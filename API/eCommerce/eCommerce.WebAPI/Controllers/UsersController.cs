using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Constants;
using eCommerce.Services;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly ITokenService _tokenService;
        private readonly ICurrentUserService _currentUser;

        public UsersController(IUserService userService, ITokenService tokenService, ICurrentUserService currentUser)
        {
            _userService = userService;
            _tokenService = tokenService;
            _currentUser = currentUser;
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpGet]
        public async Task<ActionResult<List<UserResponse>>> Get([FromQuery] UserSearchObject? search = null)
        {
            return await _userService.GetAsync(search ?? new UserSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserResponse>> GetById(int id)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            if (!_currentUser.IsSuperAdmin && _currentUser.UserId.Value != id)
                return Forbid();

            var user = await _userService.GetByIdAsync(id);
            
            if (user == null)
                return NotFound();
                
            return user;
        }


        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<ActionResult<UserResponse>> Register(RegisterRequest request)
        {
            var createdUser = await _userService.RegisterAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdUser.Id }, createdUser);
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPost("admin/manual-create")]
        public async Task<ActionResult<UserResponse>> Create(UserCreateRequest request)
        {
            var createdUser = await _userService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdUser.Id }, createdUser);
        }

        // update

        [HttpPut("update/{id}")]
        public async Task<ActionResult<UserResponse>> Update(int id, UserUpdateRequest request)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            if (!_currentUser.IsAdmin && _currentUser.UserId.Value != id)
                return Forbid();

            var updatedUser = await _userService.UpdateAsync(id, request);
            
            if (updatedUser == null)
                return NotFound();
                
            return updatedUser;
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPut("{id}/roles")]
        public async Task<ActionResult<UserResponse>> UpdateRoles(int id, [FromBody] List<int> roleIds)
        {
            var updatedUser = await _userService.UpdateRolesAsync(id, roleIds);

            if (updatedUser == null)
                return NotFound();

            return updatedUser;
        }

        // soft delete
        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpDelete("soft/{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _userService.DeleteAsync(id);
            
            if (!deleted)
                return NotFound();
                
            return NoContent();
        }

        // Permanentno brisanje - samo za SuperAdmin
        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpDelete("{id}/permanent")]
        public async Task<ActionResult> PermanentDelete(int id)
        {
            var deleted = await _userService.PermanentDeleteAsync(id);
            
            if (!deleted)
                return NotFound();
                
            return NoContent();
        }

        // Restore deleted user
        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPost("restore/{id}")]
        public async Task<ActionResult> RestoreUser(int id)
        {
            var restored = await _userService.RestoreUserAsync(id);
            
            if (!restored)
                return NotFound();
                
            return Ok(new { message = "User successfully restored" });
        }

        // View deleted users
        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpGet("deleted")]
        public async Task<ActionResult<List<UserResponse>>> GetDeletedUsers()
        {
            var deletedUsers = await _userService.GetDeletedUsersAsync();
            return Ok(deletedUsers);
        }

        // login

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<ActionResult> Login(UserLoginRequest request)
        {
            try
            {
                var user = await _userService.AuthenticateAsync(request);
                
                if (user == null)
                    return Unauthorized(new { message = "Invalid username or password" });
                
                // Create JWT token
                var token = _tokenService.CreateToken(await _userService.GetUserByIdAsync(user.Id));
                
                return Ok(new LoginResponse
                { 
                    Token = token,
                    User = user
                });
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(403, new { message = ex.Message });
            }
        }


        // Ban user
        
        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPost("ban-user")]
        public async Task<IActionResult> BanUser([FromBody] BanUserResponse dto)
        {
            var result = await _userService.BanUserAsync(dto.UserId, dto.Reason, dto.ExpiresAt);

            if (!result)
                return NotFound(new { message = "User not found" });

            return Ok(new { message = "User successfully banned" });
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPost("unban-user/{userId}")]
        public async Task<IActionResult> UnbanUser(int userId)
        {
            var result = await _userService.UnbanUserAsync(userId);

            if (!result)
                return NotFound(new { message = "User not found" });

            return Ok(new { message = "User successfully unbanned" });
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpGet("check-ban/{userId}")]
        public async Task<IActionResult> CheckBan(int userId)
        {
            var isBanned = await _userService.IsUserBannedAsync(userId);
            return Ok(new { isBanned });
        }

        [HttpGet("check-ban/me")]
        public async Task<IActionResult> CheckMyBan()
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            var isBanned = await _userService.IsUserBannedAsync(_currentUser.UserId.Value);
            return Ok(new { isBanned });
        }

        // za mobile profil reset lozinke, bez potrebe emaila
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (!_currentUser.UserId.HasValue) return Forbid();

            var changed = await _userService.ChangePasswordAsync(_currentUser.UserId.Value, request.CurrentPassword, request.NewPassword);
            if (!changed)
                return BadRequest(new { message = "Invalid current password" });

            return Ok(new { message = "Password successfully changed" });
        }

        [AllowAnonymous]
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            await _userService.ForgotPasswordAsync(request.Email);

            // Always return success message (don't reveal if email exists)
            return Ok(new { message = "If the email exists in the system, a password reset link has been sent" });
        }

        [AllowAnonymous]
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var success = await _userService.ResetPasswordAsync(request.Email, request.Code, request.NewPassword);

            if (!success)
                return BadRequest(new { message = "Invalid or expired verification code" });

            return Ok(new { message = "Password successfully reset" });
        }


    }
} 