namespace Autine.Application.Contracts.Patients;

public record AssignPatientRequest(
    string PatientId,
    string AssigneeId
    );
