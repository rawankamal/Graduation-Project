using Microsoft.AspNetCore.Identity;

namespace Autine.Infrastructure.Persistence.Configurations;

public class UserConfigurations : IEntityTypeConfiguration<ApplicationUser>
{
    public void Configure(EntityTypeBuilder<ApplicationUser> builder)
    {
        builder.Property(e => e.FirstName)
            .HasMaxLength(100);
        builder.Property(e => e.LastName)
            .HasMaxLength(100);

        builder.Property(e => e.Bio)
            .HasMaxLength(2500);

        builder.Property(e => e.Gender)
            .HasMaxLength(100);

        builder.Property(e => e.ProfilePicture)
            .HasMaxLength(1000);

        builder.Property(e => e.Country)
            .HasMaxLength(100);

        builder.Property(e => e.City)
            .HasMaxLength(100);

        builder.OwnsMany(e => e.RefreshTokens)
            .ToTable("RefreshTokens")
            .WithOwner()
            .HasForeignKey("UserId");

        var users = new List<ApplicationUser>
        {
            new()
            {
                Id = DefaultUsers.Admin.Id,
                FirstName = DefaultUsers.Admin.FirstName,
                LastName = DefaultUsers.Admin.LastName,
                Bio = DefaultUsers.Admin.LastName,
                ProfilePicture = "none",
                Gender = "male",
                DateOfBirth = new DateTime(2025, 2, 27),
                Country = "Egypt",
                City = "Kafr elsheikh",
                UserName = DefaultUsers.Admin.UserName,
                NormalizedUserName = DefaultUsers.Admin.UserName.ToUpper(),
                Email = DefaultUsers.Admin.Email,
                NormalizedEmail = DefaultUsers.Admin.Email.ToUpper(),
                EmailConfirmed = true,
                SecurityStamp = DefaultUsers.Admin.SecurityStamp,
                ConcurrencyStamp = DefaultUsers.Admin.ConcurrencyStamp,
                PasswordHash = "AQAAAAIAAYagAAAAEBbWjL8coqX4W28rbExSdO9oxmhKHv6wM4FPUC7EA+NPus+zl7GH7agHyr/+5JzfJQ=="
            },
            new()
            {
                Id = DefaultUsers.AnonymousUser.Id,
                FirstName = DefaultUsers.AnonymousUser.FirstName,
                LastName = DefaultUsers.AnonymousUser.LastName,
                Bio = DefaultUsers.AnonymousUser.LastName,
                ProfilePicture = "none",
                Gender = "male",
                DateOfBirth = new DateTime(2025, 2, 27),
                Country = "Egypt",
                City = "Kafr elsheikh",
                UserName = DefaultUsers.AnonymousUser.UserName,
                NormalizedUserName = DefaultUsers.AnonymousUser.UserName.ToUpper(),
                Email = DefaultUsers.AnonymousUser.Email,
                NormalizedEmail = DefaultUsers.AnonymousUser.Email.ToUpper(),
                EmailConfirmed = true,
                SecurityStamp = DefaultUsers.AnonymousUser.SecurityStamp,
                ConcurrencyStamp = DefaultUsers.AnonymousUser.ConcurrencyStamp,
                PasswordHash = "AQAAAAIAAYagAAAAENM3gPuLzFgxltA0DcYSDrTPi1XWJhEkzbxXO6/EAxO9qqTV6hBNn1GSHo0VmGJT1A=="

            }
        };

        builder.HasData(users);
    }
}