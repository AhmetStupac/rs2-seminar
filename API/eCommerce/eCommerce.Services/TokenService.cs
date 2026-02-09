using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class TokenService(IConfiguration config) : ITokenService
    {
        public string CreateToken(User user)
        {
            var tokenKey = config["TokenKey"] ?? throw new Exception("Cannot get token key");

            if (tokenKey.Length < 64) throw new Exception("Your token key needs to be >= 64 characters");

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenKey));

            var claims = new List<Claim>
            {
                new (ClaimTypes.NameIdentifier, user.Id.ToString()),
                new (ClaimTypes.Name, user.Username),
                new (ClaimTypes.Email, user.Email),
                new (ClaimTypes.GivenName, user.FirstName),
                new (ClaimTypes.Surname, user.LastName)
            };

            // Add roles to claims
            if (user.UserRoles != null)
            {
                foreach (var userRole in user.UserRoles)
                {
                    claims.Add(new Claim(ClaimTypes.Role, userRole.Role.Name));
                }
            }

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256Signature);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddDays(7), // Changed from 1 minute to 7 days
                SigningCredentials = creds
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(token);
        }

        public string CreatePasswordResetToken(string email)
        {
            var tokenKey = config["TokenKey"] ?? throw new Exception("Cannot get token key");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenKey));

            var claims = new List<Claim>
            {
                new (ClaimTypes.Email, email),
                new ("TokenType", "PasswordReset")
            };

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256Signature);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddHours(1), // Token is valid for 1 hour
                SigningCredentials = creds
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(token);
        }

        public string ValidatePasswordResetToken(string token)
        {
            try
            {
                var tokenKey = config["TokenKey"] ?? throw new Exception("Cannot get token key");
                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenKey));

                var tokenHandler = new JwtSecurityTokenHandler();
                var validationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = key,
                    ValidateIssuer = false,
                    ValidateAudience = false,
                    ClockSkew = TimeSpan.Zero
                };

                var principal = tokenHandler.ValidateToken(token, validationParameters, out _);
                
                var tokenType = principal.FindFirst("TokenType")?.Value;
                if (tokenType != "PasswordReset")
                    throw new SecurityTokenException("Invalid token type");

                var email = principal.FindFirst(ClaimTypes.Email)?.Value;
                if (string.IsNullOrEmpty(email))
                    throw new SecurityTokenException("Email not found in token");

                return email;
            }
            catch
            {
                throw new SecurityTokenException("Invalid or expired token");
            }
        }
    }
}
