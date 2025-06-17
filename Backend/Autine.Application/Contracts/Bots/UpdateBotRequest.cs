namespace Autine.Application.Contracts.Bots;

public record UpdateBotRequest(
    string Name,
    string Context,
    string Bio
);