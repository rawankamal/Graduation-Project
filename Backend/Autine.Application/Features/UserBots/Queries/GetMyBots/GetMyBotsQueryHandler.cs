using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.UserBots.Queries.GetMyBots;

public class GetMyBotsQueryHandler(
    IBotService botService,
    IUrlGenratorService urlGenratorService) : IQueryHandler<GetMyBotsQuery, IEnumerable<PatientBotsResponse>>
{
    public async Task<Result<IEnumerable<PatientBotsResponse>>> Handle(GetMyBotsQuery request, CancellationToken cancellationToken)
    {
        var botPatients = await botService.GetPatientBotsAsync(request.UserId, cancellationToken);

        var response = botPatients.Select(e => new PatientBotsResponse(
            e.Id,
            e.Name,
            urlGenratorService.GetImageUrl(e.ProfilePic, true)!,
            e.CreateAt)
        );

        return Result.Success(response);
    }
}
