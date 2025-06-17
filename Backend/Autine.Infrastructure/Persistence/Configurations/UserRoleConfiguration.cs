namespace Autine.Infrastructure.Persistence.Configurations;

public class UserRoleConfiguration : IEntityTypeConfiguration<IdentityUserRole<string>>
{
    public void Configure(EntityTypeBuilder<IdentityUserRole<string>> builder)
    {
        List<IdentityUserRole<string>> userRoles = [
            new IdentityUserRole<string>
            {
                RoleId = DefaultRoles.Admin.Id,
                UserId = DefaultUsers.Admin.Id,
            }
        ];

        builder.HasData(userRoles);
    }
}
