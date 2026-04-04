using eCommerce.Model.Enums;
using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class PaymentService : BaseService<PaymentResponse, PaymentSearchObject, Payment>, IPaymentService
    {
        private readonly IB210033DbContext _context;
        private readonly IConfiguration _configuration;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public PaymentService(IB210033DbContext context, IMapper mapper, IConfiguration configuration, IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _context = context;
            _configuration = configuration;
            _httpContextAccessor = httpContextAccessor;
            StripeConfiguration.ApiKey = _configuration["Stripe:SecretKey"];
        }

        protected override IQueryable<Payment> ApplyFilter(IQueryable<Payment> query, PaymentSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(p => p.UserId == search.UserId.Value);

            if (search.ItemType.HasValue)
                query = query.Where(p => p.ItemType == search.ItemType.Value);

            if (!string.IsNullOrWhiteSpace(search.Status))
                query = query.Where(p => p.Status == search.Status);

            return query;
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(PaymentCreateRequest request)
        {
            var amountInCents = await ResolveAmountInCentsAsync(request);

            var options = new PaymentIntentCreateOptions
            {
                Amount = amountInCents,
                Currency = "eur",
                PaymentMethodTypes = new System.Collections.Generic.List<string> { "card" },
                Metadata = new System.Collections.Generic.Dictionary<string, string>
                {
                    { "userId", request.UserId.ToString() },
                    { "itemType", request.ItemType.ToString() },
                    { "itemId", request.ItemId?.ToString() ?? "N/A" }
                }
            };

            var stripeService = new PaymentIntentService();
            var intent = await stripeService.CreateAsync(options);

            var record = new Payment
            {
                UserId = request.UserId,
                ItemType = request.ItemType,
                ItemId = request.ItemId,
                AmountInCents = (int)amountInCents,
                StripePaymentIntentId = intent.Id,
                Status = intent.Status,
                CreatedAt = DateTime.UtcNow
            };

            _context.Set<Payment>().Add(record);
            await _context.SaveChangesAsync();

            return new PaymentIntentResponse
            {
                ClientSecret = intent.ClientSecret,
                PaymentRecordId = record.Id,
                AmountInCents = record.AmountInCents
            };
        }

        public async Task<PaymentResponse> ConfirmPaymentAsync(ConfirmPaymentRequest request)
        {
            var record = await _context.Set<Payment>()
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == request.StripePaymentIntentId);

            if (record == null)
                throw new KeyNotFoundException($"No payment record found for intent '{request.StripePaymentIntentId}'.");

            var currentUserId = GetCurrentUserId();
            var isAdmin = IsCurrentUserAdmin();
            if (!isAdmin && record.UserId != currentUserId)
                throw new UnauthorizedAccessException("You are not allowed to confirm this payment.");

            var stripeService = new PaymentIntentService();
            var intent = await stripeService.GetAsync(request.StripePaymentIntentId);

            if (intent == null)
                throw new InvalidOperationException("Stripe PaymentIntent was not found.");

            if (intent.Amount != record.AmountInCents)
                throw new InvalidOperationException("Stripe payment amount does not match the stored payment record.");

            record.Status = intent.Status;

            if (!string.Equals(intent.Status, "succeeded", StringComparison.OrdinalIgnoreCase))
            {
                await _context.SaveChangesAsync();
                throw new InvalidOperationException($"Payment is not successful on Stripe. Current status: {intent.Status}");
            }

            await ApplyPurchaseEffectsAsync(record);

            await _context.SaveChangesAsync();

            return MapToResponse(record);
        }

        private async Task ApplyPurchaseEffectsAsync(Payment record)
        {
            if (!record.ItemId.HasValue)
                return;

            switch (record.ItemType)
            {
                case PaymentItemType.NutritionPlan:
                {
                    var plan = await _context.Set<Database.NutritionPlan>().FindAsync(record.ItemId.Value);
                    if (plan == null)
                        throw new KeyNotFoundException($"NutritionPlan with id {record.ItemId.Value} not found.");

                    plan.UserId = record.UserId;
                    break;
                }

                case PaymentItemType.TrainingPlan:
                {
                    var plan = await _context.Set<Database.TrainingPlan>().FindAsync(record.ItemId.Value);
                    if (plan == null)
                        throw new KeyNotFoundException($"TrainingPlan with id {record.ItemId.Value} not found.");

                    plan.UserId = record.UserId;
                    break;
                }

                case PaymentItemType.Membership:
                default:
                    break;
            }
        }

        private int GetCurrentUserId()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            if (user?.Identity?.IsAuthenticated != true)
                throw new UnauthorizedAccessException("Unauthorized user.");

            var userIdClaim = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? user.FindFirst("nameid")?.Value;

            if (!int.TryParse(userIdClaim, out var userId))
                throw new UnauthorizedAccessException("Invalid user identity.");

            return userId;
        }

        private bool IsCurrentUserAdmin()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            return user?.IsInRole("SuperAdmin") == true || user?.IsInRole("Administrator") == true || user?.IsInRole("Admin") == true;
        }

        // -----------------------------------------------------------------------
        // Helpers
        // -----------------------------------------------------------------------

        private async Task<long> ResolveAmountInCentsAsync(PaymentCreateRequest request)
        {
            switch (request.ItemType)
            {
                case PaymentItemType.TrainingPlan:
                {
                    if (!request.ItemId.HasValue)
                        throw new ArgumentException("ItemId is required for TrainingPlan payments.");

                    var plan = await _context.Set<Database.TrainingPlan>()
                        .FindAsync(request.ItemId.Value);

                    if (plan == null)
                        throw new KeyNotFoundException($"TrainingPlan with id {request.ItemId.Value} not found.");

                    return (long)(plan.BasePrice * 100);
                }

                case PaymentItemType.NutritionPlan:
                {
                    if (!request.ItemId.HasValue)
                        throw new ArgumentException("ItemId is required for NutritionPlan payments.");

                    var plan = await _context.Set<Database.NutritionPlan>()
                        .FindAsync(request.ItemId.Value);

                    if (plan == null)
                        throw new KeyNotFoundException($"NutritionPlan with id {request.ItemId.Value} not found.");

                    return (long)(plan.Price * 100);
                }

                case PaymentItemType.Membership:
                {
                    if (!request.ItemId.HasValue)
                        throw new ArgumentException("ItemId (PersonalTrainer ID) is required for Membership payments.");

                    var trainer = await _context.Set<Database.PersonalTrainer>()
                        .FindAsync(request.ItemId.Value);

                    if (trainer == null)
                        throw new KeyNotFoundException($"PersonalTrainer with id {request.ItemId.Value} not found.");

                    if (!request.CustomAmountInCents.HasValue || request.CustomAmountInCents.Value <= 0)
                        throw new ArgumentException("CustomAmountInCents is required for Membership payments.");

                    return request.CustomAmountInCents.Value;
                }

                default:
                    throw new ArgumentOutOfRangeException(nameof(request.ItemType), "Unsupported PaymentItemType.");
            }
        }
    }
}
