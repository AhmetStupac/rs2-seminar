using EasyNetQ;
using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using Connection = eCommerce.Services.Database.Connection;
using Group = eCommerce.Services.Database.Group;

namespace eCommerce.Services.Interface
{
    public interface IMessageRepository
    {
        void AddMessage(Message message);
        void DeleteMessage(Message message);
        Task<Message?> GetMessage(string messageId);
        //Task<PaginatedResult<MessageDto>> GetMessagesForMember(MessageParams messageParams);
        Task<IReadOnlyList<MessageResponse>> GetMessageThread(int currentMemberId, int recipientId);

        void AddGroup(Group group);
        Task RemoveConnection(string connectionId);
        Task<Connection?> GetConnection(string connectionId);
        //Task<Group?> GetMessageGroup(string groupName);
        //Task<Group?> GetGroupForConnection(string connectionId);
    }
}
