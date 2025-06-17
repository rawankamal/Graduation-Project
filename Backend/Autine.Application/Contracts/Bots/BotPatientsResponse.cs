namespace Autine.Application.Contracts.Bots;

public record BotPatientsResponse(
    string Id,
    string Name,
    DateTime CreateAt,
    string ProfilePic
);
