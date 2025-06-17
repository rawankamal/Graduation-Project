using Autine.Application.Contracts.UserBots;

namespace Autine.Application.Features.Messages.Commands;
public record SendDMCommand(string UserId, string RecieverId, string Content) : ICommand<MessageResponse>;
