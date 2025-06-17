namespace Autine.Application.Features.Bots.Commands.UpdateBotImage;
public record UpdateBotImageCommand(string UserId, IFormFile Image, Guid BotId) : ICommand;
