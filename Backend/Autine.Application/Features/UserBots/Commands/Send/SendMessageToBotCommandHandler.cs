using Autine.Application.Contracts.UserBots;
using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.UserBots.Commands.Send;
public class SendMessageToBotCommandHandler(
    IUnitOfWork unitOfWork,
    IAIModelService aIModelService,
    ILogger<SendMessageToBotCommandHandler> logger) : ICommandHandler<SendMessageToBotCommand, MessageResponse>
{
    public async Task<Result<MessageResponse>> Handle(SendMessageToBotCommand request, CancellationToken cancellationToken)
    {
        var botPatient = await unitOfWork.BotPatients
            .GetAsync(e => 
            e.BotId == request.BotId && 
            e.UserId == request.UserId,
            includes: "Bot",
            ct: cancellationToken);

        var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            string botName = string.Empty;
            Guid botPatientId = Guid.Empty;
            if (botPatient == null)
            {
                if (await unitOfWork.Bots.GetAsync(e => e.Id == request.BotId, ct: cancellationToken) is not { } bot)
                {
                    //logger.LogWarning("Bot not found. BotId: {BotId}", request.BotId);
                    return BotErrors.BotNotFound;
                }

                if (!bot.IsPublic)
                {
                   // logger.LogWarning("Bot is not public. BotId: {BotId}", request.BotId);
                    return BotErrors.InvalidBot;
                }

                var newBotPatient = new BotPatient
                {
                    BotId = bot.Id,
                    UserId = request.UserId,
                    IsUser = true
                };

                await unitOfWork.BotPatients.AddAsync(newBotPatient, ct: cancellationToken);

                botName = bot.Name;
                botPatientId = newBotPatient.Id;
            }
            else
            {
                botName = botPatient.Bot.Name;
                botPatientId = botPatient.Id;
            }

            var botResponse = await aIModelService.SendMessageToModelAsync(
                userId: request.UserId,
                modelName: botName,
                message: request.Content,
                ct: cancellationToken
                );

            if (botResponse.IsFailure)
            {
                logger.LogError("Failed to send message to bot. UserId: {UserId}, Bot: {BotName}, Error: {Error}", request.UserId, botName, botResponse.Error);
                await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
                return Error.BadRequest("SendMessage.Failed", botResponse.Error.Description);
            }


            var messages = new List<Message>
            {
                new()
                {
                    SenderId = request.UserId,
                    Content = request.Content,
                    CreatedDate = DateTime.UtcNow,
                    ReadAt = DateTime.UtcNow,
                    Status = MessageStatus.Read,
                    BotPatientId = botPatientId
                },
                new()
                {
                    Content = botResponse.Value.model_msg,
                    CreatedDate = DateTime.UtcNow,
                    ReadAt = DateTime.UtcNow.AddSeconds(1),
                    Status = MessageStatus.Read,
                    BotPatientId = botPatientId
                }
            };


            await unitOfWork.Messages.AddRangeAsync(messages, cancellationToken);

            await unitOfWork.CommitChangesAsync(cancellationToken);

            var response = new MessageResponse(
                messages[1].Id,
                messages[1].Content, 
                messages[1].CreatedDate, 
                messages[1].Status, 
                false);

            await unitOfWork.CommitTransactionAsync(transaction, cancellationToken);
            return Result.Success(response);
        }
        catch(Exception ex)
        {
            // TODO: log error
            logger.LogError(ex, "Exception occurred while sending message. UserId: {UserId}, BotId: {BotId}", request.UserId, request.BotId);
            await unitOfWork.RollbackTransactionAsync(transaction, cancellationToken);
            return Error.BadRequest("SendMessage.Error", "Error occure while sendimg message");
        }
    }
}
