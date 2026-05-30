using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddUserPurchasedPlans : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "UserPurchasedNutritionPlans",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    PaymentId = table.Column<int>(type: "int", nullable: false),
                    NutritionPlanId = table.Column<int>(type: "int", nullable: false),
                    BoughtAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserPurchasedNutritionPlans", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserPurchasedNutritionPlans_NutritionPlans_NutritionPlanId",
                        column: x => x.NutritionPlanId,
                        principalTable: "NutritionPlans",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserPurchasedNutritionPlans_Payments_PaymentId",
                        column: x => x.PaymentId,
                        principalTable: "Payments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserPurchasedNutritionPlans_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UserPurchasedTrainingPlans",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    PaymentId = table.Column<int>(type: "int", nullable: false),
                    TrainingPlanId = table.Column<int>(type: "int", nullable: false),
                    BoughtAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserPurchasedTrainingPlans", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserPurchasedTrainingPlans_Payments_PaymentId",
                        column: x => x.PaymentId,
                        principalTable: "Payments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserPurchasedTrainingPlans_TrainingPlans_TrainingPlanId",
                        column: x => x.TrainingPlanId,
                        principalTable: "TrainingPlans",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserPurchasedTrainingPlans_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 32, DateTimeKind.Utc).AddTicks(9758));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 32, DateTimeKind.Utc).AddTicks(9760));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 32, DateTimeKind.Utc).AddTicks(9762));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(239));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(241));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(242));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(244));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(246));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(247));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(249));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(163));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(166));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(169));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(175));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(177));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(180));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 14, 44, 34, 33, DateTimeKind.Utc).AddTicks(182));

            migrationBuilder.CreateIndex(
                name: "IX_UserPurchasedNutritionPlans_NutritionPlanId",
                table: "UserPurchasedNutritionPlans",
                column: "NutritionPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_UserPurchasedNutritionPlans_PaymentId",
                table: "UserPurchasedNutritionPlans",
                column: "PaymentId");

            migrationBuilder.CreateIndex(
                name: "IX_UserPurchasedNutritionPlans_UserId_NutritionPlanId",
                table: "UserPurchasedNutritionPlans",
                columns: new[] { "UserId", "NutritionPlanId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserPurchasedTrainingPlans_PaymentId",
                table: "UserPurchasedTrainingPlans",
                column: "PaymentId");

            migrationBuilder.CreateIndex(
                name: "IX_UserPurchasedTrainingPlans_TrainingPlanId",
                table: "UserPurchasedTrainingPlans",
                column: "TrainingPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_UserPurchasedTrainingPlans_UserId_TrainingPlanId",
                table: "UserPurchasedTrainingPlans",
                columns: new[] { "UserId", "TrainingPlanId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserPurchasedNutritionPlans");

            migrationBuilder.DropTable(
                name: "UserPurchasedTrainingPlans");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3126));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3128));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3130));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3641));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3642));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3644));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3646));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3647));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3649));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3650));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3584));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3587));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3589));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3592));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3594));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3598));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 18, 11, 6, 288, DateTimeKind.Utc).AddTicks(3601));
        }
    }
}
