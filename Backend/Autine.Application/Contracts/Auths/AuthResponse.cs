namespace Autine.Application.Contracts.Auths;
public record AuthResponse(
    string AccessToken,
    int ExpiresIn,
    string RefreshToken,
    DateTime RefreshTokenExpiration,
    string TokenType = "Berear"
);