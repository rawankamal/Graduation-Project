using Autine.Application.IServices;

namespace Autine.Application.Features.Auth.Commands.ForgotPassword;
public class ForgotPasswordCommandHandler(IAuthService _authService) : ICommandHandler<ForgotPasswordCommand, RegisterResponse>
{
    public async Task<Result<RegisterResponse>> Handle(ForgotPasswordCommand request, CancellationToken cancellationToken)
        => await _authService.ForgotPasswordAsync(request.Request, cancellationToken);
}
