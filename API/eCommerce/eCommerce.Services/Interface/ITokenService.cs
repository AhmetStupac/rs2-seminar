using eCommerce.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface ITokenService
    {
        string CreateToken(User user);
        string CreatePasswordResetToken(string email);
        string ValidatePasswordResetToken(string token);
    }
}
