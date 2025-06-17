namespace Autine.Application.Contracts.Bots;

public record PatientBotsResponse(
    Guid Id,
    string Name,
    string ProfilePic,
    DateTime CreateAt
);