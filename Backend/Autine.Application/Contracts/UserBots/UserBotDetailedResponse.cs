namespace Autine.Application.Contracts.UserBots;

public record UserBotDetailedResponse(
    Guid Id,
    string Name,
    string Bio,
    string ImageUrl
    );