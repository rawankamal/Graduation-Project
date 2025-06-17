using Autine.Application.Contracts.Auths;

namespace Autine.Application.Features.Auth.Commands.RefreshTokens;
public record RefreshTokenCommand(RefreshTokenRequest RefreshToken) : ICommand<AuthResponse>;
