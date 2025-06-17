using Autine.Domain.Abstractions;
using Autine.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Profiles.Commands.Delete;
public class DeleteProfileCommandHandler(
    IAIAuthService aIAuthService,
    IUserService userService,
    IUnitOfWork unitOfWork,
    ILogger<DeleteProfileCommandHandler> logger) : ICommandHandler<DeleteProfileCommand>
  {
    public async Task<Result> Handle(DeleteProfileCommand request, CancellationToken cancellationToken)
    {
        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var serverResult = await userService.DeleteUserAsync(request.UserId,cancellationToken, transaction);

            if (serverResult.IsFailure)
            {
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return serverResult.Error;
            }

            var aiResult = await aIAuthService.DeleteUserAsync(
                serverResult.Value,
                request.UserId,
                Consts.FixedPassword,
            cancellationToken
            );
            if (aiResult.IsFailure)
            {
                logger.LogError("Failed to delete Profile from AI model. UserId: {UserId}, Error: {Error}", request.UserId, aiResult.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return aiResult.Error;
            }
            logger.LogInformation("Profile Deleted Successfully for userId:{UserId}",request.UserId);
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success();
        }
        catch(Exception ex) 
        {
            logger.LogError(ex, "Error occurred while deleting Profile {UserId}. Reason: {Reason}", request.UserId,ex.Message);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("Error.DeleteUser", "error occure while deleting user");
        }

        
    }
}
