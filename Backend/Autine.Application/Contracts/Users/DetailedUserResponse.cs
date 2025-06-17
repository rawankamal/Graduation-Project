namespace Autine.Application.Contracts.Users;

public record DetailedUserResponse(
    string Id,
    string FirstName,
    string LastName,
    string Email,
    string UserName,
    string Bio,
    string Gender,
    string ProfilePic,
    IList<string> Roles
    );
