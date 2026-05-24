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
        private readonly ICurrentUserService _currentUser;

        public PaymentController(IPaymentService paymentService, IValidator<PaymentCreateRequest> validator, ICurrentUserService currentUser)
            : base(paymentService)
        {
            _paymentService = paymentService;
            _validator = validator;
            _currentUser = currentUser;
        }

        /// <summary>
        /// Creates a Stripe PaymentIntent for a TrainingPlan, NutritionPlan, or Membership.
        /// Returns a clientSecret that the Flutter Stripe SDK uses to confirm payment on-device.
        /// </summary>
        [HttpPost("create-intent")]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] PaymentCreateRequest request)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            request.UserId = _currentUser.UserId.Value;

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

        [HttpPost("refund-request")]
        public async Task<IActionResult> RequestRefund([FromBody] RefundRequestCreateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.StripePaymentIntentId))
                return BadRequest("StripePaymentIntentId is required.");

            try
            {
                await _paymentService.RequestRefundAsync(request);
                return Ok(new { message = "Refund request submitted." });
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

        [Authorize(Roles = Roles.SuperAdmin + "," + Roles.Administrator)]
        [HttpPost("refund-decision")]
        public async Task<IActionResult> DecideRefund([FromBody] RefundDecisionRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.StripePaymentIntentId))
                return BadRequest("StripePaymentIntentId is required.");

            try
            {
                var result = await _paymentService.DecideRefundAsync(request);
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
        /// Returns a paginated payment history for the currently authenticated user.
        /// </summary>
        [HttpGet("user")]
        public async Task<IActionResult> GetByUser([FromQuery] int page = 0, [FromQuery] int pageSize = 10)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();

            var search = new PaymentSearchObject
            {
                UserId = _currentUser.UserId.Value,
                Page = page,
                PageSize = pageSize,
                IncludeTotalCount = true
            };
            var result = await _paymentService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet]
        public override async Task<PagedResult<PaymentResponse>> Get([FromQuery] PaymentSearchObject? search = null)
        {
            if (!_currentUser.UserId.HasValue)
                return new PagedResult<PaymentResponse>();

            search ??= new PaymentSearchObject();

            if (_currentUser.IsSuperAdmin)
            {
                return await _paymentService.GetAsync(search);
            }

            if (_currentUser.IsAdministrator)
            {
                var trainerId = await _currentUser.GetPersonalTrainerIdAsync();
                if (!trainerId.HasValue)
                    return new PagedResult<PaymentResponse>();

                search.TrainerId = trainerId.Value;
                search.UserId = null;
                return await _paymentService.GetAsync(search);
            }

            search.UserId = _currentUser.UserId.Value;
            search.TrainerId = null;
            return await _paymentService.GetAsync(search);
        }

        [HttpGet("{id}")]
        public override async Task<PaymentResponse?> GetById(int id)
        {
            if (!_currentUser.UserId.HasValue) return null;

            var payment = await _paymentService.GetByIdAsync(id);
            if (payment == null) return null;

            if (_currentUser.IsSuperAdmin)
                return payment;

            if (_currentUser.IsAdministrator)
            {
                var trainerId = await _currentUser.GetPersonalTrainerIdAsync();
                if (!trainerId.HasValue)
                    return null;

                var belongsToTrainer = await _paymentService.BelongsToPersonalTrainerAsync(id, trainerId.Value);
                return belongsToTrainer ? payment : null;
            }

            return payment.UserId == _currentUser.UserId.Value ? payment : null;
        }

        /// <summary>
        /// Returns a paginated list of all payment records (admin only).
        /// SuperAdmin sees everything and may optionally filter by trainerId.
        /// Administrator (trainer) always sees only payments for their own PersonalTrainer profile.
        /// Accepts optional query params: status (e.g. refund_requested), trainerId, page, pageSize (max 50).
        /// </summary>
        [Authorize(Roles = Roles.SuperAdmin + "," + Roles.Administrator)]
        [HttpGet("all")]
        public async Task<IActionResult> GetAll(
            [FromQuery] string? status,
            [FromQuery] int? trainerId,
            [FromQuery] int page = 0,
            [FromQuery] int pageSize = 20)
        {
            if (!_currentUser.UserId.HasValue)
                return Forbid();

            var search = new PaymentSearchObject
            {
                Status = status,
                Page = page,
                PageSize = pageSize,
                IncludeTotalCount = true
            };

            if (_currentUser.IsSuperAdmin)
            {
                search.TrainerId = trainerId;
            }
            else
            {
                var ownTrainerId = await _currentUser.GetPersonalTrainerIdAsync();
                if (!ownTrainerId.HasValue)
                    return NotFound(new { message = "No PersonalTrainer profile found for the current user." });

                if (trainerId.HasValue && trainerId.Value != ownTrainerId.Value)
                    return Forbid();

                search.TrainerId = ownTrainerId.Value;
            }

            var result = await _paymentService.GetAsync(search);
            return Ok(result);
        }
    }
}
