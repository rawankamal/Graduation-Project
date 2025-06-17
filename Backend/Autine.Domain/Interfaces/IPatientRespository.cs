using Autine.Domain.Abstractions;

namespace Autine.Domain.Interfaces;
public interface IPatientRespository : IRepository<Patient>
{
    Task<IEnumerable<Patient>> ArePatientsAsync(IList<string> ids, CancellationToken ct = default);
    Task<IEnumerable<Patient>> GetAllThreads(string userId, CancellationToken ct = default);
    Task<Patient?> GetThreadByIdAsync(Guid id, CancellationToken ct = default);
}
