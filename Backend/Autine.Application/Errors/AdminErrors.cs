namespace Autine.Application.Errors;

public class AdminErrors
{
    public static readonly Error InvalidRole
        = Error.BadRequest($"Admin.{InvalidRole}", "Admin can't assign user to model");
}
