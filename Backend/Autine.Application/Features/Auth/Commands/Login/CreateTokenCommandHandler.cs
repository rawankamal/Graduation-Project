using Autine.Application.Abstractions.Messaging;
using Autine.Application.Contracts.Auths;
using Autine.Application.IServices;

namespace Autine.Application.Features.Auth.Commands.Login;

public class CreateTokenCommandHandler(IAuthService _authService) : ICommandHandler<CreateTokenCommand, AuthResponse>
{
    public async Task<Result<AuthResponse>> Handle(CreateTokenCommand request, CancellationToken cancellationToken) 
        => await _authService.GetTokenAsync(request.Request, cancellationToken);
}