using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class PersonalTrainerRatingService : IPersonalTrainerRatingService
    {
        private readonly IB210033DbContext _context;

        public PersonalTrainerRatingService(IB210033DbContext context)
        {
            _context = context;
        }

        public async Task<PersonalTrainerRatingResponse> CreateRatingAsync(int userId, PersonalTrainerRatingUpsertRequest request)
        {
            // Check if user already rated this trainer
            var existingRating = await _context.PersonalTrainerRatings
                .FirstOrDefaultAsync(r => r.UserId == userId && r.PersonalTrainerId == request.PersonalTrainerId);

            if (existingRating != null)
            {
                throw new InvalidOperationException("You have already rated this personal trainer. Use update instead.");
            }

            // Verify trainer exists
            var trainer = await _context.PersonalTrainers
                .Include(pt => pt.User)
                .FirstOrDefaultAsync(pt => pt.Id == request.PersonalTrainerId);

            if (trainer == null)
            {
                throw new InvalidOperationException("Personal trainer not found.");
            }

            var rating = new PersonalTrainerRating
            {
                UserId = userId,
                PersonalTrainerId = request.PersonalTrainerId,
                Rating = request.Rating,
                Comment = request.Comment,
                CreatedAt = DateTime.UtcNow
            };

            _context.PersonalTrainerRatings.Add(rating);
            await _context.SaveChangesAsync();

            return await GetRatingResponseAsync(rating.Id);
        }

        public async Task<PersonalTrainerRatingResponse?> UpdateRatingAsync(int ratingId, int userId, PersonalTrainerRatingUpsertRequest request)
        {
            var rating = await _context.PersonalTrainerRatings
                .FirstOrDefaultAsync(r => r.Id == ratingId && r.UserId == userId);

            if (rating == null)
            {
                return null;
            }

            rating.Rating = request.Rating;
            rating.Comment = request.Comment;
            rating.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return await GetRatingResponseAsync(rating.Id);
        }

        public async Task<bool> DeleteRatingAsync(int ratingId, int userId)
        {
            var rating = await _context.PersonalTrainerRatings
                .FirstOrDefaultAsync(r => r.Id == ratingId && r.UserId == userId);

            if (rating == null)
            {
                return false;
            }

            _context.PersonalTrainerRatings.Remove(rating);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<PersonalTrainerRatingResponse?> GetUserRatingForTrainerAsync(int userId, int personalTrainerId)
        {
            var rating = await _context.PersonalTrainerRatings
                .Include(r => r.User)
                .Include(r => r.PersonalTrainer)
                    .ThenInclude(pt => pt.User)
                .FirstOrDefaultAsync(r => r.UserId == userId && r.PersonalTrainerId == personalTrainerId);

            if (rating == null)
            {
                return null;
            }

            return MapToResponse(rating);
        }

        public async Task<List<PersonalTrainerRatingResponse>> GetRatingsForTrainerAsync(int personalTrainerId)
        {
            var ratings = await _context.PersonalTrainerRatings
                .Include(r => r.User)
                .Include(r => r.PersonalTrainer)
                    .ThenInclude(pt => pt.User)
                .Where(r => r.PersonalTrainerId == personalTrainerId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return ratings.Select(MapToResponse).ToList();
        }

        public async Task<(double averageRating, int totalRatings)> GetTrainerRatingStatsAsync(int personalTrainerId)
        {
            var ratings = await _context.PersonalTrainerRatings
                .Where(r => r.PersonalTrainerId == personalTrainerId)
                .ToListAsync();

            if (!ratings.Any())
            {
                return (0, 0);
            }

            var averageRating = ratings.Average(r => r.Rating);
            var totalRatings = ratings.Count;

            return (Math.Round(averageRating, 2), totalRatings);
        }

        private async Task<PersonalTrainerRatingResponse> GetRatingResponseAsync(int ratingId)
        {
            var rating = await _context.PersonalTrainerRatings
                .Include(r => r.User)
                .Include(r => r.PersonalTrainer)
                    .ThenInclude(pt => pt.User)
                .FirstAsync(r => r.Id == ratingId);

            return MapToResponse(rating);
        }

        private PersonalTrainerRatingResponse MapToResponse(PersonalTrainerRating rating)
        {
            return new PersonalTrainerRatingResponse
            {
                Id = rating.Id,
                UserId = rating.UserId,
                UserName = rating.User != null 
                    ? $"{rating.User.FirstName} {rating.User.LastName}" 
                    : "Unknown User",
                PersonalTrainerId = rating.PersonalTrainerId,
                PersonalTrainerName = rating.PersonalTrainer.User != null 
                    ? $"{rating.PersonalTrainer.User.FirstName} {rating.PersonalTrainer.User.LastName}" 
                    : "Unknown",
                Rating = rating.Rating,
                Comment = rating.Comment,
                CreatedAt = rating.CreatedAt,
                UpdatedAt = rating.UpdatedAt
            };
        }
    }
}
