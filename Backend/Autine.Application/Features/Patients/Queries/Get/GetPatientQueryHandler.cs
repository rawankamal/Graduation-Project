using Autine.Application.Contracts.Patients;
using Autine.Application.IServices;

namespace Autine.Application.Features.Patients.Queries.Get;
public class GetPatientQueryHandler(IPatientService patientService) : IQueryHandler<GetPatientQuery, PatientResponse>
{
    public async Task<Result<PatientResponse>> Handle(GetPatientQuery request, CancellationToken cancellationToken)
    {
        if (await patientService.GetPatientByIdAsync(request.UserId, request.Id, ct: cancellationToken) is not { } patient)
            return PatientErrors.PatientsNotFound;

        return patient;
    }
}
