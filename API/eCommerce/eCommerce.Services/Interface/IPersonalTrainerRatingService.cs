using eCommerce.Model.Requests;
using eCommerce.Model.Responses;

namespace eCommerce.Services.Interface
{
    public interface IPersonalTrainerRatingService
    {
        Task<PersonalTrainerRatingResponse> CreateRatingAsync(int userId, PersonalTrainerRatingUpsertRequest request);
        Task<PersonalTrainerRatingResponse?> UpdateRatingAsync(int ratingId, int userId, PersonalTrainerRatingUpsertRequest request);
        Task<bool> DeleteRatingAsync(int ratingId, int userId);
        Task<PersonalTrainerRatingResponse?> GetUserRatingForTrainerAsync(int userId, int personalTrainerId);
        Task<List<PersonalTrainerRatingResponse>> GetRatingsForTrainerAsync(int personalTrainerId);
        Task<(double averageRating, int totalRatings)> GetTrainerRatingStatsAsync(int personalTrainerId);
    }
}
