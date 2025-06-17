using Autine.Domain.Abstractions;

namespace Autine.Domain.Interfaces;
public interface IBotRepository : IRepository<Bot>
{
    Task<Result> DeleteBotAsync(Guid botId);
}
