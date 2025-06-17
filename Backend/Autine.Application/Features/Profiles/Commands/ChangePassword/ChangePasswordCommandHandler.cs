using Autine.Application.IServices;
using Autine.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Profiles.Commands.ChangePassword;
public class ChangePasswordCommandHandler(
    IAccountService accountService,
    ILogger<ChangePasswordCommandHandler> logger) : ICommandHandler<ChangePasswordCommand>
{
    public async Task<Result> Handle(ChangePasswordCommand request, CancellationToken cancellationToken)
    {
        try
        { 
            var serverResult = await accountService.ChangePasswordAsync(request.UserId, request.ChangePasswordRequest, cancellationToken);
            
            if (!serverResult.IsSuccess)
                return serverResult;

            return Result.Success();
        }
        catch(Exception ex) 
        {
            // TODO: Log error
            logger.LogError(ex, "Password change failed for userId: {UserId}. Reason: {Reason}", request.UserId, ex.Message);
            return Error.InternalServerError("Error.ChangePassword", "An error occure while change password info");
        }
    }
}
