using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Autine.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedingAnonymousUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "Bio", "City", "ConcurrencyStamp", "Country", "DateOfBirth", "Email", "EmailConfirmed", "FirstName", "Gender", "LastName", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "ProfilePicture", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "e91025e5-5eb4-4ba3-a669-70d69acb77a1", 0, "Anonymous", "Kafr elsheikh", "FDF489E9-610F-4C4F-B560-6A6C6DC3D212", "Egypt", new DateTime(2025, 2, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), "anonymous@anonymous.com", true, "Autine", "male", "Anonymous", false, null, "ANONYMOUS@ANONYMOUS.COM", "ANONYMOUS", "AQAAAAIAAYagAAAAENM3gPuLzFgxltA0DcYSDrTPi1XWJhEkzbxXO6/EAxO9qqTV6hBNn1GSHo0VmGJT1A==", null, false, "none", "8c817ccb-f1cb-42fb-a039-45ba6634ae65", false, "anonymous" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "e91025e5-5eb4-4ba3-a669-70d69acb77a1");
        }
    }
}
