namespace Autine.Infrastructure.Persistence.Configurations;

public class ThreadMemberConfigurations : IEntityTypeConfiguration<ThreadMember>
{
    public void Configure(EntityTypeBuilder<ThreadMember> builder)
    {
        builder.HasKey(x => x.Id);

        builder.HasOne<ApplicationUser>()
               .WithMany(u => u.ThreadMember)
               .HasForeignKey(m => m.MemberId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.Thread)
               .WithMany(t => t.Members)
               .HasForeignKey(m => m.ThreadId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Messages)
            .WithOne(e => e.ThreadMember)
            .HasForeignKey(e => e.ThreadMemberId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(t => new { t.ThreadId, t.MemberId })
            .IsUnique();
    }
}
