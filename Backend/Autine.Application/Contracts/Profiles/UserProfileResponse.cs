namespace Autine.Application.Contracts.Profiles;

public record UserProfileResponse(
    string Id,
    string FirstName,
    string LastName,
    string Bio,
    string Gender,
    string? Country,
    string? City,
    string? ImageUrl,
    DateTime DateOfBirth
    );