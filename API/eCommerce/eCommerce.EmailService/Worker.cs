using eCommerce.Model.Messages;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Text.Json;

namespace eCommerce.EmailService;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly IConfiguration _configuration;
    private IConnection? _connection;
    private IModel? _channel;

    private const string QueueName = "user-login";
    private const int MaxRetries = 5;
    private const int RetryDelayMs = 5000;

    public Worker(ILogger<Worker> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    private async Task<bool> ConnectAsync(CancellationToken cancellationToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _configuration["RabbitMQ:Host"] ?? "localhost",
            UserName = _configuration["RabbitMQ:Username"] ?? "guest",
            Password = _configuration["RabbitMQ:Password"] ?? "guest",
            Port = int.Parse(_configuration["RabbitMQ:Port"] ?? "5672"),
            RequestedHeartbeat = TimeSpan.FromSeconds(60),
            AutomaticRecoveryEnabled = true,
            DispatchConsumersAsync = true
        };

        for (int attempt = 1; attempt <= MaxRetries; attempt++)
        {
            try
            {
                _connection = factory.CreateConnection();
                _channel = _connection.CreateModel();
                _channel.QueueDeclare(
                    queue: QueueName,
                    durable: true,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null);
                _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);

                _logger.LogInformation("EmailService Worker connected to RabbitMQ.");
                return true;
            }
            catch (Exception ex) when (attempt < MaxRetries)
            {
                _logger.LogWarning(ex, "RabbitMQ connection attempt {Attempt}/{Max} failed. Retrying in {Delay}ms...",
                    attempt, MaxRetries, RetryDelayMs);
                await Task.Delay(RetryDelayMs, cancellationToken);
            }
        }

        return false;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        if (!await ConnectAsync(stoppingToken))
        {
            _logger.LogError("Failed to connect to RabbitMQ after {Max} attempts. Worker will not start.", MaxRetries);
            return;
        }

        var consumer = new AsyncEventingBasicConsumer(_channel);

        consumer.Received += async (_, ea) =>
        {
            var json = Encoding.UTF8.GetString(ea.Body.ToArray());

            try
            {
                var message = JsonSerializer.Deserialize<LoginNotificationMessage>(json);
                if (message == null)
                {
                    _logger.LogWarning("Received null or unreadable message — discarding.");
                    _channel!.BasicAck(ea.DeliveryTag, multiple: false);
                    return;
                }

                await SendLoginNotificationEmailAsync(message);
                _logger.LogInformation("Login notification email sent to {Email}.", message.Email);
                _channel!.BasicAck(ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email — rejecting message (no requeue to avoid infinite loop).");
                _channel!.BasicNack(ea.DeliveryTag, multiple: false, requeue: false);
            }
        };

        _channel!.BasicConsume(
            queue: QueueName,
            autoAck: false,
            consumer: consumer);

        await Task.Delay(Timeout.Infinite, stoppingToken);
    }

    private async Task SendLoginNotificationEmailAsync(LoginNotificationMessage message)
    {
        var smtpHost = _configuration["EmailSettings:SmtpHost"];
        var smtpPort = int.Parse(_configuration["EmailSettings:SmtpPort"] ?? "587");
        var smtpUsername = _configuration["EmailSettings:SmtpUsername"];
        var smtpPassword = _configuration["EmailSettings:SmtpPassword"];
        var fromEmail = _configuration["EmailSettings:FromEmail"];
        var fromName = _configuration["EmailSettings:FromName"] ?? "PersonalTrainerApp";

        var mailMessage = new MailMessage
        {
            From = new MailAddress(fromEmail!, fromName),
            Subject = "New Login Detected - PersonalTrainerApp",
            Body = BuildEmailBody(message.FirstName, message.LastName, message.LoginTime),
            IsBodyHtml = true
        };

        mailMessage.To.Add(message.Email);

        using var smtpClient = new SmtpClient(smtpHost, smtpPort)
        {
            EnableSsl = true,
            Credentials = new NetworkCredential(smtpUsername, smtpPassword)
        };

        await smtpClient.SendMailAsync(mailMessage);
    }

    private static string BuildEmailBody(string firstName, string lastName, string loginTime) => $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #28a745; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; background-color: #f9f9f9; }}
        .info-box {{
            background-color: #f0fff4;
            border: 2px solid #28a745;
            border-radius: 8px;
            padding: 16px;
            margin: 20px 0;
        }}
        .footer {{ padding: 20px; text-align: center; font-size: 12px; color: #666; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Login Notification</h1>
        </div>
        <div class='content'>
            <p>Dear {firstName} {lastName},</p>
            <p>We noticed a new login to your PersonalTrainerApp account.</p>
            <div class='info-box'>
                <p style='margin: 0;'><strong>Login Time:</strong> {loginTime}</p>
            </div>
            <p>If this was you, no action is needed.</p>
            <p>If you did not log in, please reset your password immediately.</p>
            <p>Best regards,<br>PersonalTrainerApp Team</p>
        </div>
        <div class='footer'>
            <p>This is an automatically generated email. Please do not reply to this message.</p>
        </div>
    </div>
</body>
</html>";

    public override Task StopAsync(CancellationToken cancellationToken)
    {
        _channel?.Close();
        _connection?.Close();
        return base.StopAsync(cancellationToken);
    }
}
