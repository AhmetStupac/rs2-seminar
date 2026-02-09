using eCommerce.Services.Interface;
using Microsoft.Extensions.Configuration;
using System;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendPasswordResetEmailAsync(string toEmail, string resetToken, string userName)
        {
            var smtpHost = _configuration["EmailSettings:SmtpHost"];
            var smtpPort = int.Parse(_configuration["EmailSettings:SmtpPort"] ?? "587");
            var smtpUsername = _configuration["EmailSettings:SmtpUsername"];
            var smtpPassword = _configuration["EmailSettings:SmtpPassword"];
            var fromEmail = _configuration["EmailSettings:FromEmail"];
            var fromName = _configuration["EmailSettings:FromName"] ?? "PersonalTrainerApp";
            var frontendUrl = _configuration["EmailSettings:FrontendUrl"] ?? "http://localhost:3000";

            // Create reset link
            var resetLink = $"{frontendUrl}/reset-password?token={resetToken}";

            var mailMessage = new MailMessage
            {
                From = new MailAddress(fromEmail, fromName),
                Subject = "Password Reset - eCommerce",
                Body = GetEmailBody(userName, resetLink),
                IsBodyHtml = true
            };

            mailMessage.To.Add(toEmail);

            using var smtpClient = new SmtpClient(smtpHost, smtpPort)
            {
                EnableSsl = true,
                Credentials = new NetworkCredential(smtpUsername, smtpPassword)
            };

            try
            {
                await smtpClient.SendMailAsync(mailMessage);
            }
            catch (Exception ex)
            {
                // Log error (you can add logging framework)
                throw new Exception($"Error sending email: {ex.Message}");
            }
        }

        private string GetEmailBody(string userName, string resetLink)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #007bff; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; background-color: #f9f9f9; }}
        .button {{ 
            display: inline-block; 
            padding: 12px 30px; 
            background-color: #007bff; 
            color: white; 
            text-decoration: none; 
            border-radius: 5px;
            margin: 20px 0;
        }}
        .footer {{ padding: 20px; text-align: center; font-size: 12px; color: #666; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Password Reset</h1>
        </div>
        <div class='content'>
            <p>Dear {userName},</p>
            <p>We received a request to reset your password. Click the button below to reset your password:</p>
            <center>
                <a href='{resetLink}' class='button'>Reset Password</a>
            </center>
            <p>This link will be active for the next 1 hour.</p>
            <p>If you did not request a password reset, please ignore this email.</p>
            <p>Best regards,<br>PersonalTrainerApp Team</p>
        </div>
        <div class='footer'>
            <p>This is an automatically generated email. Please do not reply to this message.</p>
        </div>
    </div>
</body>
</html>";
        }
    }
}
