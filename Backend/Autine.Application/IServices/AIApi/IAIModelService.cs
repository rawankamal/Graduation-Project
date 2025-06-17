using Autine.Application.ExternalContracts.Bots;

namespace Autine.Application.IServices.AIApi;
public interface IAIModelService
{
    Task<Result> AddModelAsync(string userId, ModelRequest request, bool isAdmin = false, CancellationToken ct = default);
    Task<Result> AssignModelAsync(string userId, string modelName, string patientId, CancellationToken ct = default);
    Task<Result> RemoveModelAsync(string userId, string modelName, bool isAdmin = false, CancellationToken ct = default); 
    Task<Result<ModelMessageResponse>> SendMessageToModelAsync(string userId, string modelName, string message, CancellationToken ct = default);
    Task<Result> UpdateModelAsync(string username, string model_name, ModelRequest request, bool isAdmin = false, CancellationToken ct = default);
    Task<Result> DeleteAssignAsync(string supervisor_username, string user_username, string model_name, CancellationToken ct = default);
    Task<Result> DeleteChatAsync(string username, string model_name, CancellationToken ct = default);
}
