using eCommerce.Model.Messages;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IEmailService
    {
        Task SendPasswordResetEmailAsync(string toEmail, string resetToken, string userName);
        Task SendLoginNotificationEmailAsync(LoginNotificationMessage message);
    }
}
