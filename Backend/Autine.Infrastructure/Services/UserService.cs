using Autine.Application.Contracts.Threads;
using Autine.Application.Contracts.Users;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Microsoft.Extensions.Logging;
using System.Collections.Immutable;
using static Autine.Infrastructure.Identity.Consts.DefaultRoles;
using static Autine.Infrastructure.Persistence.DBCommands.StoredProcedures;
namespace Autine.Infrastructure.Services;
public class UserService(
    ApplicationDbContext context,
    UserManager<ApplicationUser> userManager,
    IFileService fileService,
    IUrlGenratorService urlGenratorService,
    ILogger<UserService> logger) : IUserService
{
    public async Task<bool> CheckUserExist(string userId, CancellationToken ct = default)
        => await context.Users.AnyAsync(e => e.Id == userId, ct);

    
    public async Task<Result<string>> DeleteUserAsync(string userId, CancellationToken ct = default, IDbContextTransaction? existingTransaction = null)
    {
        if (await context.Users.FindAsync([userId], ct) is not { } user)
        {
            logger.LogWarning("Delete failed. User with ID {UserId} not found.", userId);
            return UserErrors.UserNotFound;
        }


        var userRole = await userManager.GetRolesAsync(user);
        
        var image = await context.Users
            .Where(e => e.Id == userId)
            .Select(e => e.ProfilePicture)
            .SingleOrDefaultAsync(ct);

        
        var useLocalTransaction = existingTransaction == null;
        var transaction = existingTransaction ?? await context.Database.BeginTransactionAsync(ct);

        try
        {
            await context.Database.ExecuteSqlRawAsync(
                DeleteUserSPs.DeleteUserWithAllRelationsCall,
                DeleteUserSPs.DeleteUserWithAllRelationsParamter(userId),
                ct
                );

            await fileService.DeleteImageAsync(image!, false);

            if (useLocalTransaction)
                await transaction.CommitAsync(ct);


            var role = userRole.Contains(Admin.Name, StringComparer.OrdinalIgnoreCase) ? Admin.Name :
                userRole.Contains(Doctor.Name, StringComparer.OrdinalIgnoreCase) ? "supervisor" :
                userRole.Contains(Parent.Name, StringComparer.OrdinalIgnoreCase) ? "supervisor" :
                userRole.Contains(DefaultRoles.Patient.Name, StringComparer.OrdinalIgnoreCase) ? DefaultRoles.User.Name :
                DefaultRoles.User.Name;

         //   logger.LogInformation("Successfully deleted user {UserId} with role {Role}", userId, role);

            return Result.Success(role.ToLower());
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error occurred while deleting user {UserId}", userId);
            // TODO: log error
            if (useLocalTransaction)
                await transaction.RollbackAsync(ct);

            return Error.BadRequest("Error.DeleteUser", "error occure while deleting user.");
        }
    }

    public async Task<Result<DetailedUserResponse>> GetAsync(string id, CancellationToken ct = default)
    {
        var response = await (
            from u in context.Users
            join ur in context.UserRoles
            on u.Id equals ur.UserId
            join r in context.Roles
            on ur.RoleId equals r.Id into rls
            where u.Id == id && u.Id != "019409bf-3ae7-7cdf-995b-db4620f2ff5f"
            select new
            {
                u.Id,
                u.FirstName,
                u.LastName,
                u.UserName,
                u.Email,
                u.Bio,
                u.Gender,
                u.ProfilePicture,
                roles = rls.Select(e => e.Name)
            })
            .GroupBy(u => new { u.Id, u.FirstName, u.LastName, u.UserName, u.Bio, u.Gender, u.ProfilePicture, u.Email })
            .Select(x => new DetailedUserResponse
            (
                x.Key.Id,
                x.Key.FirstName,
                x.Key.LastName,
                x.Key.Email,
                x.Key.UserName,
                x.Key.Bio,
                x.Key.Gender,
                urlGenratorService.GetImageUrl(x.Key.ProfilePicture, false)!,
                x.SelectMany(e => e.roles).ToList()
            ))
            .SingleOrDefaultAsync(ct);


        if (response == null)
        {
            logger.LogWarning("User with ID {UserId} not found for GetAsync.", id);
            return UserErrors.UserNotFound;
        }

        logger.LogInformation("Retrieved detailed user info for userId: {UserId}", id);

        return Result.Success(response);
    }
    public async Task<IEnumerable<UserResponse>> GetAllAsync(string userId, string? roleId, CancellationToken cancellationToken = default)
    {
        var response = await (
        from u in context.Users
        join ur in context.UserRoles
        on u.Id equals ur.UserId
        join r in context.Roles
        on ur.RoleId equals r.Id
        where u.Id != userId && u.Id != "019409bf-3ae7-7cdf-995b-db4620f2ff5f"
        where ur.RoleId == roleId || roleId == null
        select new
        {
            u.Id,
            u.FirstName,
            u.LastName,
            u.Bio,
            u.ProfilePicture,
            r.Name
        })
        .GroupBy(u => new { u.Id, u.FirstName, u.LastName, u.ProfilePicture, u.Bio })
        .Select(x => new UserResponse
        (
            x.Key.Id,
            x.Key.FirstName,
            x.Key.LastName,
            x.Key.Bio,
            x.Key.ProfilePicture,
            x.Select(e => e.Name).FirstOrDefault()!
        ))
        .ToListAsync(cancellationToken);

        logger.LogInformation("Fetched all users (excluding userId: {UserId}) with role filter: {RoleId}", userId, roleId ?? "none");

        return response;
    }
    public async Task<Result<IEnumerable<ThreadMessageResponse>>> GetThreadMessage(string userId, Guid threadId, CancellationToken ct = default)
    {
        var messages = await (
            from tm in context.ThreadMembers
            join t in context.Patients on tm.ThreadId equals t.Id
            join m in context.Messages on tm.Id equals m.ThreadMemberId
            where tm.ThreadId == t.Id && t.Id == threadId
            select new
            {
                m.Id,
                m.Content,
                m.CreatedDate,
                m.Status,
                tm.MemberId
            }
            ).ToListAsync(ct);


        var memberIds = messages.Select(m => m.MemberId).ToList();

        if (memberIds.Count == 0)
            return Result.Success(Enumerable.Empty<ThreadMessageResponse>());

        var users = await (
            from u in context.Users
            join ur in context.UserRoles on u.Id equals ur.UserId
            join r in context.Roles on ur.RoleId equals r.Id
            where memberIds.Contains(u.Id)
            select new
            {
                u.Id,
                u.FirstName,
                u.LastName,
                u.Bio,
                u.ProfilePicture,
                r.Name
            }
            ).GroupBy(u => new { u.Id, u.FirstName, u.LastName, u.ProfilePicture, u.Bio })
            .Select(x => new UserResponse
            (
                x.Key.Id,
                x.Key.FirstName,
                x.Key.LastName,
                x.Key.Bio,
                urlGenratorService.GetImageUrl(x.Key.ProfilePicture, false)!,
                x.Select(e => e.Name).FirstOrDefault()!
            )).ToListAsync(ct);

        var response = messages.Join(
            users,
            m => m.MemberId,
            u => u.Id,
            (m, u) => new ThreadMessageResponse
            (
                m.Id,
                m.Content,
                m.CreatedDate,
                m.Status,
                u,
                u.Id == userId
            )).ToList();


        return response;
    }
    public async Task<Result<ThreadMessageResponse>> GetThreadMessageResponse(Guid messageId, CancellationToken ct = default)
    {
        var message = await context.Messages
            .Where(m => m.Id == messageId)
            .Join(
                context.Users,
                m => m.SenderId,
                u => u.Id,
                (m, u) => new ThreadMessageResponse(
                    m.Id,
                    m.Content,
                    m.CreatedDate,
                    m.Status,
                    new UserResponse
                    (
                        u.Id,
                        u.FirstName,
                        u.LastName,
                        u.Bio,
                        urlGenratorService.GetImageUrl(u.ProfilePicture, false)!,
                        string.Empty
                    ),
                    false
                )
            ).FirstOrDefaultAsync(ct);

        

        return message ?? default!;
    }

    public async Task<IEnumerable<ThreadChatMemberResponse>> GetThreadMemberResponse(Guid threadId, CancellationToken ct = default)
        =>  await (
                from u in context.Users
                join ur in context.UserRoles on u.Id equals ur.UserId
                join r in context.Roles on ur.RoleId equals r.Id
                join tm in context.ThreadMembers on u.Id equals tm.MemberId
                where tm.ThreadId == threadId
                select new ThreadChatMemberResponse
                (
                    tm.Id,
                    u.Id,
                    tm.CreatedAt,
                    new UserResponse
                    (
                        u.Id,
                        u.FirstName,
                        u.LastName,
                        u.Bio,
                        urlGenratorService.GetImageUrl(u.ProfilePicture, false)!,
                        r.Name!
                    )
                )
            ).ToListAsync(ct);
}

