namespace Autine.Application.Contracts.Profiles;

public record UpdateUserProfileRequest(
    string FirstName,
    string LastName,
    string Bio,
    string? Country,
    string? City,
    string Gender,
    DateTime DateOfBirth
    );