namespace Autine.Application.Errors;

public class ThreadErrors
{
    public static readonly Error ThreadNotFound
        = Error.NotFound($"Thread.{nameof(ThreadNotFound)}", "Thread not found");
    public static readonly Error ThreadAlreadyExists
        = Error.Conflict($"Thread.{nameof(ThreadAlreadyExists)}", "Thread already exists");
}