using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
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

        [HttpPost]
        public async Task<ActionResult<UserResponse>> Create(UserUpsertRequest request)
        {
            var createdUser = await _userService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdUser.Id }, createdUser);
        }

        // update

        [HttpPut("update/{id}")]
        public async Task<ActionResult<UserResponse>> Update(int id, UserUpsertRequest request)
        {
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

        // Restore obrisanog korisnika
       // [Authorize(Roles = "SuperAdmin")]
        [HttpPost("restore/{id}")]
        public async Task<ActionResult> RestoreUser(int id)
        {
            var restored = await _userService.RestoreUserAsync(id);
            
            if (!restored)
                return NotFound();
                
            return Ok(new { message = "Korisnik je uspješno vraćen" });
        }

        // Pregled obrisanih korisnika
        [Authorize(Roles = "SuperAdmin")]
        [HttpGet("deleted")]
        public async Task<ActionResult<List<UserResponse>>> GetDeletedUsers()
        {
            var deletedUsers = await _userService.GetDeletedUsersAsync();
            return Ok(deletedUsers);
        }

        [HttpPost("login")]
        public async Task<ActionResult<UserResponse>> Login(UserLoginRequest request)
        {
            var user = await _userService.AuthenticateAsync(request);
            return Ok(user);
        }


        // banovanje korisnika
        
        [Authorize(Roles = "SuperAdmin")]
        [HttpPost("ban-user")]
        public async Task<IActionResult> BanUser([FromBody] BanUserResponse dto)
        {
            var result = await _userService.BanUserAsync(dto.UserId, dto.Reason, dto.ExpiresAt);

            if (!result)
                return NotFound(new { message = "Korisnik nije pronađen" });

            return Ok(new { message = "Korisnik je uspešno banovan" });
        }

        [Authorize(Roles = "SuperAdmin")]
        [HttpPost("unban-user/{userId}")]
        public async Task<IActionResult> UnbanUser(int userId)
        {
            var result = await _userService.UnbanUserAsync(userId);

            if (!result)
                return NotFound(new { message = "Korisnik nije pronađen" });

            return Ok(new { message = "Korisnik je unbanovan" });
        }

        [HttpGet("check-ban/{userId}")]
        public async Task<IActionResult> CheckBan(int userId)
        {
            var isBanned = await _userService.IsUserBannedAsync(userId);
            return Ok(new { isBanned });
        }

       
    }
} 