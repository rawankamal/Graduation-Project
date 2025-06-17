namespace Autine.Application.Errors;

public class BotMessageError
{
    public static readonly Error FailedToSendMessage
        = Error.BadRequest($"Bot.{nameof(FailedToSendMessage)}", "failed to send message");
}