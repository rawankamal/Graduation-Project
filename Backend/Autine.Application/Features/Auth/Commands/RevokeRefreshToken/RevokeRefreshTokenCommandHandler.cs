using Autine.Application.IServices;

namespace Autine.Application.Features.Auth.Commands.RevokeRefreshToken;

public class RevokeRefreshTokenCommandHandler(IAuthService authService) : ICommandHandler<RevokeRefreshTokenCommand>
{
    public async Task<Result> Handle(RevokeRefreshTokenCommand request, CancellationToken cancellationToken)
        => await authService.RevokeRefreshTokenAsync(request.RefreshTokenRequest.Token, request.RefreshTokenRequest.RefreshToken, cancellationToken);
}
