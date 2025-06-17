using Autine.Application.Contracts.Users;

namespace Autine.Application.Contracts.Threads;

public record ThreadChatMemberResponse(
    Guid Id,
    string UserId, 
    DateTime CraetedAt,
    UserResponse UserResponse
    );