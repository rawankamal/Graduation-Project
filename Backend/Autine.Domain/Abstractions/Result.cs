namespace Autine.Domain.Abstractions;
public class Result
{
    public Result(bool isSuccess, Error error)
    {
        if (isSuccess && Error.Non != error || !isSuccess && error == Error.Non)
            throw new InvalidOperationException("There Was An error.");
        IsSuccess = isSuccess;
        Error = error;
    }

    public bool IsSuccess { get; }
    public bool IsFailure => !IsSuccess;
    public Error Error { get; }

    public static Result Success() => new(true, Error.Non);
    public static Result Failure(Error error) => new(false, error);

    public static Result<TValue> Success<TValue>(TValue value) => new(value, true, Error.Non);
    public static Result<TValue> Failure<TValue>(Error error) => new(default, false, error);
}

public class Result<TValue>(TValue? value, bool isSuccess, Error error) : Result(isSuccess, error)
{
    private readonly TValue? _value = value;

    public static implicit operator Result<TValue>(Error error)
        => new(default, false, error);
    public static implicit operator Result<TValue>(TValue value)
        => new(value, true, Error.Non);

    public TValue Value => IsSuccess
        ? _value!
        : throw new InvalidOperationException("");
}
