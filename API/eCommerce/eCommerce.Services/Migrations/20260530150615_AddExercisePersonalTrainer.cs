using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddExercisePersonalTrainer : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PersonalTrainerId",
                table: "Exercises",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 1,
                column: "PersonalTrainerId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 2,
                column: "PersonalTrainerId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 3,
                column: "PersonalTrainerId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 4,
                column: "PersonalTrainerId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 5,
                column: "PersonalTrainerId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 6,
                column: "PersonalTrainerId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 7,
                column: "PersonalTrainerId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 8,
                column: "PersonalTrainerId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(2972));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(2973));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(2975));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3279));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3280));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3281));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3283));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3284));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3285));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3286));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3233));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3236));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3238));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3240));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3242));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3243));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 30, 15, 6, 14, 870, DateTimeKind.Utc).AddTicks(3245));

            migrationBuilder.CreateIndex(
                name: "IX_Exercises_PersonalTrainerId",
                table: "Exercises",
                column: "PersonalTrainerId");

            migrationBuilder.AddForeignKey(
                name: "FK_Exercises_PersonalTrainers_PersonalTrainerId",
                table: "Exercises",
                column: "PersonalTrainerId",
                principalTable: "PersonalTrainers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Exercises_PersonalTrainers_PersonalTrainerId",
                table: "Exercises");

            migrationBuilder.DropIndex(
                name: "IX_Exercises_PersonalTrainerId",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "PersonalTrainerId",
                table: "Exercises");

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
        }
    }
}
