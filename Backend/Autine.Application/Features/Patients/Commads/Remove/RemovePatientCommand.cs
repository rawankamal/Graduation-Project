namespace Autine.Application.Features.Patients.Commads.Remove;
public record RemovePatientCommand(string UserId, string Id) : ICommand;
