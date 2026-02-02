using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class changedEntityPTrainer : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_NutritionPlans_PersonalTrainers_TrainerId",
                table: "NutritionPlans");

            migrationBuilder.RenameColumn(
                name: "TrainerId",
                table: "NutritionPlans",
                newName: "PersonalTrainerId");

            migrationBuilder.RenameIndex(
                name: "IX_NutritionPlans_TrainerId",
                table: "NutritionPlans",
                newName: "IX_NutritionPlans_PersonalTrainerId");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 18, 56, 5, 656, DateTimeKind.Utc).AddTicks(6235));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 18, 56, 5, 656, DateTimeKind.Utc).AddTicks(6238));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 18, 56, 5, 656, DateTimeKind.Utc).AddTicks(6239));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 2, 18, 56, 5, 656, DateTimeKind.Utc).AddTicks(6353));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 2, 18, 56, 5, 656, DateTimeKind.Utc).AddTicks(6354));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 2, 18, 56, 5, 656, DateTimeKind.Utc).AddTicks(6355));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 18, 56, 5, 656, DateTimeKind.Utc).AddTicks(6381));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 18, 56, 5, 656, DateTimeKind.Utc).AddTicks(6383));

            migrationBuilder.AddForeignKey(
                name: "FK_NutritionPlans_PersonalTrainers_PersonalTrainerId",
                table: "NutritionPlans",
                column: "PersonalTrainerId",
                principalTable: "PersonalTrainers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_NutritionPlans_PersonalTrainers_PersonalTrainerId",
                table: "NutritionPlans");

            migrationBuilder.RenameColumn(
                name: "PersonalTrainerId",
                table: "NutritionPlans",
                newName: "TrainerId");

            migrationBuilder.RenameIndex(
                name: "IX_NutritionPlans_PersonalTrainerId",
                table: "NutritionPlans",
                newName: "IX_NutritionPlans_TrainerId");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 1, 15, 54, 33, 840, DateTimeKind.Utc).AddTicks(3530));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 1, 15, 54, 33, 840, DateTimeKind.Utc).AddTicks(3532));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 1, 15, 54, 33, 840, DateTimeKind.Utc).AddTicks(3533));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 1, 15, 54, 33, 840, DateTimeKind.Utc).AddTicks(3635));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 1, 15, 54, 33, 840, DateTimeKind.Utc).AddTicks(3636));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 1, 15, 54, 33, 840, DateTimeKind.Utc).AddTicks(3638));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 1, 15, 54, 33, 840, DateTimeKind.Utc).AddTicks(3657));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 1, 15, 54, 33, 840, DateTimeKind.Utc).AddTicks(3659));

            migrationBuilder.AddForeignKey(
                name: "FK_NutritionPlans_PersonalTrainers_TrainerId",
                table: "NutritionPlans",
                column: "TrainerId",
                principalTable: "PersonalTrainers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
