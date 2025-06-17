using Autine.Application.Contracts.Bots;
using Autine.Application.IServices;

namespace Autine.Application.Features.Bots.Queries.GetPatients;
public class GetBotPatientsQueryHandler(
    IUnitOfWork unitOfWork,
    IPatientService patientService) : IQueryHandler<GetBotPatientsQuery, IEnumerable<BotPatientsResponse>>
{
    public async Task<Result<IEnumerable<BotPatientsResponse>>> Handle(GetBotPatientsQuery request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Bots.FindByIdAsync(cancellationToken, [request.BotId]) is not { } bot)
            return BotErrors.BotNotFound;

        if (bot.CreatedBy!= request.UserId)
            return BotErrors.BotNotFound;

        var patients = await patientService.GetBotPatientAsync(request.BotId, cancellationToken);

        return Result.Success(patients);
    }
}
