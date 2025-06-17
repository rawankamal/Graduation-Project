using Autine.Application.Contracts.Patients;

namespace Autine.Application.Features.Patients.Commads.Add;
public record AddPatientCommand(string UserId, PatientRequest Request) : ICommand<string>;
