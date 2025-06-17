namespace Autine.Infrastructure.Repositories;
public class ThreadMemberRepository(ApplicationDbContext context) : Repository<ThreadMember>(context), IThreadMemberRepository
{
    public new async Task<Guid> AddAsync(ThreadMember entity, CancellationToken ct = default)
    {
        await _context.ThreadMembers.AddAsync(entity, ct);
        await _context.SaveChangesAsync(ct);
        return entity.Id;
    }
    public async Task DeleteThreadMemberAsync(Guid threadMemberId, CancellationToken ct = default)
    {
        if (await _context.ThreadMembers.AnyAsync(e => e.Id == threadMemberId, ct))
            return;

        var threadMember = await _context.Messages
            .Where(e => e.Id == threadMemberId)
            .FirstOrDefaultAsync(ct);


        var afRows = await _context.ThreadMembers
            .Where(e => e.Id == threadMemberId)
            .ExecuteUpdateAsync(st => st
                .SetProperty(e => e.MemberId, DefaultUsers.AnonymousUser.Id), ct);
    }
}
