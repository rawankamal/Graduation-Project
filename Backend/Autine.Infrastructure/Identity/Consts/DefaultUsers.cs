namespace Autine.Infrastructure.Identity.Consts;

public class DefaultUsers
{
    public partial class Admin
    {
        public const string Id = "019409bf-3ae7-7cdf-995b-db4620f2ff5f";
        public const string SecurityStamp = "019409c1-af2c-7e25-bc46-da6e10412d65";
        public const string ConcurrencyStamp = "019409C1-DB8B-7B6F-A8A1-8E35FB4D0748";
        public const string Email = "admin@autine.com";
        public const string UserName = "admin";
        public const string Password = "P@ssword123";
        public const string FirstName = "Autine";
        public const string LastName = "Admin";
    }

    public partial class AnonymousUser
    {
        public const string Id = "e91025e5-5eb4-4ba3-a669-70d69acb77a1";
        public const string SecurityStamp = "8c817ccb-f1cb-42fb-a039-45ba6634ae65";
        public const string ConcurrencyStamp = "FDF489E9-610F-4C4F-B560-6A6C6DC3D212";
        public const string Email = "anonymous@anonymous.com";
        public const string UserName = "anonymous";
        public const string Password = "P@ssword123";
        public const string FirstName = "Autine";
        public const string LastName = "Anonymous";
    }
}
