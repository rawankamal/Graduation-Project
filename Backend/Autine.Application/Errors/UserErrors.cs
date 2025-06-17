namespace Autine.Application.Errors;
public class UserErrors
{
    public static readonly Error InvalidCredinitails
        = Error.Unauthorized(nameof(InvalidCredinitails), "Invalid Email/Password!");

    public static readonly Error DuplicatedEmail
        = Error.Conflict(nameof(DuplicatedEmail), "This email is exists before select another one!");
    
    public static readonly Error DuplicatedUsername
        = Error.Conflict(nameof(DuplicatedUsername), "This Username is exists before select another one!");

    public static readonly Error InvalidCode
        = Error.Unauthorized(nameof(InvalidCode), "Invalid Code");
    
    public static readonly Error EmailNotConfirmed
        = Error.BadRequest(nameof(EmailNotConfirmed), "this email is Not confirmed.");

    public static readonly Error LockedUser
        = Error.Unauthorized(nameof(LockedUser), "Locked User");

    public static readonly Error EmailConfirmed
        = Error.Conflict(nameof(EmailConfirmed), "Email is already confirmed");

    public static readonly Error UserNotFound
        = Error.NotFound(nameof(UserNotFound), "User not found");

    public static readonly Error UserIsDisabled
        = Error.Unauthorized(nameof(UserIsDisabled), "User is disabled contact with adminstrator");

    public static readonly Error InvalidToken
        = Error.Unauthorized($"Users.{InvalidToken}", "invalid token");

    public static readonly Error InvalidPassword
        = Error.Conflict($"User.{nameof(InvalidPassword)}", "this password is used before Select another one.");
}
