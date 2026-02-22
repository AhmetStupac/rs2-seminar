using System.Collections.Generic;
using System.Threading.Tasks;
using eCommerce.Model.Requests;
using eCommerce.Model.Responses;

namespace eCommerce.Services.Interface
{
    public interface IMonthlyTrainingStatisticsService
    {
        Task<List<MonthlyTrainingStatisticsResponse>> GetYearlyStatisticsAsync(int userId, int year);
        Task<MonthlyTrainingStatisticsResponse> UpdateMonthlyCommentAsync(int userId, MonthlyCommentUpsertRequest request);
        Task<MonthlyTrainingStatisticsResponse> GetMonthlyStatisticsAsync(int userId, int year, int month);
    }
}
