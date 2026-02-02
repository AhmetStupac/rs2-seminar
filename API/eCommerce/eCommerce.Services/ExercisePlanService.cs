using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Validators;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace eCommerce.Services
{
    public class ExercisePlanService : BaseCRUDService<ExercisePlanResponse, ExercisePlanSearchObject, Database.ExercisePlan, ExercisePlanUpsertRequest, ExercisePlanUpsertRequest>, IExercisePlanService
    {
        private readonly IValidator<ExercisePlanUpsertRequest> _validator;

        public ExercisePlanService(IB210033DbContext context, IMapper mapper, IValidator<ExercisePlanUpsertRequest> validator) : base(context, mapper)
        {
            _validator = validator;
        }

        protected override IQueryable<Database.ExercisePlan> ApplyFilter(IQueryable<Database.ExercisePlan> query, ExercisePlanSearchObject search)
        {
            query = query.Include(ep => ep.Exercise)
                .Include(ep => ep.TrainingPlan);

            if (search.TrainingPlanId.HasValue && search.TrainingPlanId.Value > 0)
            {
                query = query.Where(ep => ep.TrainingPlanId == search.TrainingPlanId.Value);
            }

            if (search.ExerciseId.HasValue && search.ExerciseId.Value > 0)
            {
                query = query.Where(ep => ep.ExerciseId == search.ExerciseId.Value);
            }

            return query;
        }

        protected override ExercisePlanResponse MapToResponse(Database.ExercisePlan entity)
        {
            var response = _mapper.Map<ExercisePlanResponse>(entity);
            
            if (response is ExercisePlanResponse exercisePlanResponse)
            {
                if (entity.Exercise != null)
                {
                    exercisePlanResponse.ExerciseName = entity.Exercise.Name;
                }

                if (entity.TrainingPlan != null)
                {
                    exercisePlanResponse.TrainingPlanName = entity.TrainingPlan.Title;
                }
            }
            
            return response;
        }


        protected override Task BeforeInsert(Database.ExercisePlan entity, ExercisePlanUpsertRequest insertRequest)
        {
            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }

        protected override Task BeforeUpdate(Database.ExercisePlan entity, ExercisePlanUpsertRequest insertRequest)
        {
            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }
    }
}