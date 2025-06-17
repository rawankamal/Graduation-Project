using Microsoft.Data.SqlClient;

namespace Autine.Infrastructure.Persistence.DBCommands;
public class StoredProcedures
{
    public static class BotSPs
    {
        public const string DeleteBotWithRelations = $"dbo.{nameof(DeleteBotWithRelations)}";
        public const string DeleteBotWithRelationsCall = $"EXEC {DeleteBotWithRelations} @BotId";
        public static SqlParameter BotParameter (Guid BotId)
            => new("@BotId", BotId);
        public static string DeleteBotWithRelationsProcedure => @"
            Create OR ALTER PROCEDURE dbo.DeleteBotWithRelations
                @BotId uniqueidentifier
            AS
            BEGIN
	            DELETE msg
	            from Messages as msg
	            join BotPatients bp 
	            on msg.BotPatientId = bp.Id
	            where bp.BotId = @BotId

                DELETE FROM BotPatients 
                WHERE BotId = @BotId
        
                DELETE FROM Bots 
                WHERE Id = @BotId
            END;
            GO";
    }
    public static class BotPatientSPs
    {
        public const string DeleteBotPatientWithRelations = $"dbo.{nameof(DeleteBotPatientWithRelations)}";
        public const string DeleteBotPatientWithRelationsCall = $"EXEC {DeleteBotPatientWithRelations} @BotPatientId";
        public static SqlParameter BotPatientParameter(Guid BotPatientId)
            => new("@BotPatientId", BotPatientId);
        public static string DeleteBotPatientWithRelationsProcedure => @"
            CREATE OR ALTER PROCEDURE dbo.DeleteBotPatientWithRelations
                @BotPatientId UNIQUEIDENTIFIER
            AS
            BEGIN
	            DELETE msg
	            from Messages as msg
	            join BotPatients bp 
	            on msg.BotPatientId = bp.Id
	            where bp.Id = @BotPatientId

                DELETE FROM BotPatients
                WHERE Id = @BotPatientId;
    
                RETURN 0;
            END;
            GO";
    }
    public static class BotMessageSPs
    {
        public const string DeleteBotMessagesWithRelations = $"dbo.{nameof(DeleteBotMessagesWithRelations)}";
        public const string DeleteBotMessagesWithRelationsCall = $"EXEC {DeleteBotMessagesWithRelations} @BotPatientId";
        public static SqlParameter BotMessagesParameter(Guid BotPatientId)
            => new("@BotPatientId", BotPatientId);
        public static string DeleteBotMessagesWithRelationsProcedure => @"
            CREATE OR ALTER PROCEDURE dbo.DeleteBotMessagesWithRelations
                @BotPatientId UNIQUEIDENTIFIER
            AS
            BEGIN
                DELETE msg
                from Messages as msg
                join BotPatients bp 
                on msg.BotPatientId = bp.Id
                where bp.Id = @BotPatientId

                RETURN 0;
            END;";
    }
    
    public static class ChatSPs
    {
        public const string ProcessChatOnUserDelete = $"dbo.{nameof(ProcessChatOnUserDelete)}";
        public const string ProcessChatOnUserDeleteCall = $"EXEC dbo.{nameof(ProcessChatOnUserDelete)} @UserId @AnonymousUserId";
        public static List<SqlParameter> ProcessChatOnUserDeleteParamter(string userId, string anonymousUserId)
            => [new("@UserId", userId), new ("@AnonymousUserId", anonymousUserId)];

        public static string ProcessChatOnUserDeleteProcedure => @"
            IF OBJECT_ID('dbo.ProcessChatOnUserDelete', 'P') IS NOT NULL
                DROP PROCEDURE dbo.ProcessChatOnUserDelete;
            GO
            CREATE PROCEDURE dbo.ProcessChatOnUserDelete
                @UserId NVARCHAR(450),
                @AnonymousUserId NVARCHAR(450) = 'e91025e5-5eb4-4ba3-a669-70d69acb77a1'
            AS
            BEGIN
                SET NOCOUNT ON;
    
                CREATE TABLE #ChatsToDelete (ChatId uniqueidentifier);
    
                WITH UserChats AS (
                    SELECT DISTINCT c.Id AS ChatId
                    FROM dbo.Chats c
                    WHERE c.UserId = @UserId OR c.CreatedBy = @UserId
                ),

