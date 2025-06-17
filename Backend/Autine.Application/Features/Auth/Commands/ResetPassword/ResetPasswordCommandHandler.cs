using Autine.Application.IServices;

namespace Autine.Application.Features.Auth.Commands.ResetPassword;
public class ResetPasswordCommandHandler(IAuthService _authService) : ICommandHandler<ResetPasswordCommand>
{
    public async Task<Result> Handle(ResetPasswordCommand request, CancellationToken cancellationToken)
        => await _authService.ResetPasswordAsync(request.Request, cancellationToken);
}