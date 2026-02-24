using eCommerce.Services.Interface;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using System;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class RabbitMQPublisher : IRabbitMQPublisher, IDisposable
    {
        private readonly ILogger<RabbitMQPublisher> _logger;
       private readonly IConfiguration _configuration;
        private IConnection _connection;
        private IModel _channel;
        private bool _disposed;
       private readonly object _lock = new object();
       private bool _connectionAttempted;

        public RabbitMQPublisher(IConfiguration configuration, ILogger<RabbitMQPublisher> logger)
        {
            _logger = logger;
           _configuration = configuration;
        }

        public Task PublishAsync<T>(T message, string queueName)
        {
           EnsureConnection();

           if (_channel == null)
           {
               _logger.LogError("Cannot publish message to queue '{Queue}': RabbitMQ connection is not available.", queueName);
               throw new InvalidOperationException("RabbitMQ connection is not available.");
           }

            _channel.QueueDeclare(
                queue: queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null);

            var json = JsonSerializer.Serialize(message);
            var body = Encoding.UTF8.GetBytes(json);

            var properties = _channel.CreateBasicProperties();
            properties.Persistent = true;

            _channel.BasicPublish(
                exchange: "",
                routingKey: queueName,
                basicProperties: properties,
                body: body);

            _logger.LogInformation("Published message to queue '{Queue}'.", queueName);
            return Task.CompletedTask;
        }

       private void EnsureConnection()
       {
           if (_channel != null || _connectionAttempted)
               return;

           lock (_lock)
           {
               if (_channel != null || _connectionAttempted)
                   return;

               _connectionAttempted = true;

               var factory = new ConnectionFactory
               {
                   HostName = _configuration["RabbitMQ:Host"] ?? "localhost",
                   UserName = _configuration["RabbitMQ:Username"] ?? "guest",
                   Password = _configuration["RabbitMQ:Password"] ?? "guest",
                   Port = int.Parse(_configuration["RabbitMQ:Port"] ?? "5672"),
                   RequestedHeartbeat = TimeSpan.FromSeconds(60),
                   AutomaticRecoveryEnabled = true
               };

               const int maxRetries = 3;
               for (int attempt = 1; attempt <= maxRetries; attempt++)
               {
                   try
                   {
                       _connection = factory.CreateConnection();
                       _channel = _connection.CreateModel();
                       _logger.LogInformation("RabbitMQ publisher connected successfully.");
                       return;
                   }
                   catch (Exception ex)
                   {
                       _logger.LogWarning(ex, "RabbitMQ publisher connection attempt {Attempt}/{Max} failed.", attempt, maxRetries);
                       
                       if (attempt < maxRetries)
                       {
                           System.Threading.Thread.Sleep(2000);
                       }
                   }
               }

               _logger.LogError("RabbitMQ publisher failed to connect after all retry attempts.");
           }
       }

        public void Dispose()
        {
            if (_disposed) return;
            _channel?.Close();
            _connection?.Close();
            _disposed = true;
        }
    }
}