                ChatParticipants AS (
                    SELECT 
                        c.Id AS ChatId,
                        CASE 
                            WHEN c.CreatedBy = @UserId THEN 
                                CASE WHEN c.UserId = @AnonymousUserId THEN 1 ELSE 0 END
                            WHEN c.UserId = @UserId THEN 
                                CASE WHEN c.CreatedBy = @AnonymousUserId THEN 1 ELSE 0 END
                            ELSE 0
                        END AS IsOtherUserAnonymous
                    FROM dbo.Chats c
                    JOIN UserChats uc ON c.Id = uc.ChatId
                )
                INSERT INTO #ChatsToDelete (ChatId)
                SELECT ChatId
                FROM ChatParticipants
                WHERE IsOtherUserAnonymous = 1;
    
                DELETE m
                FROM dbo.Messages m
                INNER JOIN #ChatsToDelete d ON m.ChatId = d.ChatId;
    
                DELETE c
                FROM dbo.Chats c
                INNER JOIN #ChatsToDelete d ON c.Id = d.ChatId;
    
                UPDATE c
                SET UserId = @AnonymousUserId
                FROM dbo.Chats c
                WHERE c.UserId = @UserId
                AND NOT EXISTS (SELECT 1 FROM #ChatsToDelete d WHERE d.ChatId = c.Id);
    
                UPDATE c
                SET CreatedBy = @AnonymousUserId
                FROM dbo.Chats c
                WHERE c.CreatedBy = @UserId
                AND NOT EXISTS (SELECT 1 FROM #ChatsToDelete d WHERE d.ChatId = c.Id);
    
                --DECLARE @DeletedCount INT = (SELECT COUNT(*) FROM #ChatsToDelete);

                --DECLARE @AnonymizedCount INT = (
                --    SELECT COUNT(*) 
                --    FROM dbo.Chats 
                --    WHERE (UserId = @AnonymousUserId AND CreatedBy = @UserId) 
                --       OR (CreatedBy = @AnonymousUserId AND UserId = @UserId)
                --);
    
                DROP TABLE #ChatsToDelete;
            END
            GO
        ";
    }
    // this
    public static class DeleteUserSPs
    {
        public const string DeleteUserWithAllRelations = $"dbo.{nameof(DeleteUserWithAllRelations)}";
        public const string DeleteUserWithAllRelationsCall = $"EXEC {DeleteUserWithAllRelations} @UserId, @AnonymousUserId";
        public static IEnumerable<SqlParameter> DeleteUserWithAllRelationsParamter(string userId, string anonymousUserId = DefaultUsers.AnonymousUser.Id)
            => [new("@UserId", userId), new("@AnonymousUserId", anonymousUserId)];

        public static string DeleteUserWithAllRelationsProcedure => @"
            IF OBJECT_ID('dbo.DeleteUserWithAllRelations', 'P') IS NOT NULL
                DROP PROCEDURE dbo.DeleteUserWithAllRelations;
            GO
            CREATE PROCEDURE dbo.DeleteUserWithAllRelations
                @UserId NVARCHAR(450),
                @AnonymousUserId NVARCHAR(450) = 'e91025e5-5eb4-4ba3-a669-70d69acb77a1'
            AS
            BEGIN
                SET NOCOUNT ON;
    
                DECLARE @IsSupervisor BIT = 0
                DECLARE @IsAdmin BIT = 0
                DECLARE @IsPatient BIT = 0
                DECLARE @IsRegularUser BIT = 0
    
                SELECT 
                    @IsSupervisor = CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.AspNetUserRoles ur 
                        INNER JOIN dbo.AspNetRoles r ON ur.RoleId = r.Id
                        WHERE ur.UserId = @UserId AND (r.Name = 'parent' or r.Name = 'doctor'))
                        THEN 1 ELSE 0 END,
                    @IsAdmin = CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.AspNetUserRoles ur 
                        INNER JOIN dbo.AspNetRoles r ON ur.RoleId = r.Id
                        WHERE ur.UserId = @UserId AND r.Name = 'admin') 
                        THEN 1 ELSE 0 END,
                    @IsPatient = CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.AspNetUserRoles ur 
                        INNER JOIN dbo.AspNetRoles r ON ur.RoleId = r.Id
                        WHERE ur.UserId = @UserId AND r.Name = 'patient')
                        THEN 1 ELSE 0 END,
                    @IsRegularUser = CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.AspNetUserRoles ur 
                        INNER JOIN dbo.AspNetRoles r ON ur.RoleId = r.Id
                        WHERE ur.UserId = @UserId AND r.Name = 'user')
                        THEN 1 ELSE 0 END

                IF @IsSupervisor = 1
                BEGIN

                    EXEC dbo.ProcessChatOnUserDelete @UserId = @UserId, @AnonymousUserId = @AnonymousUserId;
        
                    DECLARE @CreatedUserIds TABLE (UserId NVARCHAR(450));
        
                    INSERT INTO @CreatedUserIds
                    SELECT PatientId 
                    FROM dbo.Patients 
                    WHERE CreatedBy = @UserId;
        
