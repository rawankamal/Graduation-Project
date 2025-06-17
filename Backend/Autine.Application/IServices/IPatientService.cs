using Autine.Application.Contracts.Bots;
using Autine.Application.Contracts.Patients;
using Microsoft.EntityFrameworkCore;

namespace Autine.Application.IServices;

public interface IPatientService
{
    Task<IEnumerable<PatientResponse>> GetPatientsAsync(string userId, bool isFollowing = false, CancellationToken ct = default);
    Task<PatientResponse?> GetPatientByIdAsync(string userId, string id, CancellationToken ct = default);
    Task<IEnumerable<BotPatientsResponse>> GetBotPatientAsync(Guid botId, CancellationToken ct = default);
}

