namespace Autine.Application.Contracts.Chats;
public record ChatResponse(
    Guid Id,
    string UserId,
    DateTime CreatedAt
    );
