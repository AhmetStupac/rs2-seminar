using eCommerce.Model.Responses;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IMembershipService
    {
        /// <summary>Returns active memberships for the given client user.</summary>
        Task<List<MembershipResponse>> GetClientMembershipsAsync(int clientUserId);

        /// <summary>Returns all memberships (active and expired) for a trainer's clients.</summary>
        Task<List<MembershipResponse>> GetTrainerMembershipsAsync(int personalTrainerId);

        /// <summary>Returns the active client count for a trainer.</summary>
        Task<int> GetActiveClientCountAsync(int personalTrainerId);

        /// <summary>Checks whether a specific client has an active membership with a specific trainer.</summary>
        Task<bool> HasActiveMembershipAsync(int clientUserId, int personalTrainerId);

        /// <summary>Revokes a membership (e.g. trainer removes client). Does not refund.</summary>
        Task<MembershipResponse> RevokeAsync(int membershipId, int requestingUserId);
    }
}
