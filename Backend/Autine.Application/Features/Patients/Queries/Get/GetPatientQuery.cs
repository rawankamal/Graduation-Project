using Autine.Application.Contracts.Patients;

namespace Autine.Application.Features.Patients.Queries.Get;
public record GetPatientQuery(string UserId, string Id) : IQuery<PatientResponse>;