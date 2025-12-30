using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IPersonalTrainerService : ICRUDService<PersonalTrainerResponse, PersonalTrainerSearchObject,PersonalTrainerUpsertRequest, PersonalTrainerUpsertRequest>
    {

    }
}
