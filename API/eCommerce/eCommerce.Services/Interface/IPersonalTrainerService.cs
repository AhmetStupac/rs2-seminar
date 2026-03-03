using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IPersonalTrainerService : ICRUDService<PersonalTrainerResponse, PersonalTrainerSearchObject, PersonalTrainerUpsertRequest, PersonalTrainerUpsertRequest>
    {
        Task<PersonalTrainerResponse?> RecommendForUserAsync(int userId);
    }
}
