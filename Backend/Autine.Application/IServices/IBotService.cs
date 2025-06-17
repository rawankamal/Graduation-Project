using Autine.Application.Contracts.Bots;

namespace Autine.Application.IServices;

public interface IBotService
{
    Task<IEnumerable<PatientBotsResponse>> GetPatientBotsAsync(string userId, CancellationToken ct = default);
}

