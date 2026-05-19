using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class RemoveMealMealFoodPlanCostItem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MealFoods");

            migrationBuilder.DropTable(
                name: "PlanCostItems");

            migrationBuilder.DropTable(
                name: "Meals");

            migrationBuilder.AddColumn<DateTime>(
                name: "ApprovedAt",
                table: "TrainingSessions",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ApprovedByUserId",
                table: "TrainingSessions",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CancelledByUserId",
                table: "TrainingSessions",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7735));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7736));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7738));

            migrationBuilder.UpdateData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "ApprovedAt", "ApprovedByUserId", "CancelledByUserId" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "ApprovedAt", "ApprovedByUserId", "CancelledByUserId" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "ApprovedAt", "ApprovedByUserId", "CancelledByUserId" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7910));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7913));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7914));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7922));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7924));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7925));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7927));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7872));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7874));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7876));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7878));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7881));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7883));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7885));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ApprovedAt",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "ApprovedByUserId",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "CancelledByUserId",
                table: "TrainingSessions");

            migrationBuilder.CreateTable(
                name: "Meals",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NutritionPlanId = table.Column<int>(type: "int", nullable: false),
                    Calories = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
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
                    Amount = table.Column<float>(type: "real", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
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

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(199));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(201));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(203));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(440));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(442));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(444));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(445));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(446));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(447));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(448));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(346));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(349));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(351));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(353));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(355));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(357));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 30, 13, 46, 15, 574, DateTimeKind.Utc).AddTicks(359));

            migrationBuilder.CreateIndex(
                name: "IX_MealFoods_MealId",
                table: "MealFoods",
                column: "MealId");

            migrationBuilder.CreateIndex(
                name: "IX_Meals_NutritionPlanId",
                table: "Meals",
                column: "NutritionPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_PlanCostItems_TrainingPlanId",
                table: "PlanCostItems",
                column: "TrainingPlanId");
        }
    }
}
