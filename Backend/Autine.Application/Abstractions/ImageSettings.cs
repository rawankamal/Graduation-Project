namespace Autine.Application.Abstractions;

public class ImageSettings
{
    public const string ImagePath = @"uploads\profilePictures";
    public const string BotImagePath = @"uploads\botImages";
    public static readonly string[] AllowedExtension = [".jpg", ".jpeg", ".png"];
    public static readonly Dictionary<string, List<byte[]>> AllowedFileSignatures = new()
    {
        { "image/jpeg", new List<byte[]>
          {
              new byte[] { 0xFF, 0xD8, 0xFF, 0xE0 },
              new byte[] { 0xFF, 0xD8, 0xFF, 0xE1 },
              new byte[] { 0xFF, 0xD8, 0xFF, 0xE2 },
              new byte[] { 0xFF, 0xD8, 0xFF, 0xE3 },
              new byte[] { 0xFF, 0xD8, 0xFF, 0xE8 }
          }
        },
        { "image/png", new List<byte[]> { new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A } } },
        { "image/gif", new List<byte[]>
          {
              new byte[] { 0x47, 0x49, 0x46, 0x38, 0x37, 0x61 },
              new byte[] { 0x47, 0x49, 0x46, 0x38, 0x39, 0x61 }
          }
        },
        { "image/bmp", new List<byte[]> { new byte[] { 0x42, 0x4D } } },
        { "image/webp", new List<byte[]> { new byte[] { 0x52, 0x49, 0x46, 0x46 } } }
    };
    public const int MaxFileSizeInBytes = 5 * 1024 * 1024;
}
