using Autine.Application.Contracts.UserBots;

namespace Autine.Application.Features.UserBots.Queries.GetById;

public class GetBotUserByIdQueryHandler(
    IUnitOfWork unitOfWork,
    IUrlGenratorService urlGenratorService) : IQueryHandler<GetBotUserByIdQuery, UserBotDetailedResponse>
{
    public async Task<Result<UserBotDetailedResponse>> Handle(GetBotUserByIdQuery request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Bots.FindByIdAsync(cancellationToken, [request.BotId]) is not { } bot)
            return BotErrors.BotNotFound;

        bot.BotImage = urlGenratorService.GetImageUrl(bot.BotImage!, true) ?? null;
        var response = new UserBotDetailedResponse(bot.Id, bot.Name, bot.Bio, bot.BotImage!);

        return response;
    }
}

