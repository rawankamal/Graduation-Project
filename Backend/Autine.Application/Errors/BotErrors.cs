namespace Autine.Application.Errors;

public class BotErrors
{
    public static readonly Error BotNotFound
        = Error.NotFound($"Bot.{nameof(BotNotFound)}", "Bot not found");

    public static readonly Error DuplicatedBot
        = Error.Conflict($"Bot.{nameof(DuplicatedBot)}", "Bot name is exit select another name.");

    public static readonly Error InvalidBot
        = Error.BadRequest($"Bot.{nameof(InvalidBot)}", "Only patient can access private bots.");
}
