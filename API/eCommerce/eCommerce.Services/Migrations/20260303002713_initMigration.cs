using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class initMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Equipments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Equipments", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Groups",
                columns: table => new
                {
                    Name = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Groups", x => x.Name);
                });

            migrationBuilder.CreateTable(
                name: "MuscleGroups",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MuscleGroups", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Connections",
                columns: table => new
                {
                    ConnectionId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    GroupName = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Connections", x => x.ConnectionId);
                    table.ForeignKey(
                        name: "FK_Connections_Groups_GroupName",
                        column: x => x.GroupName,
                        principalTable: "Groups",
                        principalColumn: "Name",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ExerciseMuscleGroup",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ExerciseId = table.Column<int>(type: "int", nullable: false),
                    MuscleGroupId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExerciseMuscleGroup", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ExerciseMuscleGroup_MuscleGroups_MuscleGroupId",
                        column: x => x.MuscleGroupId,
                        principalTable: "MuscleGroups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ExercisePlans",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TrainingPlanId = table.Column<int>(type: "int", nullable: false),
                    ExerciseId = table.Column<int>(type: "int", nullable: false),
                    Sets = table.Column<int>(type: "int", nullable: true),
                    Reps = table.Column<int>(type: "int", nullable: true),
                    Duration = table.Column<int>(type: "int", nullable: true),
                    CustomPrice = table.Column<float>(type: "real", nullable: true),
                    Note = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExercisePlans", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Exercises",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EquipmentId = table.Column<int>(type: "int", nullable: false),
                    ImageId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Exercises", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Exercises_Equipments_EquipmentId",
                        column: x => x.EquipmentId,
                        principalTable: "Equipments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "GroupTrainingSessionParticipants",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    GroupTrainingSessionId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    JoinedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GroupTrainingSessionParticipants", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "GroupTrainingSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    TrainingType = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    KcalBurned = table.Column<int>(type: "int", nullable: false),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    Place = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatorId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GroupTrainingSessions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Gyms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Address = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    City = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Country = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    WorkTime = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ImageId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Gyms", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Images",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Url = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Size = table.Column<long>(type: "bigint", nullable: false),
                    IsHeader = table.Column<bool>(type: "bit", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Images", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Username = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PasswordSalt = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    LastLoginAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    IsBanned = table.Column<bool>(type: "bit", nullable: true),
                    BanExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    BanReason = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeletedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DeletedBy = table.Column<int>(type: "int", nullable: true),
                    ResetCode = table.Column<string>(type: "nvarchar(6)", maxLength: 6, nullable: true),
                    ResetCodeExpiry = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ProfileImageId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Users_Images_ProfileImageId",
                        column: x => x.ProfileImageId,
                        principalTable: "Images",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "Messages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DateRead = table.Column<DateTime>(type: "datetime2", nullable: true),
                    MessageSent = table.Column<DateTime>(type: "datetime2", nullable: false),
                    SenderDeleted = table.Column<bool>(type: "bit", nullable: false),
                    RecipientDeleted = table.Column<bool>(type: "bit", nullable: false),
                    SenderId = table.Column<int>(type: "int", nullable: true),
                    RecipientId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Messages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Messages_Users_RecipientId",
                        column: x => x.RecipientId,
                        principalTable: "Users",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Messages_Users_SenderId",
                        column: x => x.SenderId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MonthlyTrainingStatistics",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Year = table.Column<int>(type: "int", nullable: false),
                    Month = table.Column<int>(type: "int", nullable: false),
                    TrainingSessionCount = table.Column<int>(type: "int", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MonthlyTrainingStatistics", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MonthlyTrainingStatistics_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ItemType = table.Column<int>(type: "int", nullable: false),
                    ItemId = table.Column<int>(type: "int", nullable: true),
                    AmountInCents = table.Column<int>(type: "int", nullable: false),
                    StripePaymentIntentId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Payments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Payments_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PersonalTrainers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: true),
                    YearsOfExperience = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: true),
                    Certifications = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Sport = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    MyProperty = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PersonalTrainers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PersonalTrainers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: true),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    DateAssigned = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRoles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserRoles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "NutritionPlans",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PersonalTrainerId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: true),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TotalCalories = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Protein = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Carbs = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Fats = table.Column<int>(type: "int", nullable: false),
                    Price = table.Column<float>(type: "real", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NutritionPlans", x => x.Id);
                    table.ForeignKey(
                        name: "FK_NutritionPlans_PersonalTrainers_PersonalTrainerId",
                        column: x => x.PersonalTrainerId,
                        principalTable: "PersonalTrainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_NutritionPlans_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "PersonalTrainerRatings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    PersonalTrainerId = table.Column<int>(type: "int", nullable: false),
                    Rating = table.Column<int>(type: "int", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PersonalTrainerRatings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PersonalTrainerRatings_PersonalTrainers_PersonalTrainerId",
                        column: x => x.PersonalTrainerId,
                        principalTable: "PersonalTrainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PersonalTrainerRatings_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TrainingPlans",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PersonalTrainerId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: true),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    BasePrice = table.Column<float>(type: "real", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainingPlans", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TrainingPlans_PersonalTrainers_PersonalTrainerId",
                        column: x => x.PersonalTrainerId,
                        principalTable: "PersonalTrainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TrainingPlans_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Trainings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Duration = table.Column<int>(type: "int", nullable: false),
                    ClientId = table.Column<int>(type: "int", nullable: true),
                    PersonalTrainerId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Trainings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Trainings_PersonalTrainers_PersonalTrainerId",
                        column: x => x.PersonalTrainerId,
                        principalTable: "PersonalTrainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Trainings_Users_ClientId",
                        column: x => x.ClientId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "TrainingSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ClientId = table.Column<int>(type: "int", nullable: true),
                    PersonalTrainerId = table.Column<int>(type: "int", nullable: false),
                    GymId = table.Column<int>(type: "int", nullable: true),
                    ScheduledDateTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    Price = table.Column<float>(type: "real", nullable: true),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TrainerNotes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CancelledAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CancellationReason = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainingSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TrainingSessions_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TrainingSessions_PersonalTrainers_PersonalTrainerId",
                        column: x => x.PersonalTrainerId,
                        principalTable: "PersonalTrainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TrainingSessions_Users_ClientId",
                        column: x => x.ClientId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Meals",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NutritionPlanId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Calories = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Meals", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Meals_NutritionPlans_NutritionPlanId",
                        column: x => x.NutritionPlanId,
                        principalTable: "NutritionPlans",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PlanCostItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TrainingPlanId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Amount = table.Column<float>(type: "real", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlanCostItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PlanCostItems_TrainingPlans_TrainingPlanId",
                        column: x => x.TrainingPlanId,
                        principalTable: "TrainingPlans",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MealFoods",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MealId = table.Column<int>(type: "int", nullable: false),
                    FoodName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Quantity = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MealFoods", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MealFoods_Meals_MealId",
                        column: x => x.MealId,
                        principalTable: "Meals",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Equipments",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Barbell" },
                    { 2, "Dumbbell" },
                    { 3, "Pull-up Bar" },
                    { 4, "Resistance Band" },
                    { 5, "Treadmill" }
                });

            migrationBuilder.InsertData(
                table: "Images",
                columns: new[] { "Id", "IsHeader", "Name", "Size", "Url", "UserId" },
                values: new object[,]
                {
                    { 1, true, "Ahmet Profile", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/users/1/9e3e8fe361ec4270962aea28b798f5e3-Sample_User_Icon.png", null },
                    { 2, true, "Arena1", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/031c3d0740664e38b58800302259c3ef-arena.jpg", null },
                    { 3, true, "Arena2", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/498dbeb0028f46f7928417bda2be856d-arena2.png", null },
                    { 4, true, "pull-up", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/045cfc4432704dff8b23ee0bd602aa09-pull up bar.png", null },
                    { 5, true, "bench-press", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/b9921a30b8864d3b87b8329883ef4b54-benchh.jpg", null },
                    { 6, true, "row", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/row.jpeg", null },
                    { 7, true, "squat", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/squat.jpg", null },
                    { 8, true, "deadlift", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/deadlift.jpg", null },
                    { 9, true, "curl1", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/curl1.jpeg", null },
                    { 10, true, "treadmill", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/treadmill.jpeg", null },
                    { 11, true, "lateral-raise", 204800L, "https://cloudfordiversclub.blob.core.windows.net/takmicenja/general/lateral-raise.jpeg", null }
                });

            migrationBuilder.InsertData(
                table: "MuscleGroups",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Chest" },
                    { 2, "Back" },
                    { 3, "Shoulders" },
                    { 4, "Legs" },
                    { 5, "Arms" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8438), "Administrator", true, "Administrator" },
                    { 2, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8440), "Korisnik - kupac", true, "Kupac" },
                    { 3, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8441), "Super Administrator sa svim privilegijama", true, "SuperAdmin" }
                });

            migrationBuilder.InsertData(
                table: "Exercises",
                columns: new[] { "Id", "EquipmentId", "ImageId", "Name" },
                values: new object[,]
                {
                    { 1, 1, 5, "Bench Press" },
                    { 2, 1, 8, "Deadlift" },
                    { 3, 2, 9, "Dumbbell Curl" },
                    { 4, 3, 4, "Pull-up" },
                    { 5, 1, 7, "Barbell Squat" },
                    { 6, 1, 6, "Barbell Row" },
                    { 7, 5, 10, "Treadmill Run" },
                    { 8, 2, 11, "Lateral Raise" }
                });

            migrationBuilder.InsertData(
                table: "Gyms",
                columns: new[] { "Id", "Address", "City", "Country", "Email", "ImageId", "Name", "PhoneNumber", "WorkTime" },
                values: new object[,]
                {
                    { 1, "123 Main Street", "New York", "USA", "contact@fitlifegym.com", 2, "FitLife Gym", "+387 62 111 111", "Mon-Fri: 6am-10pm, Sat-Sun: 8am-6pm" },
                    { 2, "45 Oak Avenue", "London", "UK", "info@powerzone.co.uk", 3, "PowerZone Fitness", "+387 62 111 112", "Mon-Sun: 7am-11pm" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "BanExpiresAt", "BanReason", "CreatedAt", "DeletedAt", "DeletedBy", "Email", "FirstName", "IsActive", "IsBanned", "IsDeleted", "LastLoginAt", "LastName", "PasswordHash", "PasswordSalt", "PhoneNumber", "ProfileImageId", "ResetCode", "ResetCodeExpiry", "Username" },
                values: new object[,]
                {
                    { 1, null, null, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8868), null, null, "ahmet.stupac@edu.fit.ba", "Ahmet", true, null, false, null, "Stupac", "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", "Qeunp0McejKht6Qx9PW6ug==", null, 1, null, null, "superadmin" },
                    { 2, null, null, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8872), null, null, "adil@edu.fit.ba", "Denis", true, null, false, null, "Music", "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", "Qeunp0McejKht6Qx9PW6ug==", null, 1, null, null, "desktop" },
                    { 3, null, null, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8874), null, null, "ahmet2.stupac@edu.fit.ba", "Ismail", true, null, false, null, "Catic", "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", "Qeunp0McejKht6Qx9PW6ug==", null, 1, null, null, "trener2" },
                    { 4, null, null, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8876), null, null, "ahmet3.stupac@edu.fit.ba", "Alem", true, null, false, null, "Stupac", "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", "Qeunp0McejKht6Qx9PW6ug==", null, 1, null, null, "trener3" },
                    { 5, null, null, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8879), null, null, "ahmet4.stupac@edu.fit.ba", "Adil", true, null, false, null, "Joldic", "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", "Qeunp0McejKht6Qx9PW6ug==", null, 1, null, null, "trener4" },
                    { 6, null, null, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8881), null, null, "ahmet5.stupac@edu.fit.ba", "Amel", true, null, false, null, "Music", "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", "Qeunp0McejKht6Qx9PW6ug==", null, 1, null, null, "trener5" },
                    { 7, null, null, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8884), null, null, "ahmet6.stupac@edu.fit.ba", "Emina", true, null, false, null, "Junuz", "cnmepYg0B3XVzwr9POBGEWwEAzNGv+KuqebPm0/AvFk=", "Qeunp0McejKht6Qx9PW6ug==", null, 1, null, null, "mobile" }
                });

            migrationBuilder.InsertData(
                table: "ExerciseMuscleGroup",
                columns: new[] { "Id", "ExerciseId", "MuscleGroupId" },
                values: new object[,]
                {
                    { 1, 1, 1 },
                    { 2, 1, 3 },
                    { 3, 2, 2 },
                    { 4, 2, 4 },
                    { 5, 3, 5 },
                    { 6, 4, 2 },
                    { 7, 5, 4 },
                    { 8, 6, 2 },
                    { 9, 7, 4 },
                    { 10, 8, 3 }
                });

            migrationBuilder.InsertData(
                table: "GroupTrainingSessions",
                columns: new[] { "Id", "CreatedAt", "CreatorId", "DurationMinutes", "KcalBurned", "Name", "Notes", "Place", "TrainingType" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 1, 45, 450, "Morning Bootcamp", "Bring a mat and water bottle", "FitLife Gym - Studio A", "Bodyweight Training" },
                    { 2, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 1, 40, 350, "Sunset Run", null, "Central Park Trail", "Running" }
                });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "AmountInCents", "CreatedAt", "ItemId", "ItemType", "Status", "StripePaymentIntentId", "UserId" },
                values: new object[,]
                {
                    { 1, 4999, new DateTime(2026, 1, 16, 0, 0, 0, 0, DateTimeKind.Utc), 1, 0, "succeeded", "pi_test_3NpL4K2eZvKYlo2C0QJx7aBC", 2 },
                    { 2, 2999, new DateTime(2026, 1, 17, 0, 0, 0, 0, DateTimeKind.Utc), 1, 1, "succeeded", "pi_test_7MqQ8R5eZvKYlo2C1XPz9eFG", 2 }
                });

            migrationBuilder.InsertData(
                table: "PersonalTrainers",
                columns: new[] { "Id", "Certifications", "IsActive", "MyProperty", "Sport", "UserId", "YearsOfExperience" },
                values: new object[,]
                {
                    { 1, "NASM-CPT, CSCS", true, null, "Karate", 2, 8 },
                    { 2, "ACE-CPT", true, null, "Running", 3, 3 },
                    { 3, "ACE-CC", true, null, "Gym", 4, 4 },
                    { 4, "ACE-DPT", true, null, "Boxing", 5, 10 }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "Id", "DateAssigned", "RoleId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8912), 3, 1 },
                    { 2, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8913), 1, 2 },
                    { 4, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8915), 1, 3 },
                    { 5, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8916), 1, 4 },
                    { 6, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8918), 1, 5 },
                    { 7, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8919), 1, 6 },
                    { 8, new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8920), 2, 7 }
                });

            migrationBuilder.InsertData(
                table: "GroupTrainingSessionParticipants",
                columns: new[] { "Id", "GroupTrainingSessionId", "JoinedAt", "UserId" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { 2, 2, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 2 }
                });

            migrationBuilder.InsertData(
                table: "NutritionPlans",
                columns: new[] { "Id", "Carbs", "CreatedAt", "Description", "Fats", "PersonalTrainerId", "Price", "Protein", "Title", "TotalCalories", "UserId" },
                values: new object[,]
                {
                    { 1, "320g", new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "High-protein diet plan tailored for muscle building and recovery.", 80, 1, 29.99f, "220g", "Muscle Gain Diet", "3200", 2 },
                    { 2, "150g", new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Calorie-deficit diet designed for sustainable and healthy weight loss.", 60, 1, 24.99f, "160g", "Fat Loss Plan", "1800", null },
                    { 3, "380g", new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Carbohydrate-focused plan for endurance athletes and long-distance runners.", 55, 2, 19.99f, "140g", "Endurance Fueling", "2800", null }
                });

            migrationBuilder.InsertData(
                table: "PersonalTrainerRatings",
                columns: new[] { "Id", "Comment", "CreatedAt", "PersonalTrainerId", "Rating", "UpdatedAt", "UserId" },
                values: new object[,]
                {
                    { 1, "Excellent trainer! Very knowledgeable, motivating, and professional.", new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 1, 5, null, 2 },
                    { 2, "Great running coach. Helped me improve my pace and endurance significantly.", new DateTime(2026, 1, 22, 0, 0, 0, 0, DateTimeKind.Utc), 2, 4, null, 2 }
                });

            migrationBuilder.InsertData(
                table: "TrainingPlans",
                columns: new[] { "Id", "BasePrice", "CreatedAt", "Description", "PersonalTrainerId", "Title", "UserId" },
                values: new object[,]
                {
                    { 1, 49.99f, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "A 4-week program for building foundational strength using compound lifts.", 1, "Beginner Strength Program", 2 },
                    { 2, 79.99f, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "12-week muscle-building program designed for experienced lifters.", 1, "Advanced Hypertrophy", 2 },
                    { 3, 39.99f, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "High-intensity cardio program focused on fat loss and endurance.", 2, "Cardio Blast", null }
                });

            migrationBuilder.InsertData(
                table: "TrainingSessions",
                columns: new[] { "Id", "CancellationReason", "CancelledAt", "ClientId", "CreatedAt", "DurationMinutes", "GymId", "Notes", "PersonalTrainerId", "Price", "ScheduledDateTime", "Status", "TrainerNotes", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, null, null, 2, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 60, 1, "Please bring lifting gloves", 1, 50f, new DateTime(2026, 3, 10, 9, 0, 0, 0, DateTimeKind.Utc), 1, "Client needs focus on squat depth", null },
                    { 2, null, null, 2, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 60, 1, null, 1, 50f, new DateTime(2026, 3, 12, 10, 0, 0, 0, DateTimeKind.Utc), 0, null, null },
                    { 3, null, null, null, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 45, 2, "Open availability slot", 2, 40f, new DateTime(2026, 3, 15, 8, 0, 0, 0, DateTimeKind.Utc), 0, null, null }
                });

            migrationBuilder.InsertData(
                table: "Trainings",
                columns: new[] { "Id", "ClientId", "Description", "Duration", "Name", "PersonalTrainerId" },
                values: new object[,]
                {
                    { 1, 2, "One-on-one session focusing on compound lifts and proper technique.", 60, "Strength Foundation", 1 },
                    { 2, null, "Treadmill intervals and circuit training session for fat burn.", 45, "Cardio Conditioning", 2 },
                    { 3, 2, "Guided stretching, foam rolling, and mobility work.", 30, "Mobility & Recovery", 1 }
                });

            migrationBuilder.InsertData(
                table: "ExercisePlans",
                columns: new[] { "Id", "CustomPrice", "Duration", "ExerciseId", "Note", "Reps", "Sets", "TrainingPlanId" },
                values: new object[,]
                {
                    { 1, null, null, 1, "Focus on form and controlled movement", 10, 3, 1 },
                    { 2, null, null, 5, "Keep back straight, knees tracking over toes", 12, 3, 1 },
                    { 3, null, null, 4, "Use assisted machine if full pull-ups are too difficult", 8, 3, 1 },
                    { 4, null, null, 2, "Progressive overload - increase weight each week", 5, 5, 2 },
                    { 5, null, null, 1, "Drop set on the last set", 8, 4, 2 },
                    { 6, null, 30, 7, "Maintain 70-80% of maximum heart rate", null, null, 3 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Connections_GroupName",
                table: "Connections",
                column: "GroupName");

            migrationBuilder.CreateIndex(
                name: "IX_ExerciseMuscleGroup_ExerciseId",
                table: "ExerciseMuscleGroup",
                column: "ExerciseId");

            migrationBuilder.CreateIndex(
                name: "IX_ExerciseMuscleGroup_MuscleGroupId",
                table: "ExerciseMuscleGroup",
                column: "MuscleGroupId");

            migrationBuilder.CreateIndex(
                name: "IX_ExercisePlans_ExerciseId",
                table: "ExercisePlans",
                column: "ExerciseId");

            migrationBuilder.CreateIndex(
                name: "IX_ExercisePlans_TrainingPlanId",
                table: "ExercisePlans",
                column: "TrainingPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_Exercises_EquipmentId",
                table: "Exercises",
                column: "EquipmentId");

            migrationBuilder.CreateIndex(
                name: "IX_Exercises_ImageId",
                table: "Exercises",
                column: "ImageId");

            migrationBuilder.CreateIndex(
                name: "IX_GroupTrainingSessionParticipants_GroupTrainingSessionId_UserId",
                table: "GroupTrainingSessionParticipants",
                columns: new[] { "GroupTrainingSessionId", "UserId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_GroupTrainingSessionParticipants_UserId",
                table: "GroupTrainingSessionParticipants",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_GroupTrainingSessions_CreatorId",
                table: "GroupTrainingSessions",
                column: "CreatorId");

            migrationBuilder.CreateIndex(
                name: "IX_Gyms_ImageId",
                table: "Gyms",
                column: "ImageId");

            migrationBuilder.CreateIndex(
                name: "IX_Images_UserId",
                table: "Images",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_MealFoods_MealId",
                table: "MealFoods",
                column: "MealId");

            migrationBuilder.CreateIndex(
                name: "IX_Meals_NutritionPlanId",
                table: "Meals",
                column: "NutritionPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_RecipientId",
                table: "Messages",
                column: "RecipientId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_SenderId",
                table: "Messages",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_MonthlyTrainingStatistics_UserId_Year_Month",
                table: "MonthlyTrainingStatistics",
                columns: new[] { "UserId", "Year", "Month" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_NutritionPlans_PersonalTrainerId",
                table: "NutritionPlans",
                column: "PersonalTrainerId");

            migrationBuilder.CreateIndex(
                name: "IX_NutritionPlans_UserId",
                table: "NutritionPlans",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_UserId",
                table: "Payments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PersonalTrainerRatings_PersonalTrainerId",
                table: "PersonalTrainerRatings",
                column: "PersonalTrainerId");

            migrationBuilder.CreateIndex(
                name: "IX_PersonalTrainerRatings_UserId",
                table: "PersonalTrainerRatings",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PersonalTrainers_UserId",
                table: "PersonalTrainers",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PlanCostItems_TrainingPlanId",
                table: "PlanCostItems",
                column: "TrainingPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Name",
                table: "Roles",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TrainingPlans_PersonalTrainerId",
                table: "TrainingPlans",
                column: "PersonalTrainerId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingPlans_UserId",
                table: "TrainingPlans",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Trainings_ClientId",
                table: "Trainings",
                column: "ClientId");

            migrationBuilder.CreateIndex(
                name: "IX_Trainings_PersonalTrainerId",
                table: "Trainings",
                column: "PersonalTrainerId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_ClientId",
                table: "TrainingSessions",
                column: "ClientId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_GymId",
                table: "TrainingSessions",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_PersonalTrainerId",
                table: "TrainingSessions",
                column: "PersonalTrainerId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleId",
                table: "UserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_UserId_RoleId",
                table: "UserRoles",
                columns: new[] { "UserId", "RoleId" },
                unique: true,
                filter: "[UserId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_ProfileImageId",
                table: "Users",
                column: "ProfileImageId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Username",
                table: "Users",
                column: "Username",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_ExerciseMuscleGroup_Exercises_ExerciseId",
                table: "ExerciseMuscleGroup",
                column: "ExerciseId",
                principalTable: "Exercises",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ExercisePlans_Exercises_ExerciseId",
                table: "ExercisePlans",
                column: "ExerciseId",
                principalTable: "Exercises",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ExercisePlans_TrainingPlans_TrainingPlanId",
                table: "ExercisePlans",
                column: "TrainingPlanId",
                principalTable: "TrainingPlans",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Exercises_Images_ImageId",
                table: "Exercises",
                column: "ImageId",
                principalTable: "Images",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_GroupTrainingSessionParticipants_GroupTrainingSessions_GroupTrainingSessionId",
                table: "GroupTrainingSessionParticipants",
                column: "GroupTrainingSessionId",
                principalTable: "GroupTrainingSessions",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_GroupTrainingSessionParticipants_Users_UserId",
                table: "GroupTrainingSessionParticipants",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_GroupTrainingSessions_Users_CreatorId",
                table: "GroupTrainingSessions",
                column: "CreatorId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Gyms_Images_ImageId",
                table: "Gyms",
                column: "ImageId",
                principalTable: "Images",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Images_Users_UserId",
                table: "Images",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Images_ProfileImageId",
                table: "Users");

            migrationBuilder.DropTable(
                name: "Connections");

            migrationBuilder.DropTable(
                name: "ExerciseMuscleGroup");

            migrationBuilder.DropTable(
                name: "ExercisePlans");

            migrationBuilder.DropTable(
                name: "GroupTrainingSessionParticipants");

            migrationBuilder.DropTable(
                name: "MealFoods");

            migrationBuilder.DropTable(
                name: "Messages");

            migrationBuilder.DropTable(
                name: "MonthlyTrainingStatistics");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "PersonalTrainerRatings");

            migrationBuilder.DropTable(
                name: "PlanCostItems");

            migrationBuilder.DropTable(
                name: "Trainings");

            migrationBuilder.DropTable(
                name: "TrainingSessions");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "Groups");

            migrationBuilder.DropTable(
                name: "MuscleGroups");

            migrationBuilder.DropTable(
                name: "Exercises");

            migrationBuilder.DropTable(
                name: "GroupTrainingSessions");

            migrationBuilder.DropTable(
                name: "Meals");

            migrationBuilder.DropTable(
                name: "TrainingPlans");

            migrationBuilder.DropTable(
                name: "Gyms");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "Equipments");

            migrationBuilder.DropTable(
                name: "NutritionPlans");

            migrationBuilder.DropTable(
                name: "PersonalTrainers");

            migrationBuilder.DropTable(
                name: "Images");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
