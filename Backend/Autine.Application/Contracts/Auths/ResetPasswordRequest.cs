namespace Autine.Application.Contracts.Auth;

public record ResetPasswordRequest (
    string UserId,
    string Code,
    string Password
);
