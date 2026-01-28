using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddSuperAdminRole : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5126));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5130));

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[] { 3, new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5135), "Super Administrator sa svim privilegijama", true, "SuperAdmin" });

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5501));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5505));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5568));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5574));

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "Id", "DateAssigned", "RoleId", "UserId" },
                values: new object[] { 3, new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5508), 3, 1 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 15, 56, 5, 745, DateTimeKind.Utc).AddTicks(432));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 15, 56, 5, 745, DateTimeKind.Utc).AddTicks(433));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 26, 15, 56, 5, 745, DateTimeKind.Utc).AddTicks(585));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 26, 15, 56, 5, 745, DateTimeKind.Utc).AddTicks(586));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 15, 56, 5, 745, DateTimeKind.Utc).AddTicks(700));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 15, 56, 5, 745, DateTimeKind.Utc).AddTicks(702));
        }
    }
}
