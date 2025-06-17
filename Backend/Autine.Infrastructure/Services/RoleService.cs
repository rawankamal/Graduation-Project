using Autine.Application.IServices;
using Microsoft.Extensions.Logging;

namespace Autine.Infrastructure.Services;
public class RoleService(
    UserManager<ApplicationUser> userManager,
    RoleManager<IdentityRole> roleManager,
    ILogger<RoleService> logger) : IRoleService
{
    public async Task<Result> CheckUserInRoleAsync(string userId, string roleName)
    {
        logger.LogInformation("Checking if user {UserId} is in role {RoleName}", userId, roleName);

        if (await userManager.FindByIdAsync(userId) is not { } user)
        {
            logger.LogWarning("User not found with ID: {UserId}", userId);
            return UserErrors.UserNotFound;
        }

        if (!await roleManager.RoleExistsAsync(roleName))
        {
            logger.LogWarning("Role not found: {RoleName}", roleName);
            return RoleErrors.RoleNotFound;
        }

        if (await userManager.IsInRoleAsync(user, roleName))
        {
            logger.LogInformation("User {UserId} is in role {RoleName}", userId, roleName);
            return Result.Success();
        }

        logger.LogInformation("User {UserId} is NOT in role ", userId);
        return RoleErrors.UserNotFound;
    }

    public async Task<Result> UserIsAdminAsync(string userId)
    {
        logger.LogInformation("Checking if user {UserId} is admin", userId);


        if (await userManager.FindByIdAsync(userId) is not { } user)
        {
            logger.LogWarning("User {UserId} not found", userId);
            return UserErrors.UserNotFound;
        }
        if (await userManager.IsInRoleAsync(user, DefaultRoles.Admin.Name))
            return Result.Success();
        return RoleErrors.UserNotFound;
    }

    public async Task<bool> UserIsSupervisorAsync(string userId)
    {
        logger.LogInformation("Checking if user {UserId} is supervisor", userId);

        if (await userManager.FindByIdAsync(userId) is not { } user)
        {
            logger.LogWarning("User {UserId} not found", userId);
            return false;
        }

        if (await userManager.IsInRoleAsync(user, DefaultRoles.Parent.Name)
            || await userManager.IsInRoleAsync(user, DefaultRoles.Doctor.Name))
            return true;
        return false;
    }

    public async Task<Result<string>> GetUserRoleAsync(string userId)
    {
        logger.LogInformation("Getting role for user {UserId}", userId);

        if (await userManager.FindByIdAsync(userId) is not { } user)
        {
            logger.LogWarning("User {UserId} not found", userId);
            return UserErrors.UserNotFound;
        }


        var result = await userManager.GetRolesAsync(user);

        if (result.Contains(DefaultRoles.Admin.Name, StringComparer.OrdinalIgnoreCase))
            return DefaultRoles.Admin.Name.ToLower();

        if (result.Contains(DefaultRoles.Parent.Name, StringComparer.OrdinalIgnoreCase))
            return "supervisor";

        if (result.Contains(DefaultRoles.Doctor.Name, StringComparer.OrdinalIgnoreCase))
            return "supervisor";


        return DefaultRoles.User.Name.ToLower();
    }
    public async Task<Result> IsInRoleAsync(string userId, string role, CancellationToken ct = default)
    {
        logger.LogInformation("Checking if user {UserId} is in role {Role}", userId, role);

        if (await userManager.FindByIdAsync(userId) is not { } user)
        {
            logger.LogWarning("User {UserId} not found", userId);
            return UserErrors.UserNotFound;
        }


        var result = await userManager.GetRolesAsync(user);

        if (string.Equals(role, DefaultRoles.User.Name, StringComparison.OrdinalIgnoreCase))
        {
            var isUser = result.Where(e => !string.Equals(DefaultRoles.User.Name, e, StringComparison.OrdinalIgnoreCase));

            return isUser.Any() ? Result.Success() : RoleErrors.UserNotFound;
        }

        return result.Any(r => string.Equals(r, role, StringComparison.OrdinalIgnoreCase))
            ? Result.Success()
            : RoleErrors.RoleNotFound;
    }
    public async Task<Result> IsUserAsync(string userId)
    {
        logger.LogInformation("Checking if user {UserId} is a basic  user", userId);

        if (await userManager.FindByIdAsync(userId) is not { } user)
        {
            logger.LogWarning("User {UserId} not found", userId);
            return UserErrors.UserNotFound;
        }

        var result = await userManager.GetRolesAsync(user);
        
        var isUser = result.Where(e => !string.Equals(DefaultRoles.User.Name, e, StringComparison.OrdinalIgnoreCase));
        
        return isUser.Any() ? Result.Success() : RoleErrors.UserNotFound;
    }
}
