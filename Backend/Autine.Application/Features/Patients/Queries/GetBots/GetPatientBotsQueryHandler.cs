using Autine.Application.Contracts.Bots;

namespace Autine.Application.Features.Patients.Queries.GetBots;
public class GetPatientBotsQueryHandler(IUnitOfWork unitOfWork) : IQueryHandler<GetPatientBotsQuery, IEnumerable<PatientBotsResponse>>
{
    public async Task<Result<IEnumerable<PatientBotsResponse>>> Handle(GetPatientBotsQuery request, CancellationToken cancellationToken)
    {
        if (await unitOfWork.Patients.GetAsync(e => e.PatientId == request.PatientId, ct: cancellationToken) is not { } patient)
            return PatientErrors.PatientsNotFound;

        if (patient.CreatedBy != request.UserId)
            return PatientErrors.PatientsNotFound;

        var bots = await unitOfWork.BotPatients.GetAllAsync(
            e => e.UserId == request.PatientId, 
            includes: nameof(Bot), 
            ct: cancellationToken);


        var response = bots.Select(x => new PatientBotsResponse(
            x.Bot.Id,
            x.Bot.Name,
            "not implemnted yet",
            x.CreatedAt
            ));
        
        return Result.Success(response);
    }
}
