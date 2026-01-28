using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace eCommerce.Services.Database
{
    public class User
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Username { get; set; } = string.Empty;
        
        public string PasswordHash { get; set; } = string.Empty;
        
        public string PasswordSalt { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? LastLoginAt { get; set; }
        
        [Phone]
        [MaxLength(20)]
        public string? PhoneNumber { get; set; }

        public bool? IsBanned { get; set; }  // Status bana
        public DateTime? BanExpiresAt { get; set; }  // Opciono: privremeni ban
        public string? BanReason { get; set; }  // Razlog bana

        // Soft delete properties
        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }
        public int? DeletedBy { get; set; }  // UserId ko je obrisao

        // Navigation property for the many-to-many relationship with Role
        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    }
} 