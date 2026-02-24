using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IRabbitMQPublisher
    {
        Task PublishAsync<T>(T message, string queueName);
    }
}
