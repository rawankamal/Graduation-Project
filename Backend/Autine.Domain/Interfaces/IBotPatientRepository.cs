using Autine.Domain.Abstractions;

namespace Autine.Domain.Interfaces;
public interface IBotPatientRepository : IRepository<BotPatient>
{
    Task<IEnumerable<Message>> GetMessagesAsync(Guid botPatientId, CancellationToken ct = default);
    Task<Result> DeleteBotPatientAsync(Guid id, CancellationToken ct = default);
}
