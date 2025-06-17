namespace Autine.Infrastructure.Repositories;
public class PatientRepository(ApplicationDbContext context) : Repository<Patient>(context), IPatientRespository
{
    public async Task<IEnumerable<Patient>> ArePatientsAsync(IList<string> ids, CancellationToken ct = default)
    {
        var patients = await _context.Patients
            .Where(e => ids.Contains(e.PatientId))
            .ToListAsync(ct);

        return ids.Count == patients.Count ? patients : Enumerable.Empty<Patient>();
    }
    public async Task<IEnumerable<Patient>> GetAllThreads(string userId, CancellationToken ct = default)
        => await _context.ThreadMembers
            .Where(e => e.MemberId == userId)
            .Join(_context.Patients,
                tm => tm.ThreadId,
                p => p.Id,
                (tm, p) => new Patient()
                {
                    Id = p.Id,
                    PatientId = p.PatientId,
                    IsSupervised = p.IsSupervised,
                    ThreadTitle = p.ThreadTitle,
                    CreatedAt = p.CreatedAt,
                    CreatedBy = p.CreatedBy
                }
            ).ToListAsync(ct);
    public async Task<Patient?> GetThreadByIdAsync(Guid id, CancellationToken ct = default)
    {
        var thread = await _context.Patients
            .Include(e => e.Members)
            .SingleOrDefaultAsync(e => e.Id == id, ct) ?? null!;

        return thread;
    }
}