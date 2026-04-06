using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class addedGenderToPT : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Gender",
                table: "PersonalTrainers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 1,
                column: "Gender",
                value: null);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 2,
                column: "Gender",
                value: null);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 3,
                column: "Gender",
                value: null);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 4,
                column: "Gender",
                value: null);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1689));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1691));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1693));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1908));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1909));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1911));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1912));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1913));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1914));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1915));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1866));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1869));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1871));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1874));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1876));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1878));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 5, 15, 29, 16, 530, DateTimeKind.Utc).AddTicks(1880));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Gender",
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
    }
}
