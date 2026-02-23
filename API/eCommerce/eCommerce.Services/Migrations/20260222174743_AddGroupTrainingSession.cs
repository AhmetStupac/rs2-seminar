using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddGroupTrainingSession : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "GroupTrainingSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    TrainingType = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    KcalBurned = table.Column<int>(type: "int", nullable: false),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    Place = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatorId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GroupTrainingSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GroupTrainingSessions_Users_CreatorId",
                        column: x => x.CreatorId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "GroupTrainingSessionParticipants",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    GroupTrainingSessionId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    JoinedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GroupTrainingSessionParticipants", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GroupTrainingSessionParticipants_GroupTrainingSessions_GroupTrainingSessionId",
                        column: x => x.GroupTrainingSessionId,
                        principalTable: "GroupTrainingSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_GroupTrainingSessionParticipants_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 22, 17, 47, 43, 267, DateTimeKind.Utc).AddTicks(7550));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 22, 17, 47, 43, 267, DateTimeKind.Utc).AddTicks(7553));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 22, 17, 47, 43, 267, DateTimeKind.Utc).AddTicks(7554));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 22, 17, 47, 43, 267, DateTimeKind.Utc).AddTicks(7863));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 22, 17, 47, 43, 267, DateTimeKind.Utc).AddTicks(7864));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 22, 17, 47, 43, 267, DateTimeKind.Utc).AddTicks(7866));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 22, 17, 47, 43, 267, DateTimeKind.Utc).AddTicks(7893));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 22, 17, 47, 43, 267, DateTimeKind.Utc).AddTicks(7896));

            migrationBuilder.CreateIndex(
                name: "IX_GroupTrainingSessionParticipants_GroupTrainingSessionId_UserId",
                table: "GroupTrainingSessionParticipants",
                columns: new[] { "GroupTrainingSessionId", "UserId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_GroupTrainingSessionParticipants_UserId",
                table: "GroupTrainingSessionParticipants",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_GroupTrainingSessions_CreatorId",
                table: "GroupTrainingSessions",
                column: "CreatorId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "GroupTrainingSessionParticipants");

            migrationBuilder.DropTable(
                name: "GroupTrainingSessions");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 21, 21, 25, 18, 818, DateTimeKind.Utc).AddTicks(7820));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 21, 21, 25, 18, 818, DateTimeKind.Utc).AddTicks(7824));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 21, 21, 25, 18, 818, DateTimeKind.Utc).AddTicks(7826));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 21, 21, 25, 18, 818, DateTimeKind.Utc).AddTicks(7995));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 21, 21, 25, 18, 818, DateTimeKind.Utc).AddTicks(7997));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 21, 21, 25, 18, 818, DateTimeKind.Utc).AddTicks(7998));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 21, 21, 25, 18, 818, DateTimeKind.Utc).AddTicks(8034));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 21, 21, 25, 18, 818, DateTimeKind.Utc).AddTicks(8037));
        }
    }
}
