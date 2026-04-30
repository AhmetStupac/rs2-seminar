using eCommerce.Model.Enums;
using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Constants;
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
        private readonly INotificationService _notificationService;

        public PaymentService(IB210033DbContext context, IMapper mapper, IConfiguration configuration, IHttpContextAccessor httpContextAccessor, INotificationService notificationService)
            : base(context, mapper)
        {
            _context = context;
            _configuration = configuration;
            _httpContextAccessor = httpContextAccessor;
            _notificationService = notificationService;
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
            await EnsureNoDuplicatePurchaseAsync(request);

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

            var purchaseTitle = await GetPurchaseTitleAsync(record);
            await _notificationService.CreateAsync(new NotificationCreateRequest
            {
                UserId = record.UserId,
                Title = "Purchase successful",
                Message = $"You purchased {purchaseTitle}.",
                Type = "purchase"
            });

            await _context.SaveChangesAsync();

            return MapToResponse(record);
        }

        public async Task<PaymentResponse> RefundPaymentAsync(RefundPaymentRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.StripePaymentIntentId))
                throw new ArgumentException("StripePaymentIntentId is required.");

            var record = await _context.Set<Payment>()
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == request.StripePaymentIntentId);

            if (record == null)
                throw new KeyNotFoundException($"No payment record found for intent '{request.StripePaymentIntentId}'.");

            var currentUserId = GetCurrentUserId();
            var isAdmin = IsCurrentUserAdmin();
            if (!isAdmin && record.UserId != currentUserId)
                throw new UnauthorizedAccessException("You are not allowed to refund this payment.");

            if (string.Equals(record.Status, "refunded", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Payment is already refunded.");

            if (!string.Equals(record.Status, "succeeded", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Only succeeded payments can be refunded.");

            var intentService = new PaymentIntentService();
            var intent = await intentService.GetAsync(request.StripePaymentIntentId);

            if (intent == null)
                throw new InvalidOperationException("Stripe PaymentIntent was not found.");

            var refundService = new RefundService();
            var refund = await refundService.CreateAsync(new RefundCreateOptions
            {
                PaymentIntent = request.StripePaymentIntentId
            });

            record.Status = string.Equals(refund.Status, "succeeded", StringComparison.OrdinalIgnoreCase)
                ? "refunded"
                : "refund_pending";

            if (string.Equals(refund.Status, "failed", StringComparison.OrdinalIgnoreCase))
            {
                await _context.SaveChangesAsync();
                throw new InvalidOperationException("Refund failed on Stripe.");
            }

            await RevertPurchaseEffectsAsync(record);

            var refundTitle = await GetPurchaseTitleAsync(record);
            await _notificationService.CreateAsync(new NotificationCreateRequest
            {
                UserId = record.UserId,
                Title = "Payment refunded",
                Message = $"Your payment for {refundTitle} was refunded.",
                Type = "refund"
            });

            await _context.SaveChangesAsync();

            return MapToResponse(record);
        }

        private async Task<string> GetPurchaseTitleAsync(Payment record)
        {
            return record.ItemType switch
            {
                PaymentItemType.TrainingPlan => (await _context.Set<Database.TrainingPlan>()
                    .Where(tp => tp.Id == record.ItemId)
                    .Select(tp => tp.Title)
                    .FirstOrDefaultAsync()) ?? "training plan",
                PaymentItemType.NutritionPlan => (await _context.Set<Database.NutritionPlan>()
                    .Where(np => np.Id == record.ItemId)
                    .Select(np => np.Title)
                    .FirstOrDefaultAsync()) ?? "nutrition plan",
                PaymentItemType.Membership => "membership",
                _ => "item"
            };
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
                {
                    // record.ItemId is the PersonalTrainer ID for memberships
                    var personalTrainerId = record.ItemId.Value;

                    var now = DateTime.UtcNow;
                    var membership = new Database.Membership
                    {
                        ClientUserId = record.UserId,
                        PersonalTrainerId = personalTrainerId,
                        PaymentId = record.Id,
                        StartDate = now,
                        ExpiryDate = now.AddDays(30),
                        IsRevoked = false,
                        CreatedAt = now
                    };

                    _context.Set<Database.Membership>().Add(membership);
                    break;
                }

                default:
                    break;
            }
        }

        private async Task EnsureNoDuplicatePurchaseAsync(PaymentCreateRequest request)
        {
            switch (request.ItemType)
            {
                case PaymentItemType.TrainingPlan:
                {
                    if (!request.ItemId.HasValue)
                        return;

                    var plan = await _context.Set<Database.TrainingPlan>().FindAsync(request.ItemId.Value);
                    if (plan != null && plan.UserId == request.UserId)
                        throw new InvalidOperationException("You already purchased this training plan.");
                    return;
                }

                case PaymentItemType.NutritionPlan:
                {
                    if (!request.ItemId.HasValue)
                        return;

                    var plan = await _context.Set<Database.NutritionPlan>().FindAsync(request.ItemId.Value);
                    if (plan != null && plan.UserId == request.UserId)
                        throw new InvalidOperationException("You already purchased this nutrition plan.");
                    return;
                }

                case PaymentItemType.Membership:
                {
                    if (!request.ItemId.HasValue)
                        break;

                    var personalTrainerId = request.ItemId.Value;
                    var now = DateTime.UtcNow;

                    // Check: client already has an active membership with this trainer
                    var clientHasActive = await _context.Set<Database.Membership>()
                        .AnyAsync(m => m.ClientUserId == request.UserId
                            && m.PersonalTrainerId == personalTrainerId
                            && !m.IsRevoked
                            && m.ExpiryDate > now);

                    if (clientHasActive)
                        throw new InvalidOperationException("You already have an active membership with this trainer.");

                    // Check: trainer already has 5 active clients
                    var activeClientCount = await _context.Set<Database.Membership>()
                        .CountAsync(m => m.PersonalTrainerId == personalTrainerId
                            && !m.IsRevoked
                            && m.ExpiryDate > now);

                    if (activeClientCount >= 5)
                        throw new InvalidOperationException(
                            "This trainer has reached the maximum of 5 active client memberships and cannot accept new clients at this time.");

                    return;
                }

                default:
                    break;
            }

            var hasActivePayment = await _context.Set<Payment>()
                .AnyAsync(p => p.UserId == request.UserId
                    && p.ItemType == request.ItemType
                    && p.ItemId == request.ItemId
                    && (p.Status == "succeeded" || p.Status == "refund_pending"));

            if (!hasActivePayment)
                return;

            var message = request.ItemType switch
            {
                PaymentItemType.TrainingPlan => "You already purchased this training plan.",
                PaymentItemType.NutritionPlan => "You already purchased this nutrition plan.",
                _ => "You already purchased this item."
            };

            throw new InvalidOperationException(message);
        }

        private async Task RevertPurchaseEffectsAsync(Payment record)
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

                    if (plan.UserId == record.UserId)
                        plan.UserId = null;
                    break;
                }

                case PaymentItemType.TrainingPlan:
                {
                    var plan = await _context.Set<Database.TrainingPlan>().FindAsync(record.ItemId.Value);
                    if (plan == null)
                        throw new KeyNotFoundException($"TrainingPlan with id {record.ItemId.Value} not found.");

                    if (plan.UserId == record.UserId)
                        plan.UserId = null;
                    break;
                }

                case PaymentItemType.Membership:
                {
                    var membership = await _context.Set<Database.Membership>()
                        .FirstOrDefaultAsync(m => m.PaymentId == record.Id);

                    if (membership != null)
                        membership.IsRevoked = true;

                    break;
                }

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
            return user?.IsInRole(Roles.SuperAdmin) == true || user?.IsInRole(Roles.Administrator) == true;
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
