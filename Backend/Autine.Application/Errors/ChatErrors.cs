namespace Autine.Application.Errors;

public class ChatErrors
{
    public static readonly Error UserNotExist
        = Error.NotFound($"Chat.{nameof(UserNotExist)}", "This user not exist");

    public static readonly Error ChatNotFound
        = Error.NotFound($"Chat.{nameof(ChatNotFound)}", "chat not found");

}