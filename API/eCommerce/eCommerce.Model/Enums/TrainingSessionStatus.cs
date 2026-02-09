using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Enums
{
    public enum TrainingSessionStatus
    {
        Pending = 0,      // Klijent kreirao, čeka potvrdu
        Confirmed = 1,    // Trener potvrdio
        Completed = 2,    // Trening obavljen
        Cancelled = 3,    // Otkazan
        NoShow = 4        // Klijent se nije pojavio
    }
}
