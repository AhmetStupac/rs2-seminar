using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class addProfileImageToUserEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Images_Users_UserId",
                table: "Images");

            migrationBuilder.DropIndex(
                name: "IX_Images_UserId",
                table: "Images");

            migrationBuilder.AddColumn<int>(
                name: "ProfileImageId",
                table: "Users",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 16, 20, 52, 34, 915, DateTimeKind.Utc).AddTicks(4298));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 16, 20, 52, 34, 915, DateTimeKind.Utc).AddTicks(4300));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 16, 20, 52, 34, 915, DateTimeKind.Utc).AddTicks(4301));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 16, 20, 52, 34, 915, DateTimeKind.Utc).AddTicks(4445));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 16, 20, 52, 34, 915, DateTimeKind.Utc).AddTicks(4447));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 16, 20, 52, 34, 915, DateTimeKind.Utc).AddTicks(4448));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "ProfileImageId" },
                values: new object[] { new DateTime(2026, 2, 16, 20, 52, 34, 915, DateTimeKind.Utc).AddTicks(4467), null });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "ProfileImageId" },
                values: new object[] { new DateTime(2026, 2, 16, 20, 52, 34, 915, DateTimeKind.Utc).AddTicks(4468), null });

            migrationBuilder.CreateIndex(
                name: "IX_Users_ProfileImageId",
                table: "Users",
                column: "ProfileImageId",
                unique: true,
                filter: "[ProfileImageId] IS NOT NULL");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Images_ProfileImageId",
                table: "Users",
                column: "ProfileImageId",
                principalTable: "Images",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Images_ProfileImageId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_ProfileImageId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "ProfileImageId",
                table: "Users");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 16, 19, 5, 15, 811, DateTimeKind.Utc).AddTicks(980));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 16, 19, 5, 15, 811, DateTimeKind.Utc).AddTicks(981));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 16, 19, 5, 15, 811, DateTimeKind.Utc).AddTicks(983));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 16, 19, 5, 15, 811, DateTimeKind.Utc).AddTicks(1069));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 16, 19, 5, 15, 811, DateTimeKind.Utc).AddTicks(1071));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 16, 19, 5, 15, 811, DateTimeKind.Utc).AddTicks(1072));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 16, 19, 5, 15, 811, DateTimeKind.Utc).AddTicks(1091));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 16, 19, 5, 15, 811, DateTimeKind.Utc).AddTicks(1093));

            migrationBuilder.CreateIndex(
                name: "IX_Images_UserId",
                table: "Images",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Images_Users_UserId",
                table: "Images",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id");
        }
    }
}
