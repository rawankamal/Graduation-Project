namespace Autine.Infrastructure.Identity.Consts;
public class DefaultRoles
{
    public partial class Admin
    {
        public const string Id = "48de00e1-60c9-4bf5-b352-8ac7f0fb2378";
        public const string Name = nameof(Admin);
        public const string ConcurrencyStamp = "d3bf0710-e616-4ec6-86a8-dc23d6102fc9";
    }
    public partial class User
    {
        public const string Id = "19d94e44-c519-4394-9afc-5000b23b48af";
        public const string Name = nameof(User);
        public const string ConcurrencyStamp = "f65bb7e6-155f-4d22-9bef-a2ae53108647";
    }
    public partial class Doctor
    {
        public const string Id = "5639020e-69be-4b28-a356-fb96a9b4217b";
        public const string Name = nameof(Doctor);
        public const string ConcurrencyStamp = "b5148c07-e1b6-43d7-ae12-d87a99a97679";
    }
    public partial class Parent
    {
        public const string Id = "1a580d6d-eb01-47c0-88d2-82b7481f9d59";
        public const string Name = nameof(Parent);
        public const string ConcurrencyStamp = "a1775b96-3076-4ed7-98d4-e76e0acdb49c";
    }
    public partial class Patient
    {
        public const string Id = "99d1d672-59a7-4ec5-bd44-f7d384a7b2f0";
        public const string Name = nameof(Patient);
        public const string ConcurrencyStamp = "aa71b675-2f16-4f08-a2b7-70417bd49c59";
    }
}
