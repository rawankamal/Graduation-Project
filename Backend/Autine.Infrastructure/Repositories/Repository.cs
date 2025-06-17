using Microsoft.EntityFrameworkCore.Query;
using System.Linq.Expressions;

namespace Autine.Infrastructure.Repositories;

public class Repository<T> : IRepository<T> where T : class
{
    protected readonly ApplicationDbContext _context;
    private readonly DbSet<T> _dbSet;

    public Repository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _dbSet = _context.Set<T>();
    }
    public async Task<Guid> AddAsync(T entity, CancellationToken ct = default)
    {
        await _dbSet.AddAsync(entity, ct);
        await _context.SaveChangesAsync(ct);

        return Guid.Empty;
    }
    public async Task AddRangeAsync(IEnumerable<T> entities, CancellationToken ct = default)
    {
        await _dbSet.AddRangeAsync(entities, ct);
    }

    public void Update(T entity)
    {
        _dbSet.Attach(entity);
        _context.Entry(entity).State = EntityState.Modified;
    }

    public void Delete(T entity)
    {
        if (_context.Entry(entity).State == EntityState.Detached)
        {
            _dbSet.Attach(entity);
        }
        _dbSet.Remove(entity);
    }
    public async Task<int> ExcuteUpdateAsync(Expression<Func<T, bool>> predicate, Expression<Func<SetPropertyCalls<T>, SetPropertyCalls<T>>> setPropertyCall, CancellationToken ct = default)
    {
        var row = await _dbSet.Where(predicate).ExecuteUpdateAsync(setPropertyCall, ct);

        return row;
    }

    public async Task DeleteByIdAsync(CancellationToken ct = default, params object[] keyValues)
    {
        var entity = await _dbSet.FindAsync(keyValues, ct);

        if (entity != null)
        {
            Delete(entity);
        }
    }
    public async Task<bool> CheckExistAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default)
    {
        return await _dbSet.AnyAsync(predicate, ct);
    }
    public async Task<T> FindByIdAsync(CancellationToken ct = default, params object[] keyValues)
    {
        return await _dbSet.FindAsync(keyValues, ct) ?? null!;
    }
    public async Task<T> GetAsync(Expression<Func<T, bool>> predicate, string? includes = null, bool tracked = false, CancellationToken ct = default)
    {

        var query = getIQeryable(predicate, includes, tracked);

        return await query.FirstOrDefaultAsync(ct) ?? null!;
    }
    public async Task<IEnumerable<T>> GetAllAsync(Expression<Func<T, bool>> predicate, string? includes = null, bool tracked = false, CancellationToken ct = default)
    {
        var query = getIQeryable(predicate, includes, tracked);

        return await query.ToListAsync(ct) ?? null!;
    }
    

    private IQueryable<T> getIQeryable(Expression<Func<T, bool>> predicate, string? includes, bool tracked = false)
    {
        IQueryable<T> query = _dbSet;

        if (predicate is not null)
            query = query.Where(predicate);

        if (includes is not null)
        {
            var includeProperties = includes.Split(',', StringSplitOptions.RemoveEmptyEntries);

            foreach (var include in includeProperties)
                query = query.Include(include);
        }

        if (!tracked)
            query = query.AsNoTracking();

        return query;
    }
}
