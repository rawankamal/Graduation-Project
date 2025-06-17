using Autine.Application.Contracts.Patients;

namespace Autine.Application.Features.Patients.Queries.GetAll;
public record GetPatientsQuery(string UserId, bool IsFollowing) : IQuery<ICollection<PatientResponse>>;
