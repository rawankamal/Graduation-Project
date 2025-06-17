using Autine.Application.Contracts.UserBots;
using Autine.Application.Features.Messages.Commands;
using Autine.Application.Features.Messages.Queries.GetConnections;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Caching.Hybrid;
using System.Collections.Concurrent;

namespace Autine.Api.Hubs;
[Authorize]
public class ChatHub(
    HybridCache _cache,
    ISender _sender) : Hub<IChatHubClient>
{
    private const string _key = "online-users";
    private async Task<HashSet<string>> GetContactsUserIds(string userId)
    {
        var command = new GetUserConnectionsQuery(userId);
        var result = await _sender.Send(command);

        return result.IsSuccess ? [.. result.Value] : [];
    }
    private async Task<ConcurrentDictionary<string, HashSet<string>>> LoadCurrentAsync()
    {
        var data = await _cache.GetOrCreateAsync(
            _key,
            factory: async (ct) => await Task.FromResult(new ConcurrentDictionary<string, HashSet<string>>())
            );

        return data;
    }
        
    public override async Task OnConnectedAsync()
    {
        var userId = Context.UserIdentifier!;
        var connId = Context.ConnectionId!;
        var contacts = await GetContactsUserIds(userId);
        contacts.Add(userId);
        var online = await LoadCurrentAsync();

        online.AddOrUpdate(
            userId,
            _ => [connId],
            (_, set) =>
            {
                lock (set)
                {
                    set.Add(connId);
                }
                return set;
            });

        await _cache.SetAsync(_key, online);

        var myOnlineConnections = online.Keys.Intersect(contacts);
        await Clients.Users(myOnlineConnections).OnlineUser(myOnlineConnections);

        await base.OnConnectedAsync();
    }
    public async Task SendMessage(UserMessageRequest request)
    {
        var userId = Context.UserIdentifier!;

        var command = new SendDMCommand(userId, request.ReceiverId, request.Content);
        var result = await _sender.Send(command);

        if (result.IsSuccess)
        {
            await Clients.User(request.ReceiverId).ReceiveMessage(result.Value);
            await Clients.Caller.ReceiveMessage(result.Value);
        }

    }
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.UserIdentifier!;
        var connId = Context.ConnectionId;

        var contacts = await GetContactsUserIds(userId);

        var online = await LoadCurrentAsync();

        if (online.TryGetValue(userId, out var set))
        {
            lock(set)
            {
                set.Remove(connId);
            }

            if (set.Count == 0)
                online.TryRemove(userId, out _);
        }
        await _cache.SetAsync(_key, online);

        if (online.ContainsKey(userId))
        {
            var myOnlineConnections = online.Keys.Intersect(contacts);
            await Clients.Users(myOnlineConnections).OnlineUser(myOnlineConnections);

        }
        
        await base.OnDisconnectedAsync(exception);
    }
}
