using Autine.Application.Contracts.UserBots;
namespace Autine.Application.Features.UserBots.Queries.GetMessages;
public class GetChatBotsQueryHandler(
    IUnitOfWork unitOfWork,
    IUrlGenratorService urlGenratorService) : IQueryHandler<GetChatBotsQuery, ChatResponse>
{
    public async Task<Result<ChatResponse>> Handle(GetChatBotsQuery request, CancellationToken cancellationToken)
    {
        var botPatient = await unitOfWork.BotPatients
            .GetAsync(e => e.UserId == request.UserId && e.BotId == request.BotId,
            includes: "Bot",
            ct: cancellationToken);
        
        var messages = await unitOfWork.BotPatients.GetMessagesAsync(botPatient.Id, cancellationToken);

        if (messages is null || !messages.Any())
            return BotErrors.BotNotFound;

        var result = messages.Select(m => new MessageResponse(
            m.Id,
            m.Content,
            m.CreatedDate,
            m.Status,
            m.SenderId != null
            )).ToList();

        var response = new ChatResponse(
            botPatient.Bot.Id, 
            botPatient.Bot.Name,
            urlGenratorService.GetImageUrl(botPatient.Bot.BotImage!, true)!,
            botPatient.CreatedAt, 
            result
            );


        return response;
    }
}