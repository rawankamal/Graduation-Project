namespace Autine.Infrastructure.Persistence.Configurations;

public class PatientConfiguration : IEntityTypeConfiguration<Patient>
{
    public void Configure(EntityTypeBuilder<Patient> builder)
    {
        builder.HasKey(e => e.Id);

        builder.HasOne<ApplicationUser>()
            .WithMany(e => e.Patients)
            .HasForeignKey(e => e.PatientId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne<ApplicationUser>()
            .WithMany(e => e.Supervisors)
            .HasForeignKey(e => e.CreatedBy)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(e => e.IsSupervised)
            .HasDefaultValue(false);

        builder.Property(e => e.Notes)
            .HasMaxLength(10000);

        builder.Property(e => e.Status)
            .HasMaxLength(100);

        builder.Property(e => e.SessionFrequency)
            .HasMaxLength(100);
        
        builder.Property(e => e.Diagnosis)
            .HasMaxLength(100);

        builder.HasIndex(p => new { p.PatientId, p.CreatedBy })
            .IsUnique();
    }
}
