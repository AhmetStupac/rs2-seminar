using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Validators;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class TrainingPlanService : BaseCRUDService<TrainingPlanResponse, TrainingPlanSearchObject, Database.TrainingPlan, TrainingPlanUpsertRequest, TrainingPlanUpsertRequest>
        , ITrainingPlanService
    {

        private readonly IValidator<TrainingPlanUpsertRequest> _validator;
        private readonly ICurrentUserService _currentUser;

        public TrainingPlanService(
            IB210033DbContext context,
            IMapper mapper,
            IValidator<TrainingPlanUpsertRequest> validator,
            ICurrentUserService currentUser)
            : base(context, mapper)
        {
            _validator = validator;
            _currentUser = currentUser;
        }


        protected override async Task<IQueryable<Database.TrainingPlan>> ApplyFilterAsync(IQueryable<Database.TrainingPlan> query, TrainingPlanSearchObject search)
        {
            // Keep the result as IQueryable<Database.TrainingPlan> to avoid type mismatch
            IQueryable<Database.TrainingPlan> result = query
                .Include(t => t.PersonalTrainer)
                    .ThenInclude(pt => pt.User)
                .Include(t => t.ExercisePlans)
                    .ThenInclude(ep => ep.Exercise);

            // When PersonalTrainerId is specified (e.g. purchase flow), filter by that trainer's plans only
            if (search.PersonalTrainerId.HasValue && search.PersonalTrainerId.Value > 0)
            {
                result = result.Where(t => t.PersonalTrainerId == search.PersonalTrainerId.Value);
                return result;
            }

            // Filter by authenticated user
            if (_currentUser.UserId.HasValue)
            {
                var userId = _currentUser.UserId.Value;
                // Check if user is a personal trainer
                var personalTrainerId = await _context.PersonalTrainers
                    .Where(pt => pt.UserId == userId)
                    .Select(pt => pt.Id)
                    .FirstOrDefaultAsync();

                if (personalTrainerId > 0)
                {
                    // User is a personal trainer - show only their created training plans
                    result = result.Where(t => t.PersonalTrainerId == personalTrainerId);
                }
                else
                {
                    // User is a regular user - show only training plans assigned to them
                    result = result.Where(t => t.UserId == userId);
                }
            }

            return result;
        }


        protected override TrainingPlanResponse MapToResponse(TrainingPlan entity)
        {
            var response = _mapper.Map<TrainingPlanResponse>(entity);

            response.Id = entity.Id;

            if(entity.PersonalTrainer?.User != null)
                response.PersonalTrainerUserFirstName = entity.PersonalTrainer.User.FirstName;

            // Map exercises to response
            if (entity.ExercisePlans != null && entity.ExercisePlans.Any())
            {
                response.Exercises = entity.ExercisePlans.Select(ep => new ExercisePlanResponse
                {
                    Id = ep.Id,
                    TrainingPlanId = ep.TrainingPlanId,
                    TrainingPlanName = entity.Title,
                    ExerciseId = ep.ExerciseId,
                    ExerciseName = ep.Exercise?.Name,
                    Sets = ep.Sets,
                    Reps = ep.Reps,
                    Duration = ep.Duration,
                    CustomPrice = ep.CustomPrice,
                    Note = ep.Note
                }).ToList();
            }

            return response;
        }

        protected override Task BeforeInsert(TrainingPlan entity, TrainingPlanUpsertRequest insertRequest)
        {

            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }



        protected override async Task BeforeUpdate(TrainingPlan entity, TrainingPlanUpsertRequest insertRequest)
        {
            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            var userId = GetCurrentUserId();

            // Get personal trainer ID for this user
            var personalTrainer = await _context.PersonalTrainers
                .FirstOrDefaultAsync(pt => pt.UserId == userId);

            if (personalTrainer == null)
            {
                throw new UnauthorizedAccessException("User is not a personal trainer");
            }

            // Verify the training plan belongs to this personal trainer
            if (entity.PersonalTrainerId != personalTrainer.Id)
            {
                throw new UnauthorizedAccessException("You can only update your own training plans");
            }
        }

        public override async Task<TrainingPlanResponse?> GetByIdAsync(int id)
        {
            // Get the entity with includes
            var entity = await _context.TrainingPlans
                .Include(t => t.PersonalTrainer)
                    .ThenInclude(pt => pt.User)
                .Include(t => t.ExercisePlans)
                    .ThenInclude(ep => ep.Exercise)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (entity == null)
                return null;

            var userId = GetCurrentUserId();

            // Check if user is a personal trainer
            var personalTrainerId = _context.PersonalTrainers
                .Where(pt => pt.UserId == userId)
                .Select(pt => pt.Id)
                .FirstOrDefault();

            if (personalTrainerId > 0)
            {
                // User is a personal trainer - verify they own this training plan
                if (entity.PersonalTrainerId != personalTrainerId)
                {
                    throw new UnauthorizedAccessException("You can only view your own training plans");
                }
            }
            else
            {
                // User is a regular user - verify the plan is assigned to them
                if (entity.UserId != userId)
                {
                    throw new UnauthorizedAccessException("You can only view training plans assigned to you");
                }
            }

            return MapToResponse(entity);
        }

        public async Task<IEnumerable<TrainingPlanCatalogResponse>> GetCatalogAsync()
        {
            return await _context.TrainingPlans
                .Select(t => new TrainingPlanCatalogResponse
                {
                    Id = t.Id,
                    Title = t.Title
                })
                .ToListAsync();
        }

        protected override async Task BeforeDelete(TrainingPlan entity)
        {
            var userId = GetCurrentUserId();

            // Get personal trainer ID for this user
            var personalTrainer = await _context.PersonalTrainers
                .FirstOrDefaultAsync(pt => pt.UserId == userId);

            if (personalTrainer == null)
            {
                throw new UnauthorizedAccessException("User is not a personal trainer");
            }

            // Verify the training plan belongs to this personal trainer
            if (entity.PersonalTrainerId != personalTrainer.Id)
            {
                throw new UnauthorizedAccessException("You can only delete your own training plans");
            }
        }

        private int GetCurrentUserId()
        {
            if (!_currentUser.UserId.HasValue)
                throw new UnauthorizedAccessException("User is not authenticated");

            return _currentUser.UserId.Value;
        }
    }
}
