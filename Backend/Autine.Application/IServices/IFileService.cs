namespace Autine.Application.IServices;

public interface IFileService
{
    Task<Result<string>> UploadImageAsync(IFormFile image, bool isBot = false, CancellationToken token = default);
    Task<(FileStream? stream, string? contentType, string? fileName)> StreamAsync(string image, bool isBot = false, CancellationToken cancellationToken = default);
    Task<Result<string>> UpdateImageAsync(string image, IFormFile newImage, bool isBot = false, CancellationToken ct = default);
    Task<Result> DeleteImageAsync(string image, bool isBot = false);
}