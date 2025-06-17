using Autine.Application.Abstractions;
using Autine.Application.IServices;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace Autine.Infrastructure.Services;
public class FileService(
    IWebHostEnvironment _webHostEnvironment,
    ILogger<FileService> logger) : IFileService
{
    private const string _profileImagePath = ImageSettings.ImagePath;
    private const string _botImagePath = ImageSettings.BotImagePath;
    private readonly string _profilePath = Path.Combine(_webHostEnvironment.WebRootPath, _profileImagePath);
    private readonly string _botBath = Path.Combine(_webHostEnvironment.WebRootPath, _botImagePath);
    private readonly ILogger<FileService> _logger = logger;
    public async Task<Result<string>> UploadImageAsync(IFormFile image, bool isBot = false, CancellationToken token = default)
    {
        try { 
        var path = isBot ? _botBath : _profilePath;
        if (!Directory.Exists(path))
        {
            _logger.LogDebug("Creating directory {DirectoryPath}", path);
            Directory.CreateDirectory(path);
        }
        
        var uniqueFileName = $"{Guid.CreateVersion7()}{Path.GetExtension(image.FileName)}";
        var filePath = Path.Combine(path, uniqueFileName);

        using var fileStream = new FileStream(filePath, FileMode.Create);
        await image.CopyToAsync(fileStream, token);

        return Result.Success(uniqueFileName);

        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to upload image");
            throw;
        }
    }
    public async Task<Result<string>> UpdateImageAsync(string image, IFormFile newImage, bool isBot = false, CancellationToken ct = default)
    {
        if (!string.IsNullOrEmpty(image))
        {
            _logger.LogDebug("Deleting previous image {ImageName}", image);
            var deleteResult = await DeleteImageAsync(image, isBot);
            if (deleteResult.IsFailure)
                return deleteResult.Error;
        }

        var addResult = await UploadImageAsync(newImage, isBot, ct);

        if (addResult.IsFailure)
        {
            _logger.LogError(addResult.Error.ToString(), "Failed to update image");
            return addResult.Error;
          
        }

        return addResult.Value;
    }
    public async Task<(FileStream? stream, string? contentType, string? fileName)> StreamAsync(string image, bool isBot = false, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(image))
        {
            _logger.LogDebug("Empty image name provided");
            return (null, null, null);
        }
        try
        { 
        var path = isBot ? _botBath : _profilePath;
        var fileName = Path.GetFileName(image);
        var imagePath = Path.Combine(path, fileName);
        
        if (!File.Exists(imagePath))
        {
            _logger.LogWarning("Image not found at {ImagePath}", imagePath);
            return (null, null, null);
        }
        var extension = Path.GetExtension(imagePath).ToLowerInvariant();
        var contentType = extension switch
        {
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".gif" => "image/gif",
            ".bmp" => "image/bmp",
            ".webp" => "image/webp",
            _ => "application/octet-stream"
        };
        var stream = new FileStream(
             imagePath,
             FileMode.Open,
             FileAccess.Read,
             FileShare.Read,
             4096,
             FileOptions.Asynchronous
        );


        return (stream, contentType, fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to stream image {ImageName}", image);
            return (null, null, null);
        }
    }

    public Task<Result> DeleteImageAsync(string image, bool isBot = false)
    {
        if (string.IsNullOrEmpty(image))
            return Task.FromResult(Result.Success());

        var path = isBot ? _botBath : _profilePath;
        
        try
        {
            var fileName = Path.GetFileName(image);
            var imagePath = Path.Combine(path, fileName);

            if (!File.Exists(imagePath))
                return Task.FromResult(Result.Success());

            _logger.LogDebug("Deleting image at {ImagePath}", imagePath);
            File.Delete(imagePath);
            return Task.FromResult(Result.Success());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to delete image {ImageName}", image);
            return Task.FromResult(Result.Success());
        }
    }
}
