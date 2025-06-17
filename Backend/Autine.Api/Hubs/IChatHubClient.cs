using Autine.Application.Contracts.UserBots;

namespace Autine.Api.Hubs;

public interface IChatHubClient
{
    Task UserConnected(string message);
    Task UserDisConnected(string message);
    Task OnlineUser(IEnumerable<string> users);
    Task ReceiveMessage(MessageResponse response);
    Task MessageIsReaded();
}