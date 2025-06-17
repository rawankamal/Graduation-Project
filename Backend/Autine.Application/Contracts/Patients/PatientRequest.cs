namespace Autine.Application.Contracts.Patients;

public record PatientRequest(
    string FirstName,
    string LastName,
    string Email,
    string UserName,
    string Password,
    string Gender,
    string? Bio,
    string Country,
    string City,
    DateTime DateOfBirth,
    DateTime NextSession,
    DateTime LastSession,
    string Status,
    string Notes,
    string Diagnosis
    );