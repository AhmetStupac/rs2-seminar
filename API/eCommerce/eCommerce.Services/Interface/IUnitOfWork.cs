using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IUnitOfWork
    {
        IMessageRepository MessageRepository { get; }
        Task<bool> Complete();
        bool HasChanges();
    }

}
