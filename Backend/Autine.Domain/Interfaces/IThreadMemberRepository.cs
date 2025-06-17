
namespace Autine.Domain.Interfaces;

public interface IThreadMemberRepository : IRepository<ThreadMember>
{
    //Task<bool> CheckUserExist(string userId, CancellationToken ct = default);
    //Task<bool> CheckUserInThread(string userId, string threadId, CancellationToken ct = default);
    Task DeleteThreadMemberAsync(Guid threadMemberId, CancellationToken ct = default);
}