namespace eCommerce.Services.Interface
{
    /// <summary>
    /// Provides a single, consistent way to read the authenticated user's identity
    /// and role membership across controllers, filters and middleware.
    /// </summary>
    public interface ICurrentUserService
    {
        /// <summary>Parsed UserId from the JWT claim, or null when unauthenticated.</summary>
        int? UserId { get; }

        bool IsAuthenticated { get; }

        bool IsSuperAdmin { get; }
        bool IsAdministrator { get; }

        /// <summary>True when the caller is SuperAdmin OR Administrator.</summary>
        bool IsAdmin { get; }
    }
}
