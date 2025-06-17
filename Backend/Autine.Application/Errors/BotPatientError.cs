namespace Autine.Application.Errors;

public class BotPatientError
{
    public static readonly Error PatientNotFound
        = Error.NotFound($"BotUser.{nameof(PatientNotFound)}", "this patient not found in this bot.");
    
}
