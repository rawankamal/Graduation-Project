using Microsoft.EntityFrameworkCore.Query;
using System.Linq.Expressions;

namespace Autine.Domain.Interfaces;
public interface IRepository<T> where T : class
{

    Task<Guid> AddAsync(T entity, CancellationToken ct = default);
    Task AddRangeAsync(IEnumerable<T> entities, CancellationToken ct = default);
    void Update(T entity);
    Task<int> ExcuteUpdateAsync(Expression<Func<T, bool>> predicate, Expression<Func<SetPropertyCalls<T>, SetPropertyCalls<T>>> setPropertyCall, CancellationToken ct = default);
    void Delete(T entity);
    Task DeleteByIdAsync(CancellationToken ct = default, params object[] keyValues);
    Task<bool> CheckExistAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default);
    Task<T> FindByIdAsync(CancellationToken ct = default, params object[] keyValues);
    Task<T> GetAsync(Expression<Func<T, bool>> predicate, string? includes = null, bool tracked = false, CancellationToken ct = default);
    Task<IEnumerable<T>> GetAllAsync(Expression<Func<T, bool>> predicate, string? includes = null, bool tracked = false, CancellationToken ct = default);
}
