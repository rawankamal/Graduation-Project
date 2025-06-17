namespace Autine.Application.Features.ThreadMember.Commands.Remove;
public record RemoveMemberCommand(string UserId, Guid ThreadMemberId) : ICommand;
