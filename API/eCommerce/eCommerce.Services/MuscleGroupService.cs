using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
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
        public MuscleGroupService(IB210033DbContext context, IMapper mapper) : base(context, mapper)
        {
            
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
    }
}