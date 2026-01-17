using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class ImageResponse
    {
        public int Id { get; set; }
        public string Url { get; set; }
        public string Name { get; set; }
        public long Size { get; set; }
        public bool IsHeader { get; set; }
        public int? UserId { get; set; }
    }
}
