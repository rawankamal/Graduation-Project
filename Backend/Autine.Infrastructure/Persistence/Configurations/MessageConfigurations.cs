namespace Autine.Infrastructure.Persistence.Configurations;

public class MessageConfigurations : IEntityTypeConfiguration<Message>
{
    public void Configure(EntityTypeBuilder<Message> builder)
    {
        builder.HasKey(c => c.Id);

        builder.Property(m => m.Status)
            .HasConversion<int>();

        builder.Property(m => m.Content)
            .HasMaxLength(1000);

        builder.HasOne<ApplicationUser>()
            .WithMany(e => e.Messages)
            .HasForeignKey(e => e.SenderId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(m => m.ChatId)
              .HasFilter($"{nameof(Message.ChatId)} IS NOT NULL")
              .HasDatabaseName("IX_Message_ChatId");

        builder.HasIndex(m => m.ThreadMemberId)
              .HasFilter($"{nameof(Message.ThreadMemberId)} IS NOT NULL")
              .HasDatabaseName("IX_Message_ThreadMemberId");

        builder.HasIndex(m => m.BotPatientId)
              .HasFilter($"{nameof(Message.BotPatientId)} IS NOT NULL")
              .HasDatabaseName("IX_Message_BotPatientId");

        builder.HasIndex(m => m.SenderId)
              .HasFilter($"{nameof(Message.SenderId)} IS NOT NULL")
              .HasDatabaseName("IX_Message_SenderId");

        builder.HasIndex(m => m.CreatedDate)
              .HasDatabaseName("IX_Message_CreatedDate");


        // add contrains 
    }
}
