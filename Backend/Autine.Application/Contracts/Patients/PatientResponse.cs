namespace Autine.Application.Contracts.Patients;
public record PatientResponse (
    string Id,
    string FirstName,
    string LastName,
    string UserName,
    string Bio,
    DateTime DateOfBirth,
    string Gender,
    string Country,
    string City,
    DateTime CreatedAt,
    string Image,
    int Age, 
    string Diagnosis,
    DateTime LastSession,
    DateTime NextSession,
    string Status,
    string Notes,
    string SessionFrequency
    );