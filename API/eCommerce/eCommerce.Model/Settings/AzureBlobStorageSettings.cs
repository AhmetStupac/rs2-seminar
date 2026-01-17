using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Settings
{
    public class AzureBlobStorageSettings
    {
        public string ConnectionString { get; set; }
        public string ContainerName { get; set; }
    }
}
