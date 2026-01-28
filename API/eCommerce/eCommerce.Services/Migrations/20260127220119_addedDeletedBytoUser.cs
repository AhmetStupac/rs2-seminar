using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class addedDeletedBytoUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 22, 1, 18, 877, DateTimeKind.Utc).AddTicks(3840));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 22, 1, 18, 877, DateTimeKind.Utc).AddTicks(3843));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 22, 1, 18, 877, DateTimeKind.Utc).AddTicks(3845));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 22, 1, 18, 877, DateTimeKind.Utc).AddTicks(4138));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 22, 1, 18, 877, DateTimeKind.Utc).AddTicks(4140));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 22, 1, 18, 877, DateTimeKind.Utc).AddTicks(4142));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 22, 1, 18, 877, DateTimeKind.Utc).AddTicks(4173));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 22, 1, 18, 877, DateTimeKind.Utc).AddTicks(4177));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7749));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7751));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7752));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7937));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7939));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7940));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7960));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7963));
        }
    }
}
