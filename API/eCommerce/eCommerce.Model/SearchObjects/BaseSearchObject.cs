namespace eCommerce.Model.SearchObjects
{
    /// <summary>
    /// Base search/filter object for all paginated list endpoints.
    /// PageSize is capped server-side at 50 regardless of what the client sends.
    /// Default: Page=0, PageSize=10.
    /// </summary>
    public class BaseSearchObject
    {
        public string? FTS { get; set; }

        /// <summary>Zero-based page index.</summary>
        public int? Page { get; set; } = 0;

        /// <summary>Number of items per page. Server enforces a maximum of 50.</summary>
        public int? PageSize { get; set; } = 10;

        public bool IncludeTotalCount { get; set; } = false;
    }
} 