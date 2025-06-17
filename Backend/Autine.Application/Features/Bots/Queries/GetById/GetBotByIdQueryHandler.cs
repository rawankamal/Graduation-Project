using Autine.Application.Contracts.Bots;
using Autine.Application.IServices;

namespace Autine.Application.Features.Bots.Queries.GetById;
public class GetBotByIdQueryHandler(
    IUnitOfWork unitOfWork,
    IUrlGenratorService urlGenratorService,
    IPatientService patientService) : IQueryHandler<GetBotByIdQuery, DetailedBotResponse>
{
    public async Task<Result<DetailedBotResponse>> Handle(GetBotByIdQuery request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Bots.FindByIdAsync(cancellationToken, [request.BotId]) is not { } bot)
            return BotErrors.BotNotFound;

        if (bot.CreatedBy != request.UserId)
            return BotErrors.BotNotFound;

        var patients = await patientService.GetBotPatientAsync(request.BotId, cancellationToken);
        bot.BotImage = urlGenratorService.GetImageUrl(bot.BotImage!, true) ?? null;
        var response = new DetailedBotResponse(
            bot.Id,
            bot.Name,
            bot.Bio,
            bot.Context,
            urlGenratorService.GetImageUrl(bot.BotImage!, true)!,
            bot.CreatedAt,
            [.. patients]
            );

        return response;
    }
}
