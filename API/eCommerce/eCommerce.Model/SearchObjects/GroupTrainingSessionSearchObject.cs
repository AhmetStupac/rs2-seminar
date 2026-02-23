namespace eCommerce.Model.SearchObjects
{
    public class GroupTrainingSessionSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? TrainingType { get; set; }
        public int? CreatorId { get; set; }
    }
}
