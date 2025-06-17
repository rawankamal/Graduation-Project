using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Logging;

namespace Autine.Infrastructure.Repositories;

public class UnitOfWork(ApplicationDbContext context, ILoggerFactory loggerFactory) : IUnitOfWork
{
    private readonly ApplicationDbContext _context
        = context ?? throw new ArgumentNullException(nameof(context));
    private readonly ILoggerFactory _loggerFactory 
        = loggerFactory ?? throw new ArgumentNullException(nameof(loggerFactory));

    public IRepository<T> GetRepository<T>() where T : class
        => new Repository<T>(_context);
    
    public IPatientRespository Patients
        => new PatientRepository(_context);
    public IChatRepository Chats
        => new ChatRepository(_context);
    
    public IThreadMemberRepository ThreadMembers 
        => new ThreadMemberRepository(_context);
    
    public IBotRepository Bots
        => new BotRepository(_context, _loggerFactory.CreateLogger<BotRepository>());

    public IBotPatientRepository BotPatients 
        => new BotPatientRepository(_context, _loggerFactory.CreateLogger<BotPatientRepository>());

    public IMessageRepository Messages 
        => new MessageRepository(_context);

    private bool _disposed = false;


    public async Task CommitChangesAsync(CancellationToken ct = default)
        => await _context.SaveChangesAsync(ct);

    public async Task<IDbContextTransaction> BeginTransactionAsync(CancellationToken cancellationToken = default)
        => await _context.Database.BeginTransactionAsync(cancellationToken);
    

    public async Task CommitTransactionAsync(IDbContextTransaction transaction, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(transaction);

        try
        {
            await CommitChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
        }
        catch
        {
            await RollbackTransactionAsync(transaction, cancellationToken);
            throw;
        }
    }

    public async Task RollbackTransactionAsync(IDbContextTransaction transaction, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(transaction);

        await transaction.RollbackAsync(cancellationToken);
    }
    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    protected virtual void Dispose(bool disposing)
    {
        if (!_disposed)
        {
            if (disposing)
            {
                _context.Dispose();
            }
            _disposed = true;
        }
    }


}
