namespace Autine.Infrastructure.Persistence.Configurations;

public class BotConfigurations : IEntityTypeConfiguration<Bot>
{
    public void Configure(EntityTypeBuilder<Bot> builder)
    {
        builder.HasKey(c => c.Id);

        builder.HasOne<ApplicationUser>()
           .WithMany(u => u.Bots)
           .HasForeignKey(b => b.CreatedBy)
           .OnDelete(DeleteBehavior.Restrict);


        builder.Property(b => b.Name)
           .IsRequired()
           .HasMaxLength(100);
        
        builder.Property(b => b.BotImage)
           .HasMaxLength(1000);

        builder.Property(b => b.Context)
         .IsRequired();

        builder.Property(b => b.Bio)
           .IsRequired()
           .HasMaxLength(10000);

        builder.Property(b => b.CreatedAt)
          .IsRequired();
    }

}
