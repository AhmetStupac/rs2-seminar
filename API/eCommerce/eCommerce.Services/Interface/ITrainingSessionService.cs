using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface ITrainingSessionService : ICRUDService<TrainingSessionResponse, TrainingSessionSearchObject, TrainingSessionUpsertRequest, TrainingSessionUpsertRequest>
    {
        Task<TrainingSessionResponse> ConfirmAsync(int id);
        Task<TrainingSessionResponse> CancelAsync(int id, TrainingSessionCancelRequest request);
        Task<TrainingSessionResponse> CompleteAsync(int id);
        Task<TrainingSessionResponse> MarkNoShowAsync(int id);
        Task<List<string>> AllowedActionsAsync(int id);
        Task<List<DateTime>> GetAvailableTimeSlotsAsync(int trainerId, DateTime date, int durationMinutes);
        Task<bool> CheckAvailabilityAsync(int trainerId, DateTime scheduledDateTime, int durationMinutes, int? excludeSessionId = null);
    }
}
