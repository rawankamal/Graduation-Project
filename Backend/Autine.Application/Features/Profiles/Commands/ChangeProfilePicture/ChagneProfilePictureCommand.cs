using Autine.Application.Contracts.Files;

namespace Autine.Application.Features.Profiles.Commands.ChangeProfilePicture;
public record ChagneProfilePictureCommand(string UserId, ImageRequest Image) : ICommand;
