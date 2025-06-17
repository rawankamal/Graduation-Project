using Autine.Application.ExternalContracts;

namespace Autine.Application.IServices.AIApi;
public interface IBaseService
{
    Task<Result<T>> SendAsync<T>(Request request, CancellationToken ct = default);
    Task<Result> SendAsync(Request request, CancellationToken ct = default);
}