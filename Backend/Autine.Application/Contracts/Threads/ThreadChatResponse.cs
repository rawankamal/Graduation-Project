namespace Autine.Application.Contracts.Threads;

public record ThreadChatResponse(
    Guid Id, 
    string ThreadTitle,
    IEnumerable<ThreadMessageResponse> Messages
    );