namespace Autine.Application.Contracts.Users;
public record UserResponse(
    string Id,
    string FirstName,
    string LastName,
    string Bio,
    string ProfilePic,
    string Role
    );
