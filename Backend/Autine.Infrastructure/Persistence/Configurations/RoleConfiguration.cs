namespace Autine.Infrastructure.Persistence.Configurations;
public class RoleConfiguration : IEntityTypeConfiguration<IdentityRole>
{
    public void Configure(EntityTypeBuilder<IdentityRole> builder)
    {
        List<IdentityRole> roles = [
            new IdentityRole
            {
                Id = DefaultRoles.User.Id,
                Name = DefaultRoles.User.Name,
                ConcurrencyStamp = DefaultRoles.User.ConcurrencyStamp,
                NormalizedName = DefaultRoles.User.Name.ToUpper()
            },
            new IdentityRole
            {
                Id = DefaultRoles.Admin.Id,
                Name = DefaultRoles.Admin.Name,
                ConcurrencyStamp = DefaultRoles.Admin.ConcurrencyStamp,
                NormalizedName = DefaultRoles.Admin.Name.ToUpper()
            },
            new IdentityRole
            {
                Id = DefaultRoles.Doctor.Id,
                Name = DefaultRoles.Doctor.Name,
                ConcurrencyStamp = DefaultRoles.Doctor.ConcurrencyStamp,
                NormalizedName = DefaultRoles.Doctor.Name.ToUpper()
            },
            new IdentityRole
            {
                Id = DefaultRoles.Parent.Id,
                Name = DefaultRoles.Parent.Name,
                ConcurrencyStamp = DefaultRoles.Parent.ConcurrencyStamp,
                NormalizedName = DefaultRoles.Parent.Name.ToUpper()
            },
            new IdentityRole
            {
                Id = DefaultRoles.Patient.Id,
                Name = DefaultRoles.Patient.Name,
                ConcurrencyStamp = DefaultRoles.Patient.ConcurrencyStamp,
                NormalizedName = DefaultRoles.Patient.Name.ToUpper()
            },
        ];

        builder.HasData(roles);

    }
}
