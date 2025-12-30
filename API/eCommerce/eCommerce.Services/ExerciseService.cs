using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class ExerciseService : BaseCRUDService<ExerciseResponse, ExerciseSearchObject, Database.Exercise, ExerciseUpsertRequest, ExerciseUpsertRequest>, IExerciseService
    {
        public ExerciseService(IB210033DbContext context, IMapper mapper) : base(context, mapper)
        {
            
        }

        protected override Exercise MapInsertToEntity(Exercise entity, ExerciseUpsertRequest request)
        {
            // Only map Name and EquipmentId (ignore MuscleGroupId since it doesn't exist on Exercise)
            entity.Name = request.Name;
            entity.EquipmentId = request.EquipmentId ?? 0;
            
            return entity;
        }

        protected override void MapUpdateToEntity(Exercise entity, ExerciseUpsertRequest request)
        {
            // Only map Name and EquipmentId (ignore MuscleGroupId since it doesn't exist on Exercise)
            entity.Name = request.Name;
            entity.EquipmentId = request.EquipmentId ?? 0;
        }

        protected override async Task BeforeInsert(Database.Exercise entity, ExerciseUpsertRequest request)
        {
            // Initialize the collection
            entity.ExerciseMuscleGroups = new List<ExerciseMuscleGroup>();

            // Create the ExerciseMuscleGroup relationship
            if (request.MuscleGroupId > 0)
            {
                var exerciseMuscleGroup = new ExerciseMuscleGroup
                {
                    MuscleGroupId = request.MuscleGroupId,
                    Exercise = entity
                };
                entity.ExerciseMuscleGroups.Add(exerciseMuscleGroup);
            }
            _context.Exercises.Add(entity);
            _context.SaveChanges();
        }

        protected override async Task BeforeUpdate(Database.Exercise entity, ExerciseUpsertRequest request)
        {
            // Remove existing muscle group relationships
            var existingRelationships = await _context.Set<ExerciseMuscleGroup>()
                .Where(emg => emg.ExerciseId == entity.Id)
                .ToListAsync();
            
            _context.Set<ExerciseMuscleGroup>().RemoveRange(existingRelationships);

            // Add new relationship
            if (request.MuscleGroupId > 0)
            {
                var newRelationship = new ExerciseMuscleGroup
                {
                    ExerciseId = entity.Id,
                    MuscleGroupId = request.MuscleGroupId
                };
                _context.Set<ExerciseMuscleGroup>().Add(newRelationship);
            }
            
        }

        protected override IQueryable<Database.Exercise> ApplyFilter(IQueryable<Database.Exercise> query, ExerciseSearchObject search)
        {
            query = query.Include(e => e.ExerciseMuscleGroups)
                .ThenInclude(emg => emg.MuscleGroup)
                .Include(e => e.Equipment);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(ex => ex.Name.Contains(search.Name));
            }

            return query;
        }

        protected override ExerciseResponse MapToResponse(Database.Exercise entity)
        {
            var response = _mapper.Map<ExerciseResponse>(entity);
            
            // If the response is ExerciseResponse, set the MuscleGroupId and MuscleGroupName
            if (response is ExerciseResponse exerciseResponse)
            {
                var firstMuscleGroup = entity.ExerciseMuscleGroups?.FirstOrDefault()?.MuscleGroup;
                if (firstMuscleGroup != null)
                {
                    exerciseResponse.MuscleGroupId = firstMuscleGroup.Id;
                    exerciseResponse.MuscleGroupName = firstMuscleGroup.Name;
                }
            }
            
            return response;
        }
    }
}
