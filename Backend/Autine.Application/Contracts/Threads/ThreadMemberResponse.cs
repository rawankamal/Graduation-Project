namespace Autine.Application.Contracts.Threads;

public record ThreadMemberResponse(
    Guid Id,
    string UserId, 
    DateTime CraetedAt
    );


