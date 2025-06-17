using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.UserBots.Queries.GetBots;
public record GetAllBotsQuery : IQuery<List<PatientBotsResponse>>;


public class GetAllBotsQueryHandler(
    IUnitOfWork unitOfWork,
    IUrlGenratorService urlGenratorService) : IQueryHandler<GetAllBotsQuery, List<PatientBotsResponse>>
{
    public async Task<Result<List<PatientBotsResponse>>> Handle(GetAllBotsQuery request, CancellationToken cancellationToken)
    {
        var bots = await unitOfWork.Bots.GetAllAsync(e => e.IsPublic, ct: cancellationToken);

        var response = bots
            .Select(e => new PatientBotsResponse(
                e.Id,
                e.Name,
                urlGenratorService.GetImageUrl(e.BotImage!, true)!,
                e.CreatedAt
                ))
            .ToList();

        return Result.Success(response);
    }
}
