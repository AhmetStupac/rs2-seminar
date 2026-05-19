using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace eCommerce.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddCityCountryRefactorGym : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "City",
                table: "Gyms");

            migrationBuilder.DropColumn(
                name: "Country",
                table: "Gyms");

            migrationBuilder.AddColumn<int>(
                name: "CityId",
                table: "Gyms",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Countries",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Countries", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Cities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CountryId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cities", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Cities_Countries_CountryId",
                        column: x => x.CountryId,
                        principalTable: "Countries",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "Countries",
                columns: new[] { "Id", "Name" },
                values: new object[] { 1, "Bosnia and Herzegovina" });

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Address", "CityId", "Email", "ImageId", "PhoneNumber", "WorkTime" },
                values: new object[] { "Titova 15", 2, "contact@fitlifegym.ba", null, "+387 33 111 111", "Pon-Pet: 06-22h, Sub-Ned: 08-18h" });

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Address", "CityId", "Email", "ImageId", "PhoneNumber", "WorkTime" },
                values: new object[] { "Bulevar Mira 22", 1, "info@powerzone.ba", null, "+387 36 222 222", "Pon-Ned: 07-23h" });

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

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Id", "CountryId", "Name" },
                values: new object[,]
                {
                    { 1, 1, "Mostar" },
                    { 2, 1, "Sarajevo" },
                    { 3, 1, "Zenica" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Gyms_CityId",
                table: "Gyms",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_Cities_CountryId",
                table: "Cities",
                column: "CountryId");

            migrationBuilder.AddForeignKey(
                name: "FK_Gyms_Cities_CityId",
                table: "Gyms",
                column: "CityId",
                principalTable: "Cities",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Gyms_Cities_CityId",
                table: "Gyms");

            migrationBuilder.DropTable(
                name: "Cities");

            migrationBuilder.DropTable(
                name: "Countries");

            migrationBuilder.DropIndex(
                name: "IX_Gyms_CityId",
                table: "Gyms");

            migrationBuilder.DropColumn(
                name: "CityId",
                table: "Gyms");

            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "Gyms",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Country",
                table: "Gyms",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Address", "City", "Country", "Email", "ImageId", "PhoneNumber", "WorkTime" },
                values: new object[] { "123 Main Street", "New York", "USA", "contact@fitlifegym.com", 2, "+387 62 111 111", "Mon-Fri: 6am-10pm, Sat-Sun: 8am-6pm" });

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Address", "City", "Country", "Email", "ImageId", "PhoneNumber", "WorkTime" },
                values: new object[] { "45 Oak Avenue", "London", "UK", "info@powerzone.co.uk", 3, "+387 62 111 112", "Mon-Sun: 7am-11pm" });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7735));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7736));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7738));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 1,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7910));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 2,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7913));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 4,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7914));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 5,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7922));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 6,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7924));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 7,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7925));

            migrationBuilder.UpdateData(
                table: "UserRoles",
                keyColumn: "Id",
                keyValue: 8,
                column: "DateAssigned",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7927));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7872));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7874));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7876));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7878));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7881));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7883));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedAt",
                value: new DateTime(2026, 5, 16, 20, 26, 37, 998, DateTimeKind.Utc).AddTicks(7885));
        }
    }
}
