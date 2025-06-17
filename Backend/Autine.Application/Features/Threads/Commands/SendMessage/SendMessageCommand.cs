using Autine.Application.Contracts.Threads;

namespace Autine.Application.Features.Threads.Commands.SendMessage;
public record SendMessageCommand(string UserId, Guid ThreadId, string Content) : ICommand<ThreadMessageResponse>;



public class SendMessageCommandHandler(
    IUnitOfWork unitOfWork,
    IUserService userService) : ICommandHandler<SendMessageCommand, ThreadMessageResponse>
{
    public async Task<Result<ThreadMessageResponse>> Handle(SendMessageCommand request, CancellationToken ct)
    {
        var threadMember = await unitOfWork.ThreadMembers.GetAsync(t => t.ThreadId == request.ThreadId && t.MemberId == request.UserId, ct: ct);

        if (threadMember is null)
            return ThreadMemberErrors.ThreadMemberNotFound;

        var message = new Message
        {
            Content = request.Content,
            SenderId = request.UserId,
            ThreadMemberId = threadMember.Id,
            IsRead = true
        };

        await unitOfWork.Messages.AddAsync(message, ct);

        var resposne = await userService.GetThreadMessageResponse(message.Id, ct);

        return resposne;
    }
}
