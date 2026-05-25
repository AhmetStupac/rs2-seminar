using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddTrainingSessionCompleteNoShowAudit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAt",
                table: "TrainingSessions",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CompletedByUserId",
                table: "TrainingSessions",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "NoShowAt",
                table: "TrainingSessions",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "NoShowByUserId",
                table: "TrainingSessions",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(67));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(70));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(72));

            migrationBuilder.UpdateData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CompletedAt", "CompletedByUserId", "NoShowAt", "NoShowByUserId" },
                values: new object[] { null, null, null, null });

            migrationBuilder.UpdateData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CompletedAt", "CompletedByUserId", "NoShowAt", "NoShowByUserId" },
                values: new object[] { null, null, null, null });

            migrationBuilder.UpdateData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CompletedAt", "CompletedByUserId", "NoShowAt", "NoShowByUserId" },
                values: new object[] { null, null, null, null });

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(457));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(458));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(459));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(461));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(462));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(463));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(464));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(408));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(412));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(415));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(417));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(419));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(421));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 25, 12, 16, 5, 623, DateTimeKind.Utc).AddTicks(423));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CompletedAt",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "CompletedByUserId",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "NoShowAt",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "NoShowByUserId",
                table: "TrainingSessions");

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
    }
}
