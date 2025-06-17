using Autine.Application.Contracts.Users;

namespace Autine.Application.Contracts.Threads;
public record ThreadMessageResponse(
    Guid Id,
    string Content,
    DateTime Timestamp,
    MessageStatus Status,
    UserResponse Member,
    bool Direction
    );
