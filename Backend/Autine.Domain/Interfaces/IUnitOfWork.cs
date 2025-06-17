using Microsoft.EntityFrameworkCore.Storage;

namespace Autine.Domain.Interfaces;
public interface IUnitOfWork : IDisposable
{
    IRepository<T> GetRepository<T>() where T : class;
    IPatientRespository Patients { get; }
    IChatRepository Chats { get; }
    IThreadMemberRepository ThreadMembers { get; }
    IBotRepository Bots { get; }
    IBotPatientRepository BotPatients { get; }
    IMessageRepository Messages { get; }
    Task CommitChangesAsync(CancellationToken ct = default);
    Task<IDbContextTransaction> BeginTransactionAsync(CancellationToken cancellationToken = default);
    Task CommitTransactionAsync(IDbContextTransaction transaction, CancellationToken cancellationToken = default);
    Task RollbackTransactionAsync(IDbContextTransaction transaction, CancellationToken cancellationToken = default);
}