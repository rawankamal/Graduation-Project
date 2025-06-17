using Autine.Application.IServices;
using Autine.Application.IServices.AIApi;
using Autine.Infrastructure.Identity.Authentication;
using Autine.Infrastructure.Repositories;
using Autine.Infrastructure.Services;
using Autine.Infrastructure.Services.AIApi;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Text;

namespace Autine.Infrastructure;
public static class DependancyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfigurationManager configuration)
    {   
        services.AddDbConfig(configuration);
        services.AddAuthConfig(configuration);
        services.RegisterToDI();
        return services;
    }
    private static IServiceCollection RegisterToDI(this IServiceCollection services)
    {
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IRoleService, RoleService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IAccountService, AccountService>();
        services.AddScoped<IPatientService, PatientService>();
        services.AddScoped<IUrlGenratorService, UrlGenratorService>();
        services.AddScoped<IBotService, BotService>();
        services.AddScoped<IFileService, FileService>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();
        
        services.AddHttpClient();
        services.AddHttpContextAccessor();
        services.AddScoped<IBaseService, BaseService>();
        services.AddScoped<IAIAuthService, AIAuthService>();
        services.AddScoped<IAIModelService, AIModelService>();

        services.AddOptions<ApiSettings>()
            .BindConfiguration(ApiSettings.Section)
            .ValidateDataAnnotations()
            .ValidateOnStart();

        return services;
    }
    private static IServiceCollection AddDbConfig(this IServiceCollection services, IConfiguration configuration)
    {
        
        try
        {
            var connectionString = configuration
                .GetConnectionStringOrThrow("DefaultConnection");


            services.AddDbContext<ApplicationDbContext>(options =>
            {
                options.UseSqlServer(connectionString,
                    a => a.MigrationsAssembly(typeof(ApplicationDbContext).Assembly));
            });
        }
        catch
        {
            //TODO: log error
        }
        return services;
    }
    private static IServiceCollection AddAuthConfig(this IServiceCollection services, IConfigurationManager configuration)
    {
        services.AddIdentity<ApplicationUser, IdentityRole>()
            .AddEntityFrameworkStores<ApplicationDbContext>()
            .AddDefaultTokenProviders();

        services.AddSingleton<IJwtProvider, JwtProvider>();

        services.AddOptions<JwtOptions>()
            .BindConfiguration(JwtOptions.SectionName)
            .ValidateDataAnnotations()
            .ValidateOnStart();

        services.Configure<IdentityOptions>(options =>
        {
            options.User.AllowedUserNameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._!@#$";
            options.User.RequireUniqueEmail = true;
            options.Password.RequiredLength = 8;
            options.SignIn.RequireConfirmedEmail = true;
        });

        var jwtOptions = configuration.GetSection(JwtOptions.SectionName).Get<JwtOptions>();

        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        }).AddJwtBearer(o =>
        {
            o.SaveToken = true;
            o.TokenValidationParameters = new()
            {
                ValidateLifetime = true,
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateIssuerSigningKey = true,
                ValidAudience = jwtOptions!.Audience,
                ValidIssuer = jwtOptions.Issuer,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.Key)),
                NameClaimType = JwtRegisteredClaimNames.Email
            };
        });

        return services;
    }
}
