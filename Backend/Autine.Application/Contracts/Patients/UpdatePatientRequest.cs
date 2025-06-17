namespace Autine.Application.Contracts.Patients;

public record UpdatePatientRequest(
    string FirstName,
    string LastName,
    string Bio,
    string Gender,
    DateTime DateOfBirth,
    string? Country,
    string? City,
    DateTime NextSession,
    DateTime LastSession,
    string Diagnosis,
    string Status,
    string Notes,
    string SessionFrequency
    );
