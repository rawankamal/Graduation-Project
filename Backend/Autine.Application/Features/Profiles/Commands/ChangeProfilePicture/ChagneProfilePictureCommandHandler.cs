using Autine.Application.IServices;

namespace Autine.Application.Features.Profiles.Commands.ChangeProfilePicture;

public class ChagneProfilePictureCommandHandler(
    IAccountService accountService) : ICommandHandler<ChagneProfilePictureCommand>
{
    public async Task<Result> Handle(ChagneProfilePictureCommand request, CancellationToken cancellationToken)
    {
        return await accountService.ChangeProfilePictureAsync(request.UserId, request.Image.Image, cancellationToken);
    }
}
