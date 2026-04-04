using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
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

        public UsersController(IUserService userService, ITokenService tokenService)
        {
            _userService = userService;
            _tokenService = tokenService;
        }

        [HttpGet]
        public async Task<ActionResult<List<UserResponse>>> Get([FromQuery] UserSearchObject? search = null)
        {
            return await _userService.GetAsync(search ?? new UserSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserResponse>> GetById(int id)
        {
            var user = await _userService.GetByIdAsync(id);
            
            if (user == null)
                return NotFound();
                
            return user;
        }


        //register
        [AllowAnonymous]
        [HttpPost]
        public async Task<ActionResult<UserResponse>> Create(UserUpsertRequest request)
        {
            // Only allow role assignment when the caller is authenticated and has the SuperAdmin role.
            if (!(User?.Identity?.IsAuthenticated == true && User.IsInRole("SuperAdmin")))
            {
                request.RoleIds = new List<int>();
            }

            var createdUser = await _userService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdUser.Id }, createdUser);
        }

        // update

        [HttpPut("update/{id}")]
        public async Task<ActionResult<UserResponse>> Update(int id, UserUpsertRequest request)
        {
            var currentUserIdClaim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
                                     ?? User?.FindFirst("nameid")?.Value;

            if (!int.TryParse(currentUserIdClaim, out var currentUserId))
                return Forbid();

            var isAdmin = User.IsInRole("SuperAdmin") || User.IsInRole("Administrator") || User.IsInRole("Admin");
            if (!isAdmin && currentUserId != id)
                return Forbid();

            // Prevent non-admins from modifying roles
            if (!(User?.Identity?.IsAuthenticated == true && User.IsInRole("SuperAdmin")))
            {
                request.RoleIds = new List<int>();
            }

            var updatedUser = await _userService.UpdateAsync(id, request);
            
            if (updatedUser == null)
                return NotFound();
                
            return updatedUser;
        }

        // soft delete
        [Authorize(Roles = "SuperAdmin")]
        [HttpDelete("soft/{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _userService.DeleteAsync(id);
            
            if (!deleted)
                return NotFound();
                
            return NoContent();
        }

        // Permanentno brisanje - samo za SuperAdmin
        [Authorize(Roles = "SuperAdmin")]
        [HttpDelete("{id}/permanent")]
        public async Task<ActionResult> PermanentDelete(int id)
        {
            var deleted = await _userService.PermanentDeleteAsync(id);
            
            if (!deleted)
                return NotFound();
                
            return NoContent();
        }

        // Restore deleted user
        [Authorize(Roles = "SuperAdmin")]
        [HttpPost("restore/{id}")]
        public async Task<ActionResult> RestoreUser(int id)
        {
            var restored = await _userService.RestoreUserAsync(id);
            
            if (!restored)
                return NotFound();
                
            return Ok(new { message = "User successfully restored" });
        }

        // View deleted users
        [Authorize(Roles = "SuperAdmin")]
        [HttpGet("deleted")]
        public async Task<ActionResult<List<UserResponse>>> GetDeletedUsers()
        {
            var deletedUsers = await _userService.GetDeletedUsersAsync();
            return Ok(deletedUsers);
        }
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
        
        [Authorize(Roles = "SuperAdmin")]
        [HttpPost("ban-user")]
        public async Task<IActionResult> BanUser([FromBody] BanUserResponse dto)
        {
            var result = await _userService.BanUserAsync(dto.UserId, dto.Reason, dto.ExpiresAt);

            if (!result)
                return NotFound(new { message = "User not found" });

            return Ok(new { message = "User successfully banned" });
        }

        [Authorize(Roles = "SuperAdmin")]
        [HttpPost("unban-user/{userId}")]
        public async Task<IActionResult> UnbanUser(int userId)
        {
            var result = await _userService.UnbanUserAsync(userId);

            if (!result)
                return NotFound(new { message = "User not found" });

            return Ok(new { message = "User successfully unbanned" });
        }

        [HttpGet("check-ban/{userId}")]
        public async Task<IActionResult> CheckBan(int userId)
        {
            var isBanned = await _userService.IsUserBannedAsync(userId);
            return Ok(new { isBanned });
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