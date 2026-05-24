using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddPersonalTrainerMembershipPrice : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<float>(
                name: "MembershipPrice",
                table: "PersonalTrainers",
                type: "real",
                nullable: false,
                defaultValue: 50f);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 1,
                column: "MembershipPrice",
                value: 50f);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 2,
                column: "MembershipPrice",
                value: 45f);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 3,
                column: "MembershipPrice",
                value: 40f);

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 4,
                column: "MembershipPrice",
                value: 55f);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(111));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(114));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(116));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(471));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(472));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(473));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(474));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(478));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(479));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(481));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(425));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(427));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(430));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(431));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(433));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(435));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 24, 14, 30, 45, 663, DateTimeKind.Utc).AddTicks(437));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MembershipPrice",
                table: "PersonalTrainers");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1439));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1440));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1442));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1731));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1732));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1733));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1740));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1741));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1742));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1744));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1688));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1692));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1694));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1696));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1698));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1701));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 17, 11, 39, 25, 533, DateTimeKind.Utc).AddTicks(1703));
        }
    }
}
