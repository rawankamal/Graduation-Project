using Autine.Application.ExternalContracts;
using Autine.Application.IServices.AIApi;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net;
using System.Text;

namespace Autine.Infrastructure.Services.AIApi;
public class BaseService(IHttpClientFactory _httpClientFactory, ILogger<BaseService> _logger) : IBaseService
{
   // private readonly ILogger<BaseService> _logger = logger;
    public async Task<Result<T>> SendAsync<T>(Request request, CancellationToken ct = default)
    {

        HttpClient client = _httpClientFactory.CreateClient();
        using var message = BuildHttpRequestMessage(request);

        try
        {
            _logger.LogInformation("Sending {Method} request to {Url}", message.Method, message.RequestUri);

            using var response = await client.SendAsync(message, ct);
            var responseContent = await response.Content.ReadAsStringAsync(ct);

            _logger.LogInformation("Received response with status code {StatusCode}", response.StatusCode);
           
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Request failed with {StatusCode}: {Url}", response.StatusCode, message.RequestUri);
                return Result.Failure<T>(ParseError(responseContent));
            }

            return Result.Success(JsonConvert.DeserializeObject<T>(responseContent)!);

            //var returnedResult = response.StatusCode switch
            //{
            //    HttpStatusCode.OK or HttpStatusCode.Created or HttpStatusCode.NoContent =>
            //        Result.Success(JsonConvert.DeserializeObject<T>(responseContent)!),
            //    _ =>

            //    Result.Failure<T>(ParseError(responseContent)),
            //};

            //return returnedResult;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Exception occurred while sending request to {Url}", message.RequestUri);
            return Result.Failure<T>(Error.BadRequest("ex", ex.ToString()));
        }
    }
    public async Task<Result> SendAsync(Request request, CancellationToken ct = default)
    {
        HttpClient client = _httpClientFactory.CreateClient();
        using var message = BuildHttpRequestMessage(request);

        try
        {
            _logger.LogInformation("Sending {Method} request to {Url}", message.Method, message.RequestUri);

            using var response = await client.SendAsync(message, ct);
            var responseContent = await response.Content.ReadAsStringAsync(ct);

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Request failed with {StatusCode}: {Url}", response.StatusCode, message.RequestUri);
                return Result.Failure(ParseError(responseContent));
            }
            _logger.LogInformation("Received success response from {Url}", message.RequestUri);
            return Result.Success();
            // var responseContent = await response.Content.ReadAsStringAsync(ct);

            //return response.StatusCode switch
            //{
            //    HttpStatusCode.OK or HttpStatusCode.Created or HttpStatusCode.NoContent =>
            //        Result.Success(),
            //    _ => Result.Failure(ParseError(responseContent))
            //};


        }
        catch (Exception ex)
        {
            // TODO: log error
            _logger.LogError(ex, "Exception occurred while calling AI service at {Url}", message.RequestUri);
            return Error.BadRequest("AI.Error", "An error occure while caling ai service.");
        }
    }

    private HttpRequestMessage BuildHttpRequestMessage(Request request)
    {
        var message = new HttpRequestMessage
        {
            RequestUri = new Uri(request.Url),
            Method = (sbyte)request.ApiMethod switch
            {
                1 => HttpMethod.Post,
                2 => HttpMethod.Put,
                3 => HttpMethod.Delete,
                _ => HttpMethod.Get
            }
        };

        message.Headers.Add("accept", "application/json");

        if (request.Data is not null)
        {
            message.Content = new StringContent(JsonConvert.SerializeObject(request.Data), Encoding.UTF8, "application/json");
        }

        return message;
    }

    private static Error ParseError(string content)
    {
        try
        {

            var problemDetails = JsonConvert.DeserializeObject<ServiceResponse>(content);

            return Error.BadRequest("Ai.Error", problemDetails!.msg ?? "an error accure");

        }
        catch
        {
            return Error.BadRequest("Ai.Error", "an error eccure");
        }
    }

}
public record ServiceResponse(string msg);