using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.UserBots.Commands.Remove;

public class DeleteChatCommandHandler(
    IUnitOfWork unitOfWork,
    IAIModelService aIModelService,
    ILogger<DeleteChatCommandHandler> logger) : ICommandHandler<DeleteChatCommand>
{
    public async Task<Result> Handle(DeleteChatCommand request, CancellationToken cancellationToken)
    {
        var botPatient = await unitOfWork.BotPatients
            .GetAsync(e => e.UserId == request.UserId && e.BotId == request.BotId, 
            includes: "Bot",
            ct: cancellationToken);

        if (botPatient == null)
        {
          // logger.LogWarning("BotPatient not found. UserId: {UserId}, BotId: {BotId}", request.UserId, request.BotId);
            return BotPatientError.PatientNotFound;
        }
        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            if (botPatient.IsUser)
            {
                var serverResult = await unitOfWork.BotPatients.DeleteBotPatientAsync(botPatient.Id, cancellationToken);

                if (serverResult.IsFailure)
                {
                    logger.LogError("Failed to delete BotPatient from server. Id: {Id}, Error: {Error}", botPatient.Id, serverResult.Error);
                    await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                    return serverResult.Error;
                }
            }

            var result = await aIModelService.DeleteChatAsync(request.UserId, botPatient.Bot.Name, cancellationToken);

            if (result.IsFailure)
            {
                logger.LogError("Failed to delete chat from AI model. UserId: {UserId}, BotName: {BotName}, Error: {Error}",request.UserId, botPatient.Bot.Name, result.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return result.Error;
            }

            logger.LogError("successfully delete chat from the System. UserId: {UserId}, BotName: {BotName}", request.UserId, botPatient.Bot.Name);
     
            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success();
        }
        catch(Exception ex) 
        {
            // TODO: log error
            logger.LogError(ex, "Exception occurred while deleting chat. UserId: {UserId}, BotId: {BotId}", request.UserId, request.BotId);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("Error.DeleteChat", "error occure while delete chat bot.");
        }
    }
}
