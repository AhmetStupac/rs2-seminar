using System.Threading;
using System.Threading.Tasks;

namespace eCommerce.Model.Validators
{
    public interface IUserDuplicateChecker
    {
        Task<bool> EmailExistsAsync(string email, int? excludeUserId = null, CancellationToken cancellationToken = default);
        Task<bool> UsernameExistsAsync(string username, int? excludeUserId = null, CancellationToken cancellationToken = default);
    }
}
