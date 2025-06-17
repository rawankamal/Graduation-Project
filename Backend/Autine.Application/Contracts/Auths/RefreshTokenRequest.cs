namespace Autine.Application.Contracts.Auths;

public record RefreshTokenRequest(
    string Token, 
    string RefreshToken);
