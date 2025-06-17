
namespace Autine.Application.Features.Messages.Queries.GetConnections;

public class GetUserConnectionsQueryHandler(IUnitOfWork unitOfWork) : IQueryHandler<GetUserConnectionsQuery, IList<string>>
{
    public async Task<Result<IList<string>>> Handle(GetUserConnectionsQuery request, CancellationToken ct)
    {
        var chats = await unitOfWork.Chats.GetAllAsync(c => c.UserId == request.UserId || c.CreatedBy == request.UserId, ct: ct);

        return chats.Select(c => c.UserId.Equals(request.UserId, StringComparison.OrdinalIgnoreCase) ? c.CreatedBy : c.UserId).ToList();
    }
}
