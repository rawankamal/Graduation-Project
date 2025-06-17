namespace Autine.Application.IServices;
public interface IRoleService
{
    Task<Result> IsInRoleAsync(string userId, string role, CancellationToken ct = default);
    Task<Result> CheckUserInRoleAsync(string userId, string roleName);
    Task<Result> UserIsAdminAsync(string userId);
    Task<bool> UserIsSupervisorAsync(string userId);
    Task<Result<string>> GetUserRoleAsync(string userId);
    Task<Result> IsUserAsync(string userId);
}
