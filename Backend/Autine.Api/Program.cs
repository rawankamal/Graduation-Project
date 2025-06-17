using Autine.Api;
using Autine.Api.Hubs;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

//builder.Host.UseSerilog((context, logConfig) =>
//{
//    logConfig.ReadFrom.Configuration(context.Configuration)
//             .Enrich.FromLogContext();
//});

builder.Services.AddApi(builder.Configuration);
builder.Services.AddControllers();
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = true;
    options.MaximumReceiveMessageSize = 102400; // 100 KB
});
builder.Services.AddCors(options =>
{
    options.AddPolicy("ClientPermission", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",   
                "http://127.0.0.1:5502",   
                "https://localhost:7065",   
                "http://localhost:5221"     
            ).AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

builder.Services.AddHybridCache();

var app = builder.Build();

app.UseRouting();

app.MapOpenApi();
app.MapScalarApiReference();


app.UseHttpsRedirection();
app.UseCors("ClientPermission");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();


app.MapHub<ChatHub>("/my-chat");
app.MapHub<ThreadHub>("/thread-chat");

app.Run();