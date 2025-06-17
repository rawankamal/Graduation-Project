using Autine.Application.Contracts.Patients;
using Autine.Application.IServices;

namespace Autine.Application.Features.Patients.Queries.GetAll;
public class GetPatientsQueryHandler(IPatientService patientService) : IQueryHandler<GetPatientsQuery, ICollection<PatientResponse>>
{
    public async Task<Result<ICollection<PatientResponse>>> Handle(GetPatientsQuery request, CancellationToken cancellationToken)
    {
        var respons = await patientService
            .GetPatientsAsync(request.UserId, request.IsFollowing, cancellationToken);

        return respons.ToList();
    }
}
