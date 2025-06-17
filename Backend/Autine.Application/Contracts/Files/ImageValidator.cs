﻿namespace Autine.Application.Contracts.Files;

public class ImageValidator : AbstractValidator<IFormFile>
{
    public ImageValidator()
    {
        RuleFor(e => e)
            .NotEmpty()
            .Must(file => file != null && file.Length > 0)
            .WithMessage("{PropertyName} cannot be empty.")
            .Must(e => e.Length <= ImageSettings.MaxFileSizeInBytes)
            .WithMessage($"Image can exceed {ImageSettings.MaxFileSizeInBytes}");

        RuleFor(e => e)
            .Must(BeValidImage)
            .WithMessage("{PropertyName} allowed image .jpg, .jpeg, .png, .gif");
    }
    private bool BeValidImage(IFormFile? file)
    {
        if (file == null)
            return true;


        const long maxSize = 5 * 1024 * 1024;
        if (file.Length > maxSize)
            return false;

        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!allowedExtensions.Contains(extension))
            return false;

        var allowedContentTypes = new[]
        {
            "image/jpeg",
            "image/png",
            "image/gif"
        };
        return allowedContentTypes.Contains(file.ContentType.ToLowerInvariant());
    }
}