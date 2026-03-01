using eCommerce.Model.Enums;
using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class DashboardReportService : IDashboardReportService
    {
        private readonly IB210033DbContext _context;

        public DashboardReportService(IB210033DbContext context)
        {
            _context = context;
        }

        public async Task<DashboardReportResponse> GetReportAsync()
        {
            var totalPersonalTrainers = await _context.Set<PersonalTrainer>().CountAsync();

            var totalUsers = await _context.Set<User>()
                .IgnoreQueryFilters()
                .Where(u => !u.IsDeleted)
                .CountAsync();

            var totalGyms = await _context.Set<Gym>().CountAsync();

            var topTrainers = await _context.Set<PersonalTrainer>()
                .Include(pt => pt.User)
                .Include(pt => pt.Ratings)
                .Where(pt => pt.Ratings.Any())
                .Select(pt => new TopTrainerReportItem
                {
                    TrainerId = pt.Id,
                    TrainerFullName = pt.User != null
                        ? pt.User.FirstName + " " + pt.User.LastName
                        : "Unknown",
                    AverageRating = pt.Ratings.Average(r => (double)r.Rating),
                    RatingCount = pt.Ratings.Count()
                })
                .OrderByDescending(x => x.AverageRating)
                .ThenByDescending(x => x.RatingCount)
                .Take(3)
                .ToListAsync();

            return new DashboardReportResponse
            {
                TotalPersonalTrainers = totalPersonalTrainers,
                TotalUsers = totalUsers,
                TotalGyms = totalGyms,
                TopTrainers = topTrainers
            };
        }

        public async Task<TrainerDashboardResponse> GetTrainerDashboardAsync(int personalTrainerId)
        {
            var trainer = await _context.Set<PersonalTrainer>()
                .Include(pt => pt.User)
                .Include(pt => pt.Ratings)
                .FirstOrDefaultAsync(pt => pt.Id == personalTrainerId);

            if (trainer == null)
                throw new KeyNotFoundException($"PersonalTrainer with id {personalTrainerId} not found.");

            // IQueryable subqueries – never materialised to a local list so
            // EF Core translates the whole thing to a single SQL expression
            // and empty-set edge cases are handled correctly by the database.
            var trainerTpIds = _context.Set<TrainingPlan>()
                .Where(tp => tp.PersonalTrainerId == personalTrainerId)
                .Select(tp => (int?)tp.Id);          // cast to int? to match Payment.ItemId

            var trainerNpIds = _context.Set<NutritionPlan>()
                .Where(np => np.PersonalTrainerId == personalTrainerId)
                .Select(np => (int?)np.Id);

            // Plan counts
            var totalTrainingPlansCreated = await trainerTpIds.CountAsync();
            var totalNutritionPlansCreated = await trainerNpIds.CountAsync();

            // Succeeded-payment base queries (stay as IQueryable)
            // Status comparison is case-insensitive to handle "succeeded"/"Succeeded"/"SUCCEEDED"
            var succeededTpPayments = _context.Set<Payment>()
                .Where(p => p.Status.ToLower() == "succeeded"
                    && p.ItemType == PaymentItemType.TrainingPlan
                    && trainerTpIds.Contains(p.ItemId));

            var succeededNpPayments = _context.Set<Payment>()
                .Where(p => p.Status.ToLower() == "succeeded"
                    && p.ItemType == PaymentItemType.NutritionPlan
                    && trainerNpIds.Contains(p.ItemId));

            // For Membership, ItemId must be set to personalTrainerId at purchase time
            var succeededMemberships = _context.Set<Payment>()
                .Where(p => p.Status.ToLower() == "succeeded"
                    && p.ItemType == PaymentItemType.Membership
                    && p.ItemId == personalTrainerId);

            // Sold counts
            var soldTrainingPlans   = await succeededTpPayments.CountAsync();
            var soldNutritionPlans  = await succeededNpPayments.CountAsync();
            var soldMemberships     = await succeededMemberships.CountAsync();

            // Revenue – use nullable long so EF Core maps SQL NULL (empty set) to null instead of throwing
            var earnedTp  = await succeededTpPayments.SumAsync(p => (long?)p.AmountInCents) ?? 0L;
            var earnedNp  = await succeededNpPayments.SumAsync(p => (long?)p.AmountInCents) ?? 0L;
            var earnedMem = await succeededMemberships.SumAsync(p => (long?)p.AmountInCents) ?? 0L;
            var totalEarnedEur = (earnedTp + earnedNp + earnedMem) / 100m;

            // Distinct clients across all purchase types
            var clientsTp  = await succeededTpPayments.Select(p => p.UserId).Distinct().ToListAsync();
            var clientsNp  = await succeededNpPayments.Select(p => p.UserId).Distinct().ToListAsync();
            var clientsMem = await succeededMemberships.Select(p => p.UserId).Distinct().ToListAsync();
            var totalClients = clientsTp.Union(clientsNp).Union(clientsMem).Distinct().Count();

            var avgRating = trainer.Ratings.Any()
                ? trainer.Ratings.Average(r => (double)r.Rating)
                : 0.0;

            return new TrainerDashboardResponse
            {
                TrainerId = trainer.Id,
                TrainerFullName = trainer.User != null
                    ? trainer.User.FirstName + " " + trainer.User.LastName
                    : "Unknown",
                TotalTrainingPlansCreated = totalTrainingPlansCreated,
                TotalNutritionPlansCreated = totalNutritionPlansCreated,
                TotalClients = totalClients,
                SoldTrainingPlans = soldTrainingPlans,
                SoldNutritionPlans = soldNutritionPlans,
                SoldMemberships = soldMemberships,
                TotalEarnedEur = totalEarnedEur,
                AverageRating = Math.Round(avgRating, 1),
                RatingCount = trainer.Ratings.Count
            };
        }
    }
}
