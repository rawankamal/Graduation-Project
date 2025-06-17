using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.Threads.Queries.GetTheadMessages;
public record GetThreadMessagesQuery(string UserId, Guid ThreadId) : IQuery<ThreadChatResponse>;

public class GetTheadMessagesQueryHandler(
    IUnitOfWork unitOfWork,
    IUserService userService) : IQueryHandler<GetThreadMessagesQuery, ThreadChatResponse>
{
    public async Task<Result<ThreadChatResponse>> Handle(GetThreadMessagesQuery request, CancellationToken ct)
    {
        if (await unitOfWork.Patients.GetAsync(t => t.Id == request.ThreadId, ct: ct) is not { } patient)
            return ThreadErrors.ThreadNotFound;

        var messages = await userService.GetThreadMessage(request.UserId, request.ThreadId, ct);

        if (messages.IsFailure)
            return messages.Error;

        var response = new ThreadChatResponse(
            patient.Id,
            patient.ThreadTitle,
            messages.Value);

        return response;
    }
}