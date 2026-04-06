using AutoMapper.Execution;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Repository
{
    public class UserRepository(IB210033DbContext context) : IUserRepository
    {
        public async Task<bool> Complete()
        {
            try
            {
                return await context.SaveChangesAsync() > 0;
            }
            catch (DbUpdateException ex)
            {
                throw new Exception("An error occured while saving changes", ex);
            }
        }

        public async Task<User?> GetUserByIdAsync(int id)
        {
            return await context.Users.FindAsync(id);
        }

        public async Task<List<User>> GetUsersByIdsAsync(IEnumerable<int> ids)
        {
            var userIds = ids.Distinct().ToList();
            return await context.Users
                .Where(u => userIds.Contains(u.Id))
                .ToListAsync();
        }
    }
}
