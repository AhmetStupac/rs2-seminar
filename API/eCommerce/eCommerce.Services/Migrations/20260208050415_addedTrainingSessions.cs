using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class addedTrainingSessions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TrainingSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ClientId = table.Column<int>(type: "int", nullable: true),
                    PersonalTrainerId = table.Column<int>(type: "int", nullable: false),
                    GymId = table.Column<int>(type: "int", nullable: true),
                    ScheduledDateTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TrainerNotes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CancelledAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CancellationReason = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainingSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TrainingSessions_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TrainingSessions_PersonalTrainers_PersonalTrainerId",
                        column: x => x.PersonalTrainerId,
                        principalTable: "PersonalTrainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TrainingSessions_Users_ClientId",
                        column: x => x.ClientId,
                        principalTable: "Users",
                        principalColumn: "Id");
                });

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

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_ClientId",
                table: "TrainingSessions",
                column: "ClientId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_GymId",
                table: "TrainingSessions",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_PersonalTrainerId",
                table: "TrainingSessions",
                column: "PersonalTrainerId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TrainingSessions");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 3, 15, 39, 43, 83, DateTimeKind.Utc).AddTicks(7368));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 3, 15, 39, 43, 83, DateTimeKind.Utc).AddTicks(7370));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 3, 15, 39, 43, 83, DateTimeKind.Utc).AddTicks(7372));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 3, 15, 39, 43, 83, DateTimeKind.Utc).AddTicks(7504));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 3, 15, 39, 43, 83, DateTimeKind.Utc).AddTicks(7506));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 3,
                column: "DateAssigned",
                value: new DateTime(2026, 2, 3, 15, 39, 43, 83, DateTimeKind.Utc).AddTicks(7507));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 3, 15, 39, 43, 83, DateTimeKind.Utc).AddTicks(7532));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 3, 15, 39, 43, 83, DateTimeKind.Utc).AddTicks(7535));
        }
    }
}
