namespace Autine.Application.Contracts.Patients;

public record SupervisorsResponse(
    string Id,
    string FirstName,
    string LastName,
    string UserName,
    string Email,
    string Gender,
    string Role,
    string Image,
    bool IsSupervised
    );