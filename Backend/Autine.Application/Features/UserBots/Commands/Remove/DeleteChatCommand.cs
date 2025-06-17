namespace Autine.Application.Features.UserBots.Commands.Remove;
public record DeleteChatCommand(string UserId, Guid BotId) : ICommand;
