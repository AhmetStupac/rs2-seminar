using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class removedMyPropertyFRomPT : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MyProperty",
                table: "PersonalTrainers");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(227));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(229));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(231));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(434));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(436));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(437));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(439));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(440));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(441));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(442));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(388));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(391));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(393));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(396));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(398));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(400));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 4, 21, 20, 35, 596, DateTimeKind.Utc).AddTicks(402));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "MyProperty",
                table: "PersonalTrainers",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 1,
                column: "MyProperty",
                value: null);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 2,
                column: "MyProperty",
                value: null);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 3,
                column: "MyProperty",
                value: null);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 4,
                column: "MyProperty",
                value: null);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8438));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8440));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8441));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8912));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8913));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8915));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8916));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8918));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8919));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8920));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8868));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8872));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8874));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8876));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8879));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8881));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 0, 27, 13, 303, DateTimeKind.Utc).AddTicks(8884));
        }
    }
}
