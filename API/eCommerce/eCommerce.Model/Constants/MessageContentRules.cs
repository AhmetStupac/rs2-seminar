namespace eCommerce.Model.Constants
{
    public static class MessageContentRules
    {
        public const int MaxLength = 200;

        /// <summary>
        /// Trims whitespace and returns null when the message is empty after trim.
        /// </summary>
        public static string? Normalize(string? content)
        {
            if (content == null) return null;
            var trimmed = content.Trim();
            return trimmed.Length == 0 ? null : trimmed;
        }
    }
}
