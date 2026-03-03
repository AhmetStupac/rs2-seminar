using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class PersonalTrainerService : BaseCRUDService<PersonalTrainerResponse, PersonalTrainerSearchObject, PersonalTrainer, PersonalTrainerUpsertRequest, PersonalTrainerUpsertRequest>, IPersonalTrainerService
    {
        private static MLContext? _mlContext;
        private static readonly object _mlLock = new object();
        private static ITransformer? _model;

        private readonly IValidator<PersonalTrainerUpsertRequest> _validator;

        public PersonalTrainerService(IB210033DbContext context, IMapper mapper, IValidator<PersonalTrainerUpsertRequest> validator)
            : base(context, mapper)
        {
            _validator = validator;
            if (_mlContext == null)
            {
                lock (_mlLock)
                {
                    _mlContext ??= new MLContext();
                }
            }
        }

        protected override IQueryable<PersonalTrainer> ApplyFilter(IQueryable<PersonalTrainer> query, PersonalTrainerSearchObject search)
        {
            return query.Include(pt => pt.User)
                        .Include(pt => pt.Ratings);
        }

        protected override PersonalTrainerResponse MapToResponse(PersonalTrainer entity)
        {
            var response = _mapper.Map<PersonalTrainerResponse>(entity);

            // Calculate average rating and total ratings
            if (entity.Ratings != null && entity.Ratings.Any())
            {
                response.AverageRating = Math.Round(entity.Ratings.Average(r => r.Rating), 2);
                response.TotalRatings = entity.Ratings.Count;
            }
            else
            {
                response.AverageRating = 0;
                response.TotalRatings = 0;
            }

            return response;
        }

        protected override async Task BeforeInsert(PersonalTrainer entity, PersonalTrainerUpsertRequest insertRequest)
        {
            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            var alreadyExists = await _context.PersonalTrainers
                .Include(pt => pt.User)
                .AnyAsync(pt => pt.UserId == insertRequest.UserId);

            if (alreadyExists)
            {
                var user = await _context.Users.FindAsync(insertRequest.UserId);
                throw new InvalidOperationException($"A personal trainer with user name '{user?.FirstName}' already exists.");
            }
        }

        protected override Task BeforeUpdate(PersonalTrainer entity, PersonalTrainerUpsertRequest updateRequest)
        {
            var result = _validator.Validate(updateRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }

        public async Task<PersonalTrainerResponse?> RecommendForUserAsync(int userId)
        {
            var candidateTrainers = await _context.PersonalTrainers
                .Include(pt => pt.User)
                .Include(pt => pt.Ratings)
                .Where(pt => pt.IsActive != false)
                .ToListAsync();

            if (candidateTrainers.Count == 0)
                return null;

            if (_model == null)
                return await RecommendHeuristicAsync(userId);

            if (_mlContext == null) return await RecommendHeuristicAsync(userId);
            var predictionEngine = _mlContext.Model.CreatePredictionEngine<FeedbackEntry, PersonalTrainerScorePrediction>(_model);

            var usedTrainerIds = await _context.TrainingSessions
                .Where(ts => ts.ClientId == userId)
                .Select(ts => ts.PersonalTrainerId)
                .Distinct()
                .ToListAsync();

            var highlyRatedTrainerIds = await _context.PersonalTrainerRatings
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .Select(r => r.PersonalTrainerId)
                .Distinct()
                .ToListAsync();

            var preferredSports = await GetPreferredSportsForUserAsync(userId);

            var top = candidateTrainers
                .Select(pt => new
                {
                    Trainer = pt,
                    MLScore = predictionEngine.Predict(new FeedbackEntry
                    {
                        UserId = (uint)userId,
                        PersonalTrainerId = (uint)pt.Id
                    }).Score,
                    TypeBoost = !string.IsNullOrEmpty(pt.Sport) && preferredSports.Contains(pt.Sport) ? 0.5f : 0f,
                    RatingBoost = highlyRatedTrainerIds.Contains(pt.Id) ? 0.3f : 0f
                })
                .Select(x => new
                {
                    x.Trainer,
                    FinalScore = x.MLScore + x.TypeBoost + x.RatingBoost
                })
                .OrderByDescending(x => x.FinalScore)
                .FirstOrDefault();

            return top != null ? MapToResponse(top.Trainer) : null;
        }

        private async Task<List<string>> GetPreferredSportsForUserAsync(int userId)
        {
            var trainerIdsFromSessions = await _context.TrainingSessions
                .Where(ts => ts.ClientId == userId)
                .Select(ts => ts.PersonalTrainerId)
                .Distinct()
                .ToListAsync();
            var trainerIdsFromRatings = await _context.PersonalTrainerRatings
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .Select(r => r.PersonalTrainerId)
                .Distinct()
                .ToListAsync();
            var allTrainerIds = trainerIdsFromSessions.Union(trainerIdsFromRatings).Distinct().ToList();
            if (allTrainerIds.Count == 0) return new List<string>();
            var sports = await _context.PersonalTrainers
                .Where(pt => allTrainerIds.Contains(pt.Id) && pt.Sport != null)
                .Select(pt => pt.Sport!)
                .Distinct()
                .ToListAsync();
            return sports;
        }

        private async Task<PersonalTrainerResponse?> RecommendHeuristicAsync(int userId)
        {
            var usedTrainerIds = await _context.TrainingSessions
                .Where(ts => ts.ClientId == userId)
                .Select(ts => ts.PersonalTrainerId)
                .Distinct()
                .ToListAsync();
            var highlyRatedTrainerIds = await _context.PersonalTrainerRatings
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .Select(r => r.PersonalTrainerId)
                .Distinct()
                .ToListAsync();
            var preferredSports = await GetPreferredSportsForUserAsync(userId);

            var candidates = await _context.PersonalTrainers
                .Include(pt => pt.User)
                .Include(pt => pt.Ratings)
                .Where(pt => pt.IsActive != false)
                .ToListAsync();

            if (candidates.Count == 0) return null;

            var preferred = candidates
                .Where(pt => !string.IsNullOrEmpty(pt.Sport) && preferredSports.Contains(pt.Sport) && !usedTrainerIds.Contains(pt.Id))
                .ToList();
            var fallback = candidates
                .Where(pt => !usedTrainerIds.Contains(pt.Id) || highlyRatedTrainerIds.Contains(pt.Id))
                .ToList();

            PersonalTrainer? chosen;
            if (preferred.Count > 0)
                chosen = preferred.OrderBy(_ => Guid.NewGuid()).First();
            else if (fallback.Count > 0)
                chosen = fallback.OrderBy(_ => Guid.NewGuid()).First();
            else
                chosen = candidates.OrderBy(_ => Guid.NewGuid()).First();

            return MapToResponse(chosen);
        }

        public static void TrainRecommenderAtStartup(IServiceProvider serviceProvider)
        {
            lock (_mlLock)
            {
                _mlContext ??= new MLContext();
                using var scope = serviceProvider.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<IB210033DbContext>();

                var positiveEntries = db.TrainingSessions
                    .Where(ts => ts.ClientId.HasValue)
                    .Select(ts => new FeedbackEntry
                    {
                        UserId = (uint)ts.ClientId!.Value,
                        PersonalTrainerId = (uint)ts.PersonalTrainerId,
                        Label = 1f
                    })
                    .ToList();

                var ratingEntries = db.PersonalTrainerRatings
                    .Where(r => r.Rating >= 4)
                    .Select(r => new FeedbackEntry
                    {
                        UserId = (uint)r.UserId,
                        PersonalTrainerId = (uint)r.PersonalTrainerId,
                        Label = 1.5f
                    })
                    .ToList();

                positiveEntries.AddRange(ratingEntries);

                if (positiveEntries.Count == 0)
                {
                    _model = null;
                    return;
                }

                var trainData = _mlContext.Data.LoadFromEnumerable(positiveEntries);
                var options = new Microsoft.ML.Trainers.MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(FeedbackEntry.UserId),
                    MatrixRowIndexColumnName = nameof(FeedbackEntry.PersonalTrainerId),
                    LabelColumnName = nameof(FeedbackEntry.Label),
                    LossFunction = Microsoft.ML.Trainers.MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01f,
                    Lambda = 0.025f,
                    NumberOfIterations = 50,
                    C = 0.00001f
                };

                var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                _model = estimator.Fit(trainData);
            }
        }

        private class FeedbackEntry
        {
            [KeyType(count: 100000)]
            public uint UserId { get; set; }
            [KeyType(count: 100000)]
            public uint PersonalTrainerId { get; set; }
            public float Label { get; set; }
        }

        private class PersonalTrainerScorePrediction
        {
            public float Score { get; set; }
        }
    }
}
