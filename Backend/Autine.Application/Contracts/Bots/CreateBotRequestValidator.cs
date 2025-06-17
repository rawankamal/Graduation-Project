namespace Autine.Application.Contracts.Bots;

public class CreateBotRequestValidator : AbstractValidator<CreateBotRequest>
{
    public CreateBotRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .WithMessage("{ProperityName} is required.")
            .MaximumLength(100)
            .WithMessage("{ProperityName} must be at most {MaxLength} characters long.");
        RuleFor(x => x.Context)
            .NotEmpty();

        RuleFor(x => x.Bio)
            .NotEmpty();

        RuleFor(e => e.PatientIds)
            .Must(e =>
            {
                if (e is null)
                    return true;

                foreach (var id in e)
                {
                    if (string.IsNullOrEmpty(id))
                        return false;
                }
                return true;
            }).WithMessage("{PropertyName} cannot contain empty Ids or duplicated patient.");


        //RuleFor(x => x.Image)
        //    .Must(ValidImage)
        //    .WithMessage("{PropertyName} allowed image .jpg, .jpeg, .png, .gif");
    }
    //private static bool ValidImage(IFormFile? image)
    //{
    //    if (image == null)
    //        return true;

    //    const long maxSize = 5 * 1024 * 1024;
    //    if (image.Length > maxSize)
    //        return false;

    //    var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
    //    var extension = Path.GetExtension(image.FileName).ToLowerInvariant();
    //    if (!allowedExtensions.Contains(extension))
    //        return false;

    //    var allowedContentTypes = new[]
    //    {
    //        "image/jpeg",
    //        "image/png",
    //        "image/gif"
    //    };
    //    return allowedContentTypes.Contains(image.ContentType.ToLowerInvariant());
    //}
}
