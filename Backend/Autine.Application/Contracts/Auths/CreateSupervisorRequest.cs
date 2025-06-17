namespace Autine.Application.Contracts.Auths;

public record CreateSupervisorRequest(
    string FirstName,
    string LastName,
    string Email,
    string UserName,
    string Password,
    string Gender,
    string? Bio,
    string Country,
    string City,
    string SuperviorRole,
    DateTime DateOfBirth
);

