namespace Autine.Application.Contracts.Threads;
public record ThreadResponse(
    Guid Id,
    string Title,
    string SupervisorId,
    string PatientId,
    DateTime CraetedAt,
    IList<ThreadMemberResponse> ThreadMembers
    );
