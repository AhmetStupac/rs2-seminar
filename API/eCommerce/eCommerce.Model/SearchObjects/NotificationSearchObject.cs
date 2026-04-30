using System;

namespace eCommerce.Model.SearchObjects
{
    public class NotificationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public bool? IsRead { get; set; }
        public DateTime? CreatedAfter { get; set; }
    }
}
