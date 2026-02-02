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
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class TrainingPlanService : BaseCRUDService<TrainingPlanResponse, NameSearchObject, Database.TrainingPlan, TrainingPlanUpsertRequest, TrainingPlanUpsertRequest>
        , ITrainingPlanService
    {

        private readonly IValidator<TrainingPlanUpsertRequest> _validator;

        public TrainingPlanService(IB210033DbContext context, IMapper mapper, IValidator<TrainingPlanUpsertRequest> validator)
            : base(context, mapper)
        {
            _validator = validator;
        }


        protected override IQueryable<Database.TrainingPlan> ApplyFilter(IQueryable<Database.TrainingPlan> query, NameSearchObject search)
        {


            var result = query.Include(t=> t.PersonalTrainer).ThenInclude(pt=> pt.User);

            var firstTrainer = result.FirstOrDefault();
            if (firstTrainer?.User == null)
            {
                // User is not being included
            }

            return result;
        }


        protected override TrainingPlanResponse MapToResponse(TrainingPlan entity)
        {
            var response = _mapper.Map<TrainingPlanResponse>(entity);

            response.Id = entity.Id;

            if(entity.PersonalTrainer.User != null)
                response.PersonalTrainerUserFirstName = entity.PersonalTrainer.User.FirstName;

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



        protected override Task BeforeUpdate(TrainingPlan entity, TrainingPlanUpsertRequest insertRequest)
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
