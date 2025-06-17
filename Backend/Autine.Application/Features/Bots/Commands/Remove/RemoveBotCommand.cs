namespace Autine.Application.Features.Bots.Commands.Remove;
public record RemoveBotCommand(string UserId, Guid BotId) : ICommand;
