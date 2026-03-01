using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
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
    public class MuscleGroupService : BaseCRUDService<MuscleGroupResponse, MuscleGroupSearchObject, Database.MuscleGroup, MuscleGroupUpsertRequest, MuscleGroupUpsertRequest>, IMuscleGroupService
    {
        private readonly IValidator<MuscleGroupUpsertRequest> _validator;

        public MuscleGroupService(IB210033DbContext context, IMapper mapper, IValidator<MuscleGroupUpsertRequest> validator) : base(context, mapper)
        {
            _validator = validator;
        }

        protected override IQueryable<Database.MuscleGroup> ApplyFilter(IQueryable<Database.MuscleGroup> query, MuscleGroupSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(mg => mg.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(mg => mg.Name.Contains(search.FTS));
            }

            return query;
        }

        protected override Task BeforeInsert(Database.MuscleGroup entity, MuscleGroupUpsertRequest insertRequest)
        {
            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }

        protected override Task BeforeUpdate(Database.MuscleGroup entity, MuscleGroupUpsertRequest updateRequest)
        {
            var result = _validator.Validate(updateRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }
    }
}