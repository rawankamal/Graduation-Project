namespace Autine.Application.Contracts.Auth;

public record ChangePasswordRequest (
    string CurrentPassword,
    string NewPassword
);