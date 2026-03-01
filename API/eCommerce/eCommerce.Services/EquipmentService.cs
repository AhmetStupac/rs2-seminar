using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Validators;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class EquipmentService : BaseCRUDService
        <EquipmentResponse, NameSearchObject, Database.Equipment, EquipmentUpsertRequest, EquipmentUpsertRequest>, IEquipmentService
    {
        private readonly IValidator<EquipmentUpsertRequest> _validator;

        public EquipmentService(IB210033DbContext context, IMapper mapper, IValidator<EquipmentUpsertRequest> validator)
            : base(context, mapper)
        {
            _validator = validator;
        }

        protected override Task BeforeInsert(Database.Equipment entity, EquipmentUpsertRequest insertRequest)
        {
            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }

        protected override Task BeforeUpdate(Database.Equipment entity, EquipmentUpsertRequest updateRequest)
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

