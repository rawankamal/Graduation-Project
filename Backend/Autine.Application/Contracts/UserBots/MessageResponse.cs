namespace Autine.Application.Contracts.UserBots;
public record MessageResponse(
    Guid Id,
    string Content,
    DateTime Timestamp,
    MessageStatus Status,
    bool Direction
    );
