using Autine.Application.Contracts.UserBots;
using Autine.Application.Features.Auth.Commands.Register;
using Autine.Application.IServices;
using Microsoft.Extensions.Logging;

namespace Autine.Application.Features.Messages.Commands;

public class SendDMCommandHandler(
    IUnitOfWork unitOfWork,
    IRoleService roleService,
    ILogger<SendDMCommandHandler> logger) : ICommandHandler<SendDMCommand, MessageResponse>
{
    public async Task<Result<MessageResponse>> Handle(SendDMCommand request, CancellationToken ct)
    {
        if (!await roleService.UserIsSupervisorAsync(request.RecieverId))
            return UserErrors.UserNotFound;

        var n = string.CompareOrdinal(request.UserId, request.RecieverId) > 0;
        var userId = n ? request.UserId : request.RecieverId;
        var memberId = !n ? request.UserId : request.RecieverId;

        var chat = await unitOfWork.Chats.GetAsync(e => e.CreatedBy == userId && e.UserId == memberId, ct: ct);

        var transaction = await unitOfWork.BeginTransactionAsync(ct);
        try
        {
            logger.LogInformation("Sending DM from {SenderId} to {ReceiverId}", request.UserId, request.RecieverId);
            var chatId = Guid.Empty;
            if (chat == null)
            {
                logger.LogInformation("Creating new chat between {UserId1} and {UserId2}", request.UserId, request.RecieverId);
                chat = new Chat
                {
                    CreatedBy = userId,
                    UserId = memberId
                };
                await unitOfWork.Chats.AddAsync(chat, ct);
                chatId = chat.Id;
            }
            else
            {
                chatId = chat.Id;
            }

            var userMessage = new Message
            {
                Content = request.Content,
                ChatId = chatId,
                SenderId = request.UserId
            };

            await unitOfWork.Messages.AddAsync(userMessage, ct);

            var response = new MessageResponse(
                userMessage.Id,
                userMessage.Content,
                userMessage.CreatedDate,
                userMessage.Status,
                true
                );

            logger.LogInformation("Message sent successfully. MessageId: {MessageId}", userMessage.Id);
            await unitOfWork.CommitTransactionAsync(transaction, ct);
            return response;
        }
        catch( Exception ex ) 
        {
            // TODO: log error
            logger.LogError(ex, "Error occurred while sending DM from {SenderId} to {ReceiverId}", request.UserId, request.RecieverId);
            await unitOfWork.RollbackTransactionAsync(transaction, ct);
            return Error.BadRequest("Error.SendMessage", "error while sending message.");
        }
    }
}