                    -- Cursor to delete each created user as a regular user
                    DECLARE @CurrentUserId NVARCHAR(450);
        
                    DECLARE UserCursor CURSOR FOR 
                    SELECT UserId FROM @CreatedUserIds;
        
                    OPEN UserCursor;
                    FETCH NEXT FROM UserCursor INTO @CurrentUserId;
        
                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        EXEC dbo.DeleteUserWithAllRelations 
                            @UserId = @CurrentUserId, 
                            @AnonymousUserId = @AnonymousUserId;
            
                        FETCH NEXT FROM UserCursor INTO @CurrentUserId;
                    END
        
                    CLOSE UserCursor;
                    DEALLOCATE UserCursor;
        
                    ;WITH MsgsToDelete AS (
                        SELECT m.Id
                        FROM dbo.Messages m
                        JOIN dbo.ThreadMembers tm ON tm.Id = m.ThreadMemberId
                        JOIN dbo.Patients p ON tm.ThreadId = p.Id
                        WHERE p.CreatedBy = @UserId

                        UNION ALL

                        SELECT m.Id
                        FROM dbo.Messages m
                        JOIN dbo.BotPatients bp ON m.BotPatientId = bp.Id
                        JOIN dbo.Patients p2 ON bp.UserId = p2.PatientId
                        WHERE p2.CreatedBy = @UserId
                    )
                    DELETE msg
                    FROM dbo.Messages AS msg
                    JOIN MsgsToDelete d ON msg.Id = d.Id;

                    DELETE mbr
                    FROM dbo.ThreadMembers AS mbr
                    WHERE mbr.CreatedBy = @UserId;
		
		            Update tm
		            set tm.MemberId = @AnonymousUserId
		            from dbo.ThreadMembers as tm
		            where tm.MemberId = @UserId

                    DELETE bp
                    FROM dbo.BotPatients AS bp
                    INNER JOIN dbo.Patients AS p3 
                        ON bp.UserId = p3.PatientId
                    WHERE p3.CreatedBy = @UserId;

                    DELETE b
                    FROM dbo.Bots AS b
                    WHERE b.CreatedBy = @UserId;
                END

                ELSE IF @IsAdmin = 1
                BEGIN
                    ;WITH MsgsToDelete AS (
                        SELECT m.Id
                        FROM dbo.Messages m
                        INNER JOIN dbo.BotPatients bp ON m.BotPatientId = bp.Id
                        INNER JOIN dbo.Bots B ON bp.BotId = b.Id
                        WHERE b.CreatedBy = @UserId
                    )
                    DELETE msg
                    FROM dbo.Messages AS msg
                    JOIN MsgsToDelete d ON msg.Id = d.Id;

                    DELETE bp
                    FROM dbo.BotPatients bp
                    JOIN dbo.Bots b
                    ON bp.BotId = b.Id
                    WHERE b.CreatedBy = @UserId;

                    DELETE b
                    FROM dbo.Bots AS b
                    WHERE b.CreatedBy = @UserId;
                END

                ELSE IF @IsPatient = 1
                BEGIN
        
                    DELETE msg
                    FROM dbo.Messages AS msg
                    INNER JOIN dbo.BotPatients AS bp
                        ON bp.Id = msg.BotPatientId
                    WHERE bp.UserId = @UserId;

                    DELETE bp
                    FROM dbo.BotPatients AS bp
                    WHERE bp.UserId = @UserId;

                    DELETE mbr
                    FROM dbo.ThreadMembers AS mbr
                    INNER JOIN dbo.Patients AS p
                        ON p.Id = mbr.ThreadId
                    WHERE p.PatientId = @UserId;

                    DELETE p
                    FROM dbo.Patients AS p
                    WHERE p.PatientId = @UserId;
                END

                ELSE IF @IsRegularUser = 1
                BEGIN
                    DELETE msg
                    FROM dbo.Messages AS msg
                    INNER JOIN dbo.BotPatients AS bp
                        ON bp.Id = msg.BotPatientId
                    WHERE bp.UserId = @UserId;

                    DELETE bp
                    FROM dbo.BotPatients AS bp
                    WHERE bp.UserId = @UserId;

                END

                DELETE FROM dbo.AspNetUserTokens WHERE UserId = @UserId;
                DELETE FROM dbo.AspNetUserLogins WHERE UserId = @UserId;
                DELETE FROM dbo.AspNetUserRoles WHERE UserId = @UserId;
                DELETE FROM dbo.AspNetUserClaims WHERE UserId = @UserId;
                DELETE FROM dbo.AspNetUsers WHERE Id = @UserId;
            END
            GO";
    }
}

