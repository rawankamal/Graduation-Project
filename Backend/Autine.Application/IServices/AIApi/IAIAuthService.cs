using Autine.Application.ExternalContracts.Auth;

namespace Autine.Application.IServices.AIApi;
public interface IAIAuthService
{
    Task<Result> RegisterAsync(AIRegisterRequest request, CancellationToken ct = default);
    Task<Result> SupervisorAsync(AIRegisterRequest request, CancellationToken ct = default);
    Task<Result> AddPatientAsync(string username, AIRegisterRequest request, CancellationToken ct = default);
    Task<Result> AdminAddAdmin(string admin_username, AIRegisterRequest request, CancellationToken ct = default);
    Task<Result> RemovePatientAsync(string username, string user_username, CancellationToken ct = default);
    Task<Result> UpdateUserAsync(string role, string username, AIUpdateRequest request, string password, CancellationToken ct = default);
        Task<Result> DeleteUserAsync(string role, string username, string password, CancellationToken ct = default);
    //Task<Result> UpdateUserByRoleAsync(string username, string password, AIUpdateSuperRequest request, bool isAdmin = false, CancellationToken ct = default);
}
