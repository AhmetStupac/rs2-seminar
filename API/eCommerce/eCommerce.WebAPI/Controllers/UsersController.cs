using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
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

        [HttpPut("{id}")]
        public async Task<ActionResult<UserResponse>> Update(int id, UserUpsertRequest request)
        {
            var updatedUser = await _userService.UpdateAsync(id, request);
            
            if (updatedUser == null)
                return NotFound();
                
            return updatedUser;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _userService.DeleteAsync(id);
            
            if (!deleted)
                return NotFound();
                
            return NoContent();
        }

        [HttpPost("login")]
        public async Task<ActionResult<UserResponse>> Login(UserLoginRequest request)
        {
            var user = await _userService.AuthenticateAsync(request);
            return Ok(user);
        }


        // banovanje korisnika

        [HttpPost("ban-user")]
        public async Task<IActionResult> BanUser([FromBody] BanUserResponse dto)
        {
            var result = await _userService.BanUserAsync(dto.UserId, dto.Reason, dto.ExpiresAt);

            if (!result)
                return NotFound(new { message = "Korisnik nije pronađen" });

            return Ok(new { message = "Korisnik je uspešno banovan" });
        }

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