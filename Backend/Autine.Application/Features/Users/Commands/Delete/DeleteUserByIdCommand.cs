using Autine.Domain.Entities;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;

namespace Autine.Application.Features.Users.Commands.Delete;
public record DeleteUserByIdCommand(string AdminId, string UserId) : ICommand;

public class DeleteUserByIdCommandHandler(IUserService userService, IAIAuthService aIAuthService, IUnitOfWork unitOfWork, ILogger<DeleteUserByIdCommandHandler> logger) : ICommandHandler<DeleteUserByIdCommand>
{
    public async Task<Result> Handle(DeleteUserByIdCommand request, CancellationToken cancellationToken)
    {
        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var serverResult = await userService.DeleteUserAsync(request.UserId, ct: cancellationToken, transaction);

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
                logger.LogError("Failed to delete user from AI system. UserId: {UserId}, Error: {Error}", request.UserId, aiResult.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return aiResult.Error;
            }
            logger.LogInformation("Successfully deleted user {UserId} by Admin {admin}", request.UserId, request.AdminId);
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success();
        }
        catch(Exception ex) 
        {
            // TODO: log error
            logger.LogError(ex, "Exception occurred while deleting user. UserId: {UserId}", request.UserId);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("Error.DeleteUser", "error occure while deleting user");
        }
    }
}
