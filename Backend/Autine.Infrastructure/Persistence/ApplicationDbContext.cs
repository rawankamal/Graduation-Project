using Autine.Infrastructure.Persistence.Configurations;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using System.Security.Claims;


namespace Autine.Infrastructure.Persistence;
public class ApplicationDbContext(
    DbContextOptions<ApplicationDbContext> options,
    IHttpContextAccessor httpContextAccessor) : IdentityDbContext<ApplicationUser>(options)
{
    public DbSet<Patient> Patients { get; set; }
    public DbSet<Bot> Bots { get; set; }
    public DbSet<BotPatient> BotPatients { get; set; }
    public DbSet<ThreadMember> ThreadMembers { get; set; }
    public DbSet<Message> Messages { get; set; }
    public DbSet<Chat> Chats { get; set; }
    
    protected override void OnModelCreating(ModelBuilder builder)
    {
        builder.ApplyConfigurationsFromAssembly(typeof(UserConfigurations).Assembly);

        var cascadeFKs = builder.Model
            .GetEntityTypes()
            .SelectMany(t => t.GetForeignKeys())
            .Where(e => e.DeleteBehavior == DeleteBehavior.Cascade && !e.IsOwnership);

        foreach (var fk in cascadeFKs)
            fk.DeleteBehavior = DeleteBehavior.Restrict;

        base.OnModelCreating(builder);
    }

    public override Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
    {
        var entries = ChangeTracker.Entries<AuditableEntity>();

        var currentUserId = httpContextAccessor.HttpContext?.User?
            .FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;

        foreach (var entry in entries)
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    entry.Entity.CreatedBy = currentUserId;
                    break;
            }
        }

        return base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
    }
}
