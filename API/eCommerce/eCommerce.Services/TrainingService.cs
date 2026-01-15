using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class TrainingService : BaseCRUDService
        <TrainingResponse, NameSearchObject, Database.Training, TrainingUpsertRequest, TrainingUpsertRequest>, ITrainingService
    {
        public TrainingService(IB210033DbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Database.Training> ApplyFilter(IQueryable<Database.Training> query, NameSearchObject search)
        {
            // Eager-load related entities for response mapping
            query = query
                .Include(t => t.Client)
                .Include(t => t.PersonalTrainer)
                    .ThenInclude(pt => pt.User);

            // Filter by name if provided
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(t => t.Name.Contains(search.Name));
            }

            return query;
        }

        protected override async Task BeforeInsert(Database.Training entity, TrainingUpsertRequest request)
        {
            // Validate that the Client (User) exists
            var clientExists = await _context.Users.AnyAsync(u => u.Id == entity.ClientId);
            if (!clientExists)
            {
                throw new InvalidOperationException($"Client with ID {entity.ClientId} does not exist.");
            }

            // Validate that the PersonalTrainer exists
            var trainerExists = await _context.PersonalTrainers.AnyAsync(pt => pt.Id == entity.PersonalTrainerId);
            if (!trainerExists)
            {
                throw new InvalidOperationException($"Personal Trainer with ID {entity.PersonalTrainerId} does not exist.");
            }
        }

        protected override async Task BeforeUpdate(Database.Training entity, TrainingUpsertRequest request)
        {
            // Validate that the Client (User) exists
            var clientExists = await _context.Users.AnyAsync(u => u.Id == request.ClientId);
            if (!clientExists)
            {
                throw new InvalidOperationException($"Client with ID {request.ClientId} does not exist.");
            }

            // Validate that the PersonalTrainer exists
            var trainerExists = await _context.PersonalTrainers.AnyAsync(pt => pt.Id == request.PersonalTrainerId);
            if (!trainerExists)
            {
                throw new InvalidOperationException($"Personal Trainer with ID {request.PersonalTrainerId} does not exist.");
            }
        }

        protected override TrainingResponse MapToResponse(Database.Training entity)
        {
            var response = _mapper.Map<TrainingResponse>(entity);

            // Populate additional fields from related entities
            if (entity.Client != null)
            {
                response.Client = $"{entity.Client.FirstName} {entity.Client.LastName}";
            }

            if (entity.PersonalTrainer?.User != null)
            {
                response.PersonalTrainer = $"{entity.PersonalTrainer.User.FirstName} {entity.PersonalTrainer.User.LastName}";
            }

            return response;
        }
    }
}