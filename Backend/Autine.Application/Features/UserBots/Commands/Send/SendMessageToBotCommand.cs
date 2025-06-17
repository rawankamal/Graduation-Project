using Autine.Application.Contracts.UserBots;

namespace Autine.Application.Features.UserBots.Commands.Send;
public record SendMessageToBotCommand(string UserId, Guid BotId, string Content) : ICommand<MessageResponse>;
