using Autine.Application.Contracts.Chats;

namespace Autine.Application.Features.Messages.Queries.GetChats;

public record GetChatsQuery(string UserId) : IQuery<IEnumerable<ChatResponse>>;
