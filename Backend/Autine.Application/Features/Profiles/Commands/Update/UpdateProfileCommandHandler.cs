using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Profiles.Commands.Update;
public class UpdateProfileCommandHandler(
    IAccountService accountService, 
    IUnitOfWork unitOfWork,
    IRoleService roleService,
    IAIAuthService aIAuthService,
    ILogger<UpdateProfileCommandHandler> logger) : ICommandHandler<UpdateProfileCommand>
{
    public async Task<Result> Handle(UpdateProfileCommand request, CancellationToken cancellationToken)
    {

        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var serverResult = await accountService.UpdateProfileAsync(request.UserId, request.UpdateRequest, cancellationToken);

            if (!serverResult.IsSuccess)
            {
                logger.LogError("Failed to Update user Profile from server. UserId: {UserId}, Error: {Error}", request.UserId, serverResult.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return serverResult;
            }

            var role = await roleService.GetUserRoleAsync(request.UserId);

            if (role.IsSuccess) 
            {
                var aiResult = await aIAuthService.UpdateUserAsync(
                    role.Value,
                    request.UserId,
                    new(fname: request.UpdateRequest.FirstName, lname: request.UpdateRequest.LastName, gender: request.UpdateRequest.Gender),
                    Consts.FixedPassword,
                    cancellationToken);

                if (aiResult.IsFailure)
                {
                    logger.LogError("Failed to Update user Profile from AI model. UserId: {UserId}, Error: {Error}", request.UserId, aiResult.Error);
                    await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                    return aiResult.Error;
                }
            }

            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success();
        }
        catch(Exception ex) 
        {
            logger.LogError(ex,"Failed to Update user Profile from AI model. UserId: {UserId}, Error: {Error}", request.UserId, ex.Message);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.InternalServerError("Error", "An error occure while update info");
        }
    }
}
