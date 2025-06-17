using Autine.Application.Contracts.Chats;

namespace Autine.Application.Features.Messages.Queries.GetChats;

public class GetChatsQueryHandler(IUnitOfWork unitOfWork) : IQueryHandler<GetChatsQuery, IEnumerable<ChatResponse>>
{
    public async Task<Result<IEnumerable<ChatResponse>>> Handle(GetChatsQuery request, CancellationToken ct)
    {
        var chats = await unitOfWork.Chats.GetAllAsync(e => e.UserId == request.UserId || e.CreatedBy == request.UserId, ct: ct);

        if (chats == null)
            return Result.Success(Enumerable.Empty<ChatResponse>());

        var response = chats.Select(c => new ChatResponse(
            c.Id,
            c.UserId.Equals(request.UserId, StringComparison.OrdinalIgnoreCase) ? c.CreatedBy : c.UserId,
            c.CreatedAt
            ));

        return Result.Success(response);
    }
}