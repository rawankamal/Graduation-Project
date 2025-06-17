using Autine.Application.ExternalContracts;
using Autine.Application.ExternalContracts.Bots;
using Autine.Application.IServices.AIApi;
using Microsoft.Extensions.Options;

namespace Autine.Infrastructure.Services.AIApi;
public class AIModelService(
    IBaseService baseService,
    IOptions<ApiSettings> options) : IAIModelService
{
    private readonly ApiSettings _options = options.Value;

    public async Task<Result> AddModelAsync(string userId, ModelRequest request, bool isAdmin = false, CancellationToken ct = default)
    {
        if (isAdmin)
            return await baseService.SendAsync(new(
                $"{_options.AIApi}/model/admin/add?username={userId}&session_id={1}",
                Data: request
                ), ct);

        return await baseService.SendAsync(new(
                $"{_options.AIApi}/model/supervisor/add?username={userId}&session_id={1}",
                Data: request
                ), ct);
    }
    public async Task<Result> AssignModelAsync(string userId, string modelName, string patientId, CancellationToken ct = default)
    {
        var url = $"{_options.AIApi}/assign/supervisor/add?supervisor_username={userId}&user_username={patientId}&model_name={modelName}&session_id={1}";
        var response = await baseService.SendAsync(new(
            url
            ), ct);

        return response;
    }
    public async Task<Result<ModelMessageResponse>> SendMessageToModelAsync(string userId, string modelName, string message, CancellationToken ct = default)
    {
        var url = $"{_options.AIApi}/model/chat/user/send?username={userId}&model_name={modelName}&msg_text={message}&session_id={1}";
        var response = await baseService.SendAsync<ModelMessageResponse>(new(
            url
            ), ct);

        return response;
    }
    public async Task<Result> RemoveModelAsync(string userId, string modelName, bool isAdmin = false, CancellationToken ct = default)
    {
        if (isAdmin)
            return await baseService.SendAsync(new(
                $"{_options.AIApi}/model/admin/delete?username={userId}&model_name={modelName}&session_id={1}",
                ApiMethod: ApiMethod.Delete
                ), ct);

        return await baseService.SendAsync(new(
            $"{_options.AIApi}/model/supervisor/delete?username={userId}&model_name={modelName}&session_id={1}",
            ApiMethod: ApiMethod.Delete
            ), ct);
    }
    


    public async Task<Result> UpdateModelAsync(string username, string model_name, ModelRequest request, bool isAdmin = false, CancellationToken ct = default)
    {
        if (isAdmin)
            return await baseService.SendAsync(new(
                $"{_options.AIApi}/model/admin/update?username={username}&model_name={model_name}&session_id={1}",
                Data: request,
                ApiMethod: ApiMethod.Put
                ), ct);
        return await baseService.SendAsync(new(
            $"{_options.AIApi}/model/supervisor/update?username={username}&model_name={model_name}&session_id={1}",
            Data: request,
            ApiMethod: ApiMethod.Put
            ), ct);
    }
    public async Task<Result> DeleteAssignAsync(string username, string user_username, string model_name, CancellationToken ct = default)
        => await baseService.SendAsync(new(
            $"{_options.AIApi}/assign/supervisor/delete?supervisor_username={username}&user_username={user_username}&model_name={model_name}&session_id={1}",
            ApiMethod: ApiMethod.Delete
            ), ct);
    public async Task<Result> DeleteChatAsync(string username, string model_name, CancellationToken ct = default)
        => await baseService.SendAsync(new(
            $"{_options.AIApi}/model/chat/user/delete?username={username}&model_name={model_name}&session_id={1}",
            ApiMethod.Delete
            ), ct);
}