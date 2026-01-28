using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddSoftDeleteToUsers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DeletedBy",
                table: "Users",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "Users",
                type: "bit",
                nullable: false,
                defaultValue: false);

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
                columns: new[] { "CreatedAt", "DeletedAt", "DeletedBy", "IsDeleted" },
                values: new object[] { new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7960), null, null, false });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "DeletedAt", "DeletedBy", "IsDeleted" },
                values: new object[] { new DateTime(2026, 1, 27, 21, 56, 9, 889, DateTimeKind.Utc).AddTicks(7963), null, null, false });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeletedBy",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "Users");

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

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5135));

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
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 1, 27, 15, 59, 21, 534, DateTimeKind.Utc).AddTicks(5508));

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
        }
    }
}
