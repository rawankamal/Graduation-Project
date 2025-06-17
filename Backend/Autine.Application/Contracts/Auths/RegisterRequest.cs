namespace Autine.Application.Contracts.Auths;
public record RegisterRequest(
    string FirstName,
    string LastName,
    string Email,
    string UserName,
    string Password,
    string Gender,
    DateTime DateOfBirth,
    string? Country = "",
    string? City = "",
    string? Bio = ""
);

//public record RegisterRequest
//{
//    public string FirstName { get; init; } = string.Empty;
//    public string LastName { get; init; } = string.Empty;
//    public string Email { get; init; } = string.Empty;
//    public string UserName { get; init; } = string.Empty;
//    public string Password { get; init; } = string.Empty;
//    public string Gender { get; init; } = string.Empty;
//    public DateTime DateOfBirth { get; init; }  

//    // default-initialized properties:
//    public string? Bio { get; init; } = "";
//    public string? Country { get; init; } = "";
//    public string? City { get; init; } = "";
//}