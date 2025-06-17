namespace Autine.Application.Features.ThreadMember.Commands.Add;
public record AddThreadMemberCommand(string UserId, Guid ThreadId, string MemberId) : ICommand<Guid>;