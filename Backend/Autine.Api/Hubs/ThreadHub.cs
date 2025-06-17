using Autine.Application.Contracts.Threads;
using Autine.Application.Contracts.Users;
using Autine.Application.Features.ThreadMember.Queries.GetAll;
using Autine.Application.Features.Threads.Commands.SendMessage;
using Autine.Application.Features.Threads.Queries.GetAll;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Net.Http.Headers;
using System.Collections.Concurrent;
using System.Threading;

namespace Autine.Api.Hubs;
public class ThreadConnection
{
    public string UserId { get; set; } =string.Empty;
    public string ConnectionId { get; set; } = string.Empty;
    public HashSet<Guid> JoinedThreads { get; set; } = [];
}

[Authorize(Roles = $"{DefaultRoles.Parent.Name}, {DefaultRoles.Doctor.Name}")]
public class ThreadHub(ISender _sender) : Hub<IThreadHubClient>
{
    //private static readonly ConcurrentDictionary<string, HashSet<Guid>> _userThreads = new();
    private static readonly ConcurrentDictionary<string, ThreadConnection> _connections = new();
    private static readonly ConcurrentDictionary<Guid, HashSet<string>> _threadConnections = new();

    private async Task<IEnumerable<ThreadResponse>> GetThreadAsync (string userId, CancellationToken ct = default)
    {
        var query = new GetThreadsQuery(userId);
        var result = await _sender.Send(query, ct);

        if (result.IsFailure)
            return default!;
        

        return result.Value ?? [];
    }
    private async Task<IEnumerable<ThreadChatMemberResponse>> GetThreadMemberAsync(Guid threadId, CancellationToken ct = default)
    {
        var query = new GetThreadMembersQuery(threadId);
        var result = await _sender.Send(query, ct);
        if (result.IsFailure)
            return default!;
        return result.Value ?? [];
    }
    private async Task<ThreadResponse> GetThreadAsync(Guid threadId,string userId, CancellationToken ct = default)
    {
        var threads = await GetThreadAsync(userId, ct);

        return threads.FirstOrDefault(x => x.Id == threadId) ?? default!;
    }
    public async Task JoinThread(Guid threadId)
    {
        var userId = Context.UserIdentifier!;
        var connectionId = Context.ConnectionId!;

        if (!_connections.TryGetValue(connectionId, out ThreadConnection? threadConnection))
        {
            threadConnection = new ThreadConnection
            {
                UserId = userId,
                ConnectionId = connectionId
            };
            _connections[connectionId] = threadConnection;
        }

        threadConnection.JoinedThreads.Add(threadId);
        if (!_threadConnections.TryGetValue(threadId, out HashSet<string>? value))
        {
            _threadConnections[threadId] = value = [];
        }

        value.Add(threadConnection.UserId);

        await Groups.AddToGroupAsync(Context.ConnectionId, threadId.ToString());

        var threadMembers = await GetThreadMemberAsync(threadId);
        var connectedMembersCount = _threadConnections.TryGetValue(threadId, out var members) ? members.Count : 0;
        var connectMembersIds = _threadConnections.TryGetValue(threadId, out var memberIds) ? memberIds : [];
        var threadInfo = await GetThreadAsync(threadId, threadConnection.UserId);
        var connectedMember = threadMembers
            .Where(x => connectMembersIds.Contains(x.UserId))
            .ToList();

        var joinedMember = threadMembers.FirstOrDefault(x => x.UserId == threadConnection.UserId)!;

        var threadJoinedResponse = new ThreadJoinResponse(
            Id: threadId,
            Title: threadInfo.Title,
            ConnectedMemberCount: connectedMembersCount,
            OnlineMember: connectedMember
        );
        var memberJoinedResponse = new MemberJoinedResponse(
            Member: new ThreadChatMemberResponse(
                Id: joinedMember.Id,
                UserId: joinedMember.UserId,
                CraetedAt: joinedMember.CraetedAt,
                UserResponse: joinedMember.UserResponse
            ),
            OnlineMember: connectedMember,
            ConnectedMembersCount: connectedMembersCount
        );

        await Clients.Caller.ThreadJoined(threadJoinedResponse);
        await Clients.OthersInGroup(threadId.ToString()).MemberJoined(memberJoinedResponse);
    }
    private async Task LeaveThread(Guid threadId)
    {
        var userId = Context.UserIdentifier!;

        if (_connections.TryGetValue(Context.ConnectionId, out var threadConnection))
        {
            threadConnection.JoinedThreads.Remove(threadId);

            if (_threadConnections.TryGetValue(threadId, out HashSet<string>? value))
            {
                value.Remove(userId);

                if (_threadConnections[threadId].Count == 0)
                {
                    _threadConnections.TryRemove(threadId, out _);
                }
            }

            if (threadConnection.JoinedThreads.Count == 0)
            {
                _connections.TryRemove(Context.ConnectionId, out _);
            }

            var remainingMembers = _threadConnections.ContainsKey(threadId) ? _threadConnections[threadId].Count : 0;
            var remainigMembersIds = _threadConnections.ContainsKey(threadId) ? _threadConnections[threadId] : [];
            var threadMembers = await GetThreadMemberAsync(threadId);
            var threadInfo = await GetThreadAsync(threadId, userId);
            var onlineMember = threadMembers.Where(e => remainigMembersIds.Contains(e.UserId)).ToList();
            var memberLeft = threadMembers
                .Where(e => e.UserId == userId)
                .FirstOrDefault()!;
            var memberLeftResponse = new MemberJoinedResponse(
                Member: new ThreadChatMemberResponse(
                    memberLeft.Id,
                    memberLeft.UserId,
                    memberLeft.CraetedAt,
                    memberLeft.UserResponse
                    ),
                OnlineMember: onlineMember,
                remainingMembers
                );

            await Groups.RemoveFromGroupAsync(Context.ConnectionId, threadId.ToString());
            await Clients.Group(threadId.ToString()).MemberLeft(memberLeftResponse);
        }
    }
    public override async Task OnConnectedAsync()
    {
        _connections[Context.ConnectionId] = new ThreadConnection
        {
            UserId = Context.UserIdentifier!,
            ConnectionId = Context.ConnectionId
        };
        
        await base.OnConnectedAsync();
    }
    public async Task SendMessage(ThreadChatMessageRequest threadChatMessageRequest)
    {
        var userId = Context.UserIdentifier!;

        if (!_connections.TryGetValue(Context.ConnectionId, out var threadConnection))
            return;

        
        var command = new SendMessageCommand(userId, threadChatMessageRequest.ThreadId, threadChatMessageRequest.Content);
        var result = await _sender.Send(command);

        if (result.IsFailure)
            return;

        var threadMessageCaller = new ThreadMessageResponse(
            Id: result.Value.Id,
            Content: result.Value.Content,
            Timestamp: result.Value.Timestamp,
            Status: result.Value.Status,
            Member: result.Value.Member,
            Direction: true
        );

        var remainingMembers = _threadConnections.TryGetValue(threadChatMessageRequest.ThreadId, out HashSet<string>? value) ? value.Count : 0;

        await Clients.Group(threadChatMessageRequest.ThreadId.ToString()).ReceiveMessage(result.Value, remainingMembers);
        await Clients.Caller.ReceiveMessage(threadMessageCaller, remainingMembers);
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (_connections.TryGetValue(Context.ConnectionId, out var threadConnection))
        {
            foreach (var threadTitle in threadConnection.JoinedThreads.ToList())
            {
                await LeaveThread(threadTitle);
            }
        }

        await base.OnDisconnectedAsync(exception);
    }
}
public record ThreadJoinResponse(
    Guid Id,
    string Title,
    int ConnectedMemberCount,
    List<ThreadChatMemberResponse> OnlineMember
    );

public record MemberJoinedResponse(
    ThreadChatMemberResponse Member,
    List<ThreadChatMemberResponse> OnlineMember,
    int ConnectedMembersCount
    );

public record ThreadChatMessageRequest (
    Guid ThreadId,
    string Content
    );

public interface IThreadHubClient
{
    Task ThreadJoined(ThreadJoinResponse threadJoinResponse);
    Task MemberJoined(MemberJoinedResponse response);
    Task MemberLeft(MemberJoinedResponse response);
    Task ReceiveMessage(ThreadMessageResponse message, int onlineUsersCount);
    Task ThreadMessages(string threadTitle, List<ThreadMessageResponse> messages);
}
