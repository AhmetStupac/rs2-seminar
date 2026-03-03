using System;
using System.Security.Cryptography;

namespace eCommerce.Services
{
    /// <summary>
    /// Utility to generate PasswordHash and PasswordSalt for data seeding.
    /// Run GenerateForPassword() once, copy the output values into HasData().
    /// </summary>
    public static class PasswordHashGenerator
    {
        private const int SaltSize = 16;
        private const int KeySize = 32;
        private const int Iterations = 10000;

        public static (string hash, string salt) GenerateForPassword(string password)
        {
            var saltBytes = new byte[SaltSize];
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(saltBytes);
            }

            using var pbkdf2 = new Rfc2898DeriveBytes(password, saltBytes, Iterations);
            var hashBytes = pbkdf2.GetBytes(KeySize);

            return (Convert.ToBase64String(hashBytes), Convert.ToBase64String(saltBytes));
        }
    }
}
