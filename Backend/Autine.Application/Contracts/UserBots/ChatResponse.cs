namespace Autine.Application.Contracts.UserBots;

public record ChatResponse(
    Guid Id,
    string Name,
    string ProfilePic,
    DateTime CreateAt,
    IList<MessageResponse> Messages
    );