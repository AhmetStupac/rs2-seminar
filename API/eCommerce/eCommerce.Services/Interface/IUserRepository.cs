using eCommerce.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IUserRepository
    {
        //void Update(User user);
        //Task<PaginatedResult<Member>> GetMembersAsync(MemberParams memberParams);
        Task<User?> GetUserByIdAsync(int id);
        //Task<IReadOnlyList<Photo>> GetPhotosForMemberAsync(string memberId, bool isCurrentUser);
        //Task<Member?> GetMemberForUpdate(string id);
        Task<bool> Complete();
    }
}
