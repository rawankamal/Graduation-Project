namespace Autine.Application.Features.Bots.Commands.UnAssign;
public record DeleteAssignCommand(string UserId, Guid BotId, string PatientId) : ICommand;