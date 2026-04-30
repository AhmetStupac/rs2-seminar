using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddNotificationsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Message = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Type = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsRead = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ReadAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Notifications_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 1,
                column: "Gender",
                value: "Male");

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 2,
                column: "Gender",
                value: "Male");

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 3,
                column: "Gender",
                value: "Female");

            migrationBuilder.UpdateData(
                table: "PersonalTrainers",
                keyColumn: "Id",
                keyValue: 4,
                column: "Gender",
                value: "Male");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5445));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5447));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5449));

            migrationBuilder.InsertData(
                table: "TrainingPlans",
                columns: new[] { "Id", "BasePrice", "CreatedAt", "Description", "PersonalTrainerId", "Title", "UserId" },
                values: new object[,]
                {
                    { 4, 59.99f, new DateTime(2026, 1, 16, 0, 0, 0, 0, DateTimeKind.Utc), "Focused upper body strength and hypertrophy plan for intermediate clients.", 3, "Upper Body Builder", null },
                    { 5, 69.99f, new DateTime(2026, 1, 17, 0, 0, 0, 0, DateTimeKind.Utc), "Conditioning plan for boxing stamina, core stability, and footwork.", 4, "Boxing Conditioning", null }
                });

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5634));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5636));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5637));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5639));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5640));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5641));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5642));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5592));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5595));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5598));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5600));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5602));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5603));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 29, 23, 44, 47, 316, DateTimeKind.Utc).AddTicks(5605));

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_UserId",
                table: "Notifications",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DeleteData(
                table: "TrainingPlans",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "TrainingPlans",
                keyColumn: "Id",
                keyValue: 5);

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
    }
}
