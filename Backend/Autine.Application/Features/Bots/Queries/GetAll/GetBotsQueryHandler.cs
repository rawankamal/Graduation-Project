using Autine.Application.Contracts.Bots;
using Autine.Application.IServices;

namespace Autine.Application.Features.Bots.Queries.GetAll;
public class GetBotsQueryHandler(
    IUnitOfWork unitOfWork,
    IPatientService patientService,
    IUrlGenratorService urlGenratorService) : IQueryHandler<GetBotsQuery, ICollection<BotResponse>>
{
    public async Task<Result<ICollection<BotResponse>>> Handle(GetBotsQuery request, CancellationToken cancellationToken)
    {
        var bots = await unitOfWork.Bots.GetAllAsync(
            e => e.CreatedBy == request.UserId,
            ct: cancellationToken);

        var response = new List<BotResponse>();
        foreach (var b in bots) {
            IEnumerable<BotPatientsResponse> botPatients;

            if (b.BotPatients is not null) 
            {
                botPatients = await patientService.GetBotPatientAsync(b.Id, cancellationToken);
            }
            else
            {
                botPatients = [];
            }
            var bot = new BotResponse(
                Id: b.Id,
                Name: b.Name,
                Bio: b.Bio,
                Context: b.Context,
                Image: urlGenratorService.GetImageUrl(b.BotImage!, true)!,
                Patients: botPatients?.ToList() ?? []
                );

            response.Add(bot);

        }


        return response.ToList();
    }
}