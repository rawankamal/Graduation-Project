using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.Bots.Commands.Create;
public record CreateBotCommand(string UserId, CreateBotRequest Request) : ICommand<Guid>;