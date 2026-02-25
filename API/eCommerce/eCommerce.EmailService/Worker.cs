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
    private IConnection _connection;
    private IModel _channel;

    private const string QueueName = "user-login";

    public Worker(ILogger<Worker> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;

        var factory = new ConnectionFactory
        {
            HostName = configuration["RabbitMQ:Host"] ?? "localhost",
            UserName = configuration["RabbitMQ:Username"] ?? "guest",
            Password = configuration["RabbitMQ:Password"] ?? "guest",
            Port = int.Parse(configuration["RabbitMQ:Port"] ?? "5672"),
            RequestedHeartbeat = TimeSpan.FromSeconds(60),
            AutomaticRecoveryEnabled = true
        };

        const int maxRetries = 5;
        for (int attempt = 1; attempt <= maxRetries; attempt++)
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

                _logger.LogInformation("EmailService Worker connected to RabbitMQ.");
                break;
            }
            catch (Exception ex) when (attempt < maxRetries)
            {
                _logger.LogWarning(ex, "RabbitMQ connection attempt {Attempt}/{Max} failed. Retrying in 5s...", attempt, maxRetries);
                Thread.Sleep(5000);
            }
        }
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        stoppingToken.ThrowIfCancellationRequested();

        var consumer = new EventingBasicConsumer(_channel);

        consumer.Received += async (_, ea) =>
        {
            var json = Encoding.UTF8.GetString(ea.Body.ToArray());

            try
            {
                var message = JsonSerializer.Deserialize<LoginNotificationMessage>(json);
                if (message == null)
                {
                    _logger.LogWarning("Received null or unreadable message from queue.");
                    return;
                }

                await SendLoginNotificationEmailAsync(message);
                _logger.LogInformation("Login notification email sent to {Email}.", message.Email);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process login notification message.");
            }
        };

        _channel.BasicConsume(
            queue: QueueName,
            autoAck: true,
            consumer: consumer);

        return Task.CompletedTask;
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
