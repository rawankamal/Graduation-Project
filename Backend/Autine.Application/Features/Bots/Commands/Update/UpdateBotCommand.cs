using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.Bots.Commands.Update;
public record UpdateBotCommand(string UserId, Guid BotId, UpdateBotRequest UpdateRequest) : ICommand;
