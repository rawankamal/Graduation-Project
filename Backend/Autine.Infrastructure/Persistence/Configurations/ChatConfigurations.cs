namespace Autine.Infrastructure.Persistence.Configurations;

internal class ChatConfigurations : IEntityTypeConfiguration<Chat>
{
    public void Configure(EntityTypeBuilder<Chat> builder)
    {
        builder.HasKey(c => c.Id);

        builder.HasOne<ApplicationUser>()
            .WithMany()
            .HasForeignKey(cm => cm.UserId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasOne<ApplicationUser>()
            .WithMany()
            .HasForeignKey(cm => cm.CreatedBy)
            .IsRequired()
            .OnDelete(DeleteBehavior.Cascade);


        builder.HasMany(e => e.Messages)
            .WithOne(e => e.Chat)
            .HasForeignKey(e => e.ChatId)
            .OnDelete(DeleteBehavior.Cascade);


        builder.HasIndex(x => new { x.UserId, x.CreatedBy })
            .IsUnique();
    }
}

