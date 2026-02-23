using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IPaymentService : IService<PaymentResponse, PaymentSearchObject>
    {
        /// <summary>
        /// Creates a Stripe PaymentIntent, persists a pending Payment record, and returns
        /// the client secret for the Flutter Stripe SDK to confirm payment on-device.
        /// </summary>
        Task<PaymentIntentResponse> CreatePaymentIntentAsync(PaymentCreateRequest request);

        /// <summary>
        /// Marks the payment record as "succeeded" once the client confirms payment.
        /// </summary>
        Task<PaymentResponse> ConfirmPaymentAsync(ConfirmPaymentRequest request);
    }
}
