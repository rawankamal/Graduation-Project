namespace Autine.Application.Features.Bots.Commands.Assign;
public record AssignModelCommand(string UserId, string PatientId, Guid BotId) : ICommand;