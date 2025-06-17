using Autine.Application.Contracts.UserBots;

namespace Autine.Application.Contracts.Chats;

public record DetailedChatResponse(
    Guid Id,
    string UserId,
    DateTime CreatedAt,
    IEnumerable<MessageResponse> Messages 
    );
