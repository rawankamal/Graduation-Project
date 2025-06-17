using Autine.Application.Contracts.Chats;

namespace Autine.Application.Features.Messages.Queries.GetChat;
public record GetChatByIdQuery(string UserId, string ReceiverId) : IQuery<DetailedChatResponse>;


