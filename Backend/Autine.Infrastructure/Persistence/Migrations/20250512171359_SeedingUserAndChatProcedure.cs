using Microsoft.EntityFrameworkCore.Migrations;
using static Autine.Infrastructure.Persistence.DBCommands.StoredProcedures;

#nullable disable

namespace Autine.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedingUserAndChatProcedure : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(DeleteUserSPs.DeleteUserWithAllRelationsProcedure);
            migrationBuilder.Sql(ChatSPs.ProcessChatOnUserDeleteProcedure);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql($"DROP PROCEDURE {ChatSPs.ProcessChatOnUserDelete}");
            migrationBuilder.Sql($"DROP PROCEDURE {DeleteUserSPs.DeleteUserWithAllRelations}");
        }
    }
}
