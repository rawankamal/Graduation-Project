using Autine.Application.ExternalContracts;
using Autine.Application.ExternalContracts.Auth;
using Autine.Application.IServices.AIApi;
using Microsoft.Extensions.Options;

namespace Autine.Infrastructure.Services.AIApi;
public class AIAuthService(
    IBaseService baseService,
    IOptions<ApiSettings> apiSetting) : IAIAuthService
{
    private readonly ApiSettings _apiSetting = apiSetting.Value;


    public async Task<Result> RegisterAsync(AIRegisterRequest request, CancellationToken ct = default)
        => await baseService.SendAsync(
            new Request (
                $"{_apiSetting.AIApi}/auth/user/register",
                Data: request
        ), ct);
    public async Task<Result> SupervisorAsync(AIRegisterRequest request, CancellationToken ct = default)
        => await baseService.SendAsync(
            new Request (
                $"{_apiSetting.AIApi}/auth/supervisor/register",
                Data: request
        ), ct);
    public async Task<Result> AddPatientAsync(string username, AIRegisterRequest request, CancellationToken ct = default)
    => await baseService.SendAsync(
            new Request(
                $"{_apiSetting.AIApi}/auth/supervisor/user/add?username={username}&session_id={1}",
                Data: request
        ), ct);

    public async Task<Result> AdminAddAdmin(string admin_username, AIRegisterRequest request, CancellationToken ct = default)
        => await baseService.SendAsync(
            new Request(
                $"{_apiSetting.AIApi}/admin/add/admin?{nameof(admin_username)}={admin_username}&session_id={1}",
                Data: request
                ),
            ct
            );

    public async Task<Result> UpdateUserAsync(string role, string username, AIUpdateRequest request, string password, CancellationToken ct = default)
        => await baseService.SendAsync(
            new Request(
                $"{_apiSetting.AIApi}/auth/{role}/update?username={username}&password={password}&session_id=1",
                ApiMethod.Put,
                Data: request
        ), ct);

    public async Task<Result> UpdateUserByRoleAsync(string username, string password, AIUpdateSuperRequest request ,bool isAdmin = false,  CancellationToken ct = default)
    {
        if (isAdmin)
            return await baseService.SendAsync(
                new Request(
                    $"{_apiSetting.AIApi}/auth/admin/update?username={username}&password={password}&session_id=1",
                    ApiMethod.Put,
                    Data: request
            ), ct);

        return await baseService.SendAsync(
            new Request(
                $"{_apiSetting.AIApi}/auth/supervisor/update?username={username}&password={password}&session_id=1",
                ApiMethod.Put,
                Data: request
        ), ct);
    }
    public async Task<Result> RemovePatientAsync(string suepervisor_username, string user_username, CancellationToken ct = default)
        => await baseService.SendAsync(
            new Request(
                $"{_apiSetting.AIApi}/auth/supervisor/user/delete?username={suepervisor_username}&user_username={user_username}&session_id=1",
                ApiMethod.Delete
        ), ct);

    public async Task<Result> DeleteUserAsync(string role, string username, string password, CancellationToken ct = default)
        => await baseService.SendAsync(
            new Request(
                $"{_apiSetting.AIApi}/auth/{role}/delete?username={username}&password={password}&session_id=1",
                ApiMethod.Delete
        ), ct);



}
