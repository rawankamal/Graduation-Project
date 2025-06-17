using Microsoft.EntityFrameworkCore.Migrations;
using static Autine.Infrastructure.Persistence.DBCommands.StoredProcedures;

#nullable disable

namespace Autine.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedingBotProcedure : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(BotSPs.DeleteBotWithRelationsProcedure);
            migrationBuilder.Sql(BotPatientSPs.DeleteBotPatientWithRelationsProcedure);
            migrationBuilder.Sql(BotMessageSPs.DeleteBotMessagesWithRelationsProcedure);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql($"DROP PROCEDURE {BotSPs.DeleteBotWithRelations}");
            migrationBuilder.Sql($"DROP PROCEDURE {BotPatientSPs.DeleteBotPatientWithRelations}");
            migrationBuilder.Sql($"DROP PROCEDURE {BotMessageSPs.DeleteBotMessagesWithRelations}");
        }
    }
}
