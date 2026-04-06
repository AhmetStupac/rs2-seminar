using eCommerce.Services.Interface;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class RabbitMQPublisher : IRabbitMQPublisher, IDisposable
    {
        private readonly ILogger<RabbitMQPublisher> _logger;
        private readonly IConfiguration _configuration;
        private IConnection _connection;
        private IModel _channel;
        private readonly SemaphoreSlim _connectionSemaphore = new SemaphoreSlim(1, 1);
        private bool _disposed;

        public RabbitMQPublisher(IConfiguration configuration, ILogger<RabbitMQPublisher> logger)
        {
            _logger = logger;
            _configuration = configuration;
        }

        public async Task PublishAsync<T>(T message, string queueName)
        {
            var json = JsonSerializer.Serialize(message);
            var body = Encoding.UTF8.GetBytes(json);

            const int maxRetries = 5;
            var delay = TimeSpan.FromSeconds(1);

            for (int attempt = 1; attempt <= maxRetries; attempt++)
            {
                try
                {
                    await EnsureConnectionAsync();

                    if (_channel == null || !_channel.IsOpen)
                        throw new InvalidOperationException("RabbitMQ channel is not available.");

                    // RabbitMQ.Client uses synchronous publishing APIs.
                    // Run on a worker thread to keep caller path non-blocking.
                    await Task.Run(() =>
                    {
                        _channel.QueueDeclare(
                            queue: queueName,
                            durable: true,
                            exclusive: false,
                            autoDelete: false,
                            arguments: null);

                        var properties = _channel.CreateBasicProperties();
                        properties.Persistent = true;

                        _channel.BasicPublish(
                            exchange: "",
                            routingKey: queueName,
                            basicProperties: properties,
                            body: body);
                    });

                    _logger.LogInformation("Published message to queue '{Queue}'.", queueName);
                    return;
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Publish attempt {Attempt}/{Max} to queue '{Queue}' failed.", attempt, maxRetries, queueName);
                    InvalidateConnection();

                    if (attempt == maxRetries)
                    {
                        _logger.LogError("Cannot publish message to queue '{Queue}': RabbitMQ connection is not available.", queueName);
                        throw;
                    }

                    await Task.Delay(delay);
                    delay = TimeSpan.FromMilliseconds(Math.Min(delay.TotalMilliseconds * 2, 30000));
                }
            }
        }

        private async Task EnsureConnectionAsync()
        {
            if (IsConnectionOpen())
                return;

            await _connectionSemaphore.WaitAsync();
            try
            {
                if (IsConnectionOpen())
                    return;

                InvalidateConnection();

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
                var delay = TimeSpan.FromSeconds(1);

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

                        if (attempt == maxRetries)
                            throw;

                        await Task.Delay(delay);
                        delay = TimeSpan.FromMilliseconds(Math.Min(delay.TotalMilliseconds * 2, 30000));
                    }
                }
            }
            finally
            {
                _connectionSemaphore.Release();
            }
        }

        private bool IsConnectionOpen()
        {
            return _connection?.IsOpen == true && _channel?.IsOpen == true;
        }

        private void InvalidateConnection()
        {
            try
            {
                _channel?.Close();
            }
            catch { }
            finally
            {
                _channel?.Dispose();
                _channel = null;
            }

            try
            {
                _connection?.Close();
            }
            catch { }
            finally
            {
                _connection?.Dispose();
                _connection = null;
            }
        }

        public void Dispose()
        {
            if (_disposed) return;

            InvalidateConnection();
            _connectionSemaphore.Dispose();
            _disposed = true;
        }
    }
}
