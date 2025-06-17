namespace Autine.Application.Contracts.Auths;

public record TokenRequest (
    string Email,
    string Password
);
