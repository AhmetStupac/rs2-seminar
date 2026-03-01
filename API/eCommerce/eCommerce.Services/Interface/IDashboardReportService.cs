using eCommerce.Model.Responses;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IDashboardReportService
    {
        Task<DashboardReportResponse> GetReportAsync();
        Task<TrainerDashboardResponse> GetTrainerDashboardAsync(int personalTrainerId);
    }
}
