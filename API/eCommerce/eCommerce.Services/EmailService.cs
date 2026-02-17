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

        public async Task SendPasswordResetEmailAsync(string toEmail, string resetCode, string userName)
        {
            var smtpHost = _configuration["EmailSettings:SmtpHost"];
            var smtpPort = int.Parse(_configuration["EmailSettings:SmtpPort"] ?? "587");
            var smtpUsername = _configuration["EmailSettings:SmtpUsername"];
            var smtpPassword = _configuration["EmailSettings:SmtpPassword"];
            var fromEmail = _configuration["EmailSettings:FromEmail"];
            var fromName = _configuration["EmailSettings:FromName"] ?? "PersonalTrainerApp";

            var mailMessage = new MailMessage
            {
                From = new MailAddress(fromEmail, fromName),
                Subject = "Password Reset Verification Code - PersonalTrainerApp",
                Body = GetEmailBody(userName, resetCode),
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

        private string GetEmailBody(string userName, string resetCode)
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
        .code-box {{ 
            background-color: #f0f8ff;
            border: 2px solid #007bff;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
        }}
        .code {{ 
            font-size: 32px;
            font-weight: bold;
            color: #007bff;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
        }}
        .footer {{ padding: 20px; text-align: center; font-size: 12px; color: #666; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Password Reset Verification</h1>
        </div>
        <div class='content'>
            <p>Dear {userName},</p>
            <p>We received a request to reset your password. Please use the verification code below to reset your password:</p>
            
            <div class='code-box'>
                <p style='margin: 0; font-size: 14px; color: #666;'>Your verification code:</p>
                <p class='code'>{resetCode}</p>
            </div>
            
            <p><strong>Important:</strong></p>
            <ul style='color: #666;'>
                <li>This code will expire in <strong>15 minutes</strong></li>
                <li>Enter this code in your application to reset your password</li>
                <li>Do not share this code with anyone</li>
            </ul>
            
            <p>If you did not request a password reset, please ignore this email and your password will remain unchanged.</p>
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
