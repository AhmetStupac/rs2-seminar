using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Constants;
using eCommerce.Services.Interface;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentController : BaseController<PaymentResponse, PaymentSearchObject>
    {
        private readonly IPaymentService _paymentService;
        private readonly IValidator<PaymentCreateRequest> _validator;

        public PaymentController(IPaymentService paymentService, IValidator<PaymentCreateRequest> validator)
            : base(paymentService)
        {
            _paymentService = paymentService;
            _validator = validator;
        }

        /// <summary>
        /// Creates a Stripe PaymentIntent for a TrainingPlan, NutritionPlan, or Membership.
        /// Returns a clientSecret that the Flutter Stripe SDK uses to confirm payment on-device.
        /// </summary>
        [HttpPost("create-intent")]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] PaymentCreateRequest request)
        {
            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
                return Forbid();

            request.UserId = currentUserId.Value;

            var validation = await _validator.ValidateAsync(request);
            if (!validation.IsValid)
                return BadRequest(validation.Errors);

            var result = await _paymentService.CreatePaymentIntentAsync(request);
            return Ok(result);
        }

        /// <summary>
        /// Called by the client after the Stripe SDK confirms the payment successfully.
        /// Updates the payment record status to "succeeded".
        /// </summary>
        [HttpPost("confirm")]
        public async Task<IActionResult> ConfirmPayment([FromBody] ConfirmPaymentRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.StripePaymentIntentId))
                return BadRequest("StripePaymentIntentId is required.");

            try
            {
                var result = await _paymentService.ConfirmPaymentAsync(request);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Returns all payment records for the specified user.
        /// </summary>
        [HttpGet("user")]
        public async Task<IActionResult> GetByUser()
        {
            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
                return Forbid();

            var userId = currentUserId.Value;
            var search = new PaymentSearchObject { UserId = userId, RetrieveAll = true };
            var result = await _paymentService.GetAsync(search);
            return Ok(result);
        }

        private int? GetCurrentUserId()
        {
            var claim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
                        ?? User?.FindFirst("nameid")?.Value;

            return int.TryParse(claim, out var userId) ? userId : null;
        }

        /// <summary>
        /// Returns all payment records (admin only).
        /// </summary>
        [Authorize(Roles = Roles.Administrator)]
        [HttpGet("all")]
        public async Task<IActionResult> GetAll()
        {
            var search = new PaymentSearchObject { RetrieveAll = true };
            var result = await _paymentService.GetAsync(search);
            return Ok(result);
        }
    }
}
