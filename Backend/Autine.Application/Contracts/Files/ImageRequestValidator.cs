using Microsoft.AspNetCore.Http.Metadata;

namespace Autine.Application.Contracts.Files;
public class ImageRequestValidator : AbstractValidator<ImageRequest>
{
    public ImageRequestValidator()
    {
        RuleFor(e => e.Image)
            .SetValidator(new ImageValidator());
    }
}
