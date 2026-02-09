using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class addedPriceToTrainingSession : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<float>(
                name: "Price",
                table: "TrainingSessions",
                type: "real",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 9, 9, 39, 25, 574, DateTimeKind.Utc).AddTicks(1162));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 9, 9, 39, 25, 574, DateTimeKind.Utc).AddTicks(1165));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 9, 9, 39, 25, 574, DateTimeKind.Utc).AddTicks(1167));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 9, 9, 39, 25, 574, DateTimeKind.Utc).AddTicks(1262));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 9, 9, 39, 25, 574, DateTimeKind.Utc).AddTicks(1263));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 9, 9, 39, 25, 574, DateTimeKind.Utc).AddTicks(1265));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 9, 9, 39, 25, 574, DateTimeKind.Utc).AddTicks(1293));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 9, 9, 39, 25, 574, DateTimeKind.Utc).AddTicks(1296));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Price",
                table: "TrainingSessions");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 8, 5, 4, 15, 307, DateTimeKind.Utc).AddTicks(3302));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 8, 5, 4, 15, 307, DateTimeKind.Utc).AddTicks(3304));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 8, 5, 4, 15, 307, DateTimeKind.Utc).AddTicks(3305));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 8, 5, 4, 15, 307, DateTimeKind.Utc).AddTicks(3419));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 8, 5, 4, 15, 307, DateTimeKind.Utc).AddTicks(3420));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 8, 5, 4, 15, 307, DateTimeKind.Utc).AddTicks(3421));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 8, 5, 4, 15, 307, DateTimeKind.Utc).AddTicks(3456));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 8, 5, 4, 15, 307, DateTimeKind.Utc).AddTicks(3458));
        }
    }
}
