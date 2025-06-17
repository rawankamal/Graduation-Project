using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Autine.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateMessageEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Messages_Chats_ChatId",
                table: "Messages");

            migrationBuilder.DropTable(
                name: "BotMessages");

            migrationBuilder.DropTable(
                name: "ThreadMessages");

            migrationBuilder.DropIndex(
                name: "IX_Messages_ChatId",
                table: "Messages");

            migrationBuilder.DropIndex(
                name: "IX_Messages_SenderId",
                table: "Messages");

            migrationBuilder.AddColumn<Guid>(
                name: "BotPatientId",
                table: "Messages",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ThreadMemberId",
                table: "Messages",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Message_BotPatientId",
                table: "Messages",
                column: "BotPatientId",
                filter: "BotPatientId IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Message_ChatId",
                table: "Messages",
                column: "ChatId",
                filter: "ChatId IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Message_CreatedDate",
                table: "Messages",
                column: "CreatedDate");

            migrationBuilder.CreateIndex(
                name: "IX_Message_SenderId",
                table: "Messages",
                column: "SenderId",
                filter: "SenderId IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Message_ThreadMemberId",
                table: "Messages",
                column: "ThreadMemberId",
                filter: "ThreadMemberId IS NOT NULL");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Message_ExclusiveThreadMemberOrChatOrBotPatient",
                table: "Messages",
                sql: "(BotPatientId IS NOT NULL AND ChatId IS NULL AND BotPatientId IS NULL) OR (BotPatientId IS NULL AND ChatId IS NOT NULL AND BotPatientId IS NULL) OR (BotPatientId IS NULL AND ChatId IS NULL AND BotPatientId IS NOT NULL) AND(SenderId Is NOT NULL AND (ChatId IS NOT NULL OR ThreadMemberId IS NOT NULL))");

            migrationBuilder.AddForeignKey(
                name: "FK_Messages_BotPatients_BotPatientId",
                table: "Messages",
                column: "BotPatientId",
                principalTable: "BotPatients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Messages_Chats_ChatId",
                table: "Messages",
                column: "ChatId",
                principalTable: "Chats",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Messages_ThreadMembers_ThreadMemberId",
                table: "Messages",
                column: "ThreadMemberId",
                principalTable: "ThreadMembers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Messages_BotPatients_BotPatientId",
                table: "Messages");

            migrationBuilder.DropForeignKey(
                name: "FK_Messages_Chats_ChatId",
                table: "Messages");

            migrationBuilder.DropForeignKey(
                name: "FK_Messages_ThreadMembers_ThreadMemberId",
                table: "Messages");

            migrationBuilder.DropIndex(
                name: "IX_Message_BotPatientId",
                table: "Messages");

            migrationBuilder.DropIndex(
                name: "IX_Message_ChatId",
                table: "Messages");

            migrationBuilder.DropIndex(
                name: "IX_Message_CreatedDate",
                table: "Messages");

            migrationBuilder.DropIndex(
                name: "IX_Message_SenderId",
                table: "Messages");

            migrationBuilder.DropIndex(
                name: "IX_Message_ThreadMemberId",
                table: "Messages");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Message_ExclusiveThreadMemberOrChatOrBotPatient",
                table: "Messages");

            migrationBuilder.DropColumn(
                name: "BotPatientId",
                table: "Messages");

            migrationBuilder.DropColumn(
                name: "ThreadMemberId",
                table: "Messages");

            migrationBuilder.CreateTable(
                name: "BotMessages",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    BotPatientId = table.Column<Guid>(type: "uniqueidentifier", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BotMessages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BotMessages_BotPatients_BotPatientId",
                        column: x => x.BotPatientId,
                        principalTable: "BotPatients",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_BotMessages_Messages_Id",
                        column: x => x.Id,
                        principalTable: "Messages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ThreadMessages",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    MessageId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ThreadMemberId = table.Column<Guid>(type: "uniqueidentifier", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ThreadMessages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ThreadMessages_Messages_MessageId",
                        column: x => x.MessageId,
                        principalTable: "Messages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ThreadMessages_ThreadMembers_ThreadMemberId",
                        column: x => x.ThreadMemberId,
                        principalTable: "ThreadMembers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Messages_ChatId",
                table: "Messages",
                column: "ChatId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_SenderId",
                table: "Messages",
                column: "SenderId");

            migrationBuilder.CreateIndex(
                name: "IX_BotMessages_BotPatientId",
                table: "BotMessages",
                column: "BotPatientId");

            migrationBuilder.CreateIndex(
                name: "IX_ThreadMessages_MessageId",
                table: "ThreadMessages",
                column: "MessageId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ThreadMessages_ThreadMemberId_MessageId",
                table: "ThreadMessages",
                columns: new[] { "ThreadMemberId", "MessageId" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Messages_Chats_ChatId",
                table: "Messages",
                column: "ChatId",
                principalTable: "Chats",
                principalColumn: "Id");
        }
    }
}
