using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IGroupTrainingSessionService : ICRUDService
        <GroupTrainingSessionResponse, GroupTrainingSessionSearchObject, GroupTrainingSessionUpsertRequest, GroupTrainingSessionUpsertRequest>
    {
        Task<GroupTrainingSessionResponse> JoinAsync(int groupTrainingSessionId, int userId);
        Task<bool> LeaveAsync(int groupTrainingSessionId, int userId);
    }
}
