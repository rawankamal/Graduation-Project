using Autine.Application.Contracts.Auths;
using System.Data;

namespace Autine.Application.Features.Auth.Commands.RevokeRefreshToken;
public record RevokeRefreshTokenCommand(RefreshTokenRequest RefreshTokenRequest) : ICommand;
