using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Validators;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class NutritionPlanService : BaseCRUDService<NutritionPlanResponse, NameSearchObject, Database.NutritionPlan, NutritionPlanUpsertRequest, NutritionPlanUpsertRequest>, INutritionPlanService
    {

        private readonly IValidator<NutritionPlanUpsertRequest> _validator;

        public NutritionPlanService(IB210033DbContext context, IMapper mapper, IValidator<NutritionPlanUpsertRequest> validator)
            : base(context, mapper)
        {
            _validator = validator;
        }

        protected override async Task BeforeInsert(Database.NutritionPlan entity, NutritionPlanUpsertRequest request)
        {
            var result = _validator.Validate(request);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }


            // Validate that PersonalTrainer exists
            var trainer = await _context.PersonalTrainers.FindAsync(request.PersonalTrainerId);
            if (trainer == null)
            {
                throw new InvalidOperationException($"Personal Trainer with ID {request.PersonalTrainerId} not found.");
            }

            // Validate that User exists
            var user = await _context.Users.IgnoreQueryFilters().FirstOrDefaultAsync(u => u.Id == request.UserId);
            if (user == null)
            {
                throw new InvalidOperationException($"User with ID {request.UserId} not found.");
            }

            // Check if user is soft-deleted
            if (user.IsDeleted)
            {
                throw new InvalidOperationException($"Cannot create nutrition plan for deleted user.");
            }

            // Set metadata
            entity.CreatedAt = DateTime.UtcNow;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Database.NutritionPlan entity, NutritionPlanUpsertRequest request)
        {

            var result = _validator.Validate(request);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            // Validate that PersonalTrainer exists
            var trainer = await _context.PersonalTrainers.FindAsync(request.PersonalTrainerId);
            if (trainer == null)
            {
                throw new InvalidOperationException($"Personal Trainer with ID {request.PersonalTrainerId} not found.");
            }

            // Validate that User exists
            var user = await _context.Users.IgnoreQueryFilters().FirstOrDefaultAsync(u => u.Id == request.UserId);
            if (user == null)
            {
                throw new InvalidOperationException($"User with ID {request.UserId} not found.");
            }

            // Check if user is soft-deleted
            if (user.IsDeleted)
            {
                throw new InvalidOperationException($"Cannot update nutrition plan for deleted user.");
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override IQueryable<Database.NutritionPlan> ApplyFilter(IQueryable<Database.NutritionPlan> query, NameSearchObject search)
        {
            // Include related entities for better query performance
            query = query.Include(np => np.Trainer)
                         .ThenInclude(pt => pt.User)
                         .Include(np => np.User);

            // Filter by name if provided
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(np => np.Title.Contains(search.Name) || 
                                          np.Description.Contains(search.Name));
            }

            return query;
        }

        protected override NutritionPlanResponse MapToResponse(Database.NutritionPlan entity)
        {
            var response = _mapper.Map<NutritionPlanResponse>(entity);
            
            // Add related data if needed
            if (entity.Trainer != null)
            {
                response.TrainerName = $"{entity.Trainer.User?.FirstName} {entity.Trainer.User?.LastName}";
            }

            if (entity.User != null)
            {
                response.UserName = $"{entity.User.FirstName} {entity.User.LastName}";
            }

            return response;
        }
    }
}
