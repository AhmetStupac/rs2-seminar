using eCommerce.Model.Requests;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using System;

namespace eCommerce.Services.States
{
    /// <summary>
    /// Terminal state. A completed session cannot transition to any other state.
    /// All operations inherit the default "not allowed" behavior from <see cref="BaseTrainingSessionState"/>.
    /// </summary>
    public class CompletedTrainingSessionState : BaseTrainingSessionState
    {
        public CompletedTrainingSessionState(
            IServiceProvider serviceProvider,
            IB210033DbContext context,
            IMapper mapper,
            IHttpContextAccessor httpContextAccessor,
            INotificationService notificationService,
            IValidator<TrainingSessionUpsertRequest> validator,
            IValidator<TrainingSessionCancelRequest> cancelValidator)
            : base(serviceProvider, context, mapper, httpContextAccessor, notificationService, validator, cancelValidator)
        {
        }
    }
}
