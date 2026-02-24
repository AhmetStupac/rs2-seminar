using eCommerce.Model.Messages;
using eCommerce.Services.Interface;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class LoginEmailWorker : BackgroundService
    {
        private readonly ILogger<LoginEmailWorker> _logger;
        private readonly IServiceScopeFactory _scopeFactory;
       private readonly IConfiguration _configuration;
        private IConnection _connection;
        private IModel _channel;

        private const string QueueName = "user-login";

        public LoginEmailWorker(ILogger<LoginEmailWorker> logger, IServiceScopeFactory scopeFactory, IConfiguration configuration)
        {
            _logger = logger;
            _scopeFactory = scopeFactory;
           _configuration = configuration;
        }

       protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
           // Attempt to connect to RabbitMQ with retry logic
           if (!await TryConnectToRabbitMQAsync(stoppingToken))
           {
               _logger.LogError("LoginEmailWorker failed to connect to RabbitMQ after all retry attempts. Service will not process messages.");
               return;
           }

           try
           {
               var consumer = new EventingBasicConsumer(_channel);

               consumer.Received += async (_, ea) =>
               {
                   var body = ea.Body.ToArray();
                   var json = Encoding.UTF8.GetString(body);

                   try
                   {
                       var message = JsonSerializer.Deserialize<LoginNotificationMessage>(json);
                       if (message == null)
                       {
                           _logger.LogWarning("Received null login notification message.");
                           return;
                       }

                       using var scope = _scopeFactory.CreateScope();
                       var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();
                       await emailService.SendLoginNotificationEmailAsync(message);

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

               _logger.LogInformation("LoginEmailWorker is now listening for messages.");

               // Keep the service running
               await Task.Delay(Timeout.Infinite, stoppingToken);
           }
           catch (OperationCanceledException)
           {
               _logger.LogInformation("LoginEmailWorker is stopping.");
           }
           catch (Exception ex)
           {
               _logger.LogError(ex, "LoginEmailWorker encountered an unexpected error.");
           }
       }

       private async Task<bool> TryConnectToRabbitMQAsync(CancellationToken cancellationToken)
       {
           var factory = new ConnectionFactory
           {
               HostName = _configuration["RabbitMQ:Host"] ?? "localhost",
               UserName = _configuration["RabbitMQ:Username"] ?? "guest",
               Password = _configuration["RabbitMQ:Password"] ?? "guest",
               Port = int.Parse(_configuration["RabbitMQ:Port"] ?? "5672"),
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
                   _logger.LogInformation("LoginEmailWorker connected to RabbitMQ successfully.");
                   return true;
               }
               catch (Exception ex)
               {
                   _logger.LogWarning(ex, "LoginEmailWorker RabbitMQ connection attempt {Attempt}/{Max} failed. Retrying in 5s...", attempt, maxRetries);
                   
                   if (attempt < maxRetries)
                   {
                       await Task.Delay(5000, cancellationToken);
                   }
               }
           }

           return false;
        }

        public override Task StopAsync(CancellationToken cancellationToken)
        {
            _channel?.Close();
            _connection?.Close();
            return base.StopAsync(cancellationToken);
        }
    }
}
