using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Text.Json;

namespace Autine.Infrastructure.Identity.Authentication;
public class JwtProvider(IOptions<JwtOptions> options) : IJwtProvider
{
    private readonly JwtOptions _jwtOptions = options.Value;
    public (string token, int expiresIn) GenerateToken(ApplicationUser user, IEnumerable<string> roles)
    {
        Claim[] claims = [
            new (JwtRegisteredClaimNames.Sub, user.Id),
            new (JwtRegisteredClaimNames.GivenName, user.FirstName),
            new (JwtRegisteredClaimNames.FamilyName, user.LastName),
            new (JwtRegisteredClaimNames.Email, user.Email!),
            new (JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new (nameof(roles), JsonSerializer.Serialize(roles), JsonClaimValueTypes.JsonArray)
        ];
        
        var symmetricKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtOptions.Key));
        var signingCredentials = new SigningCredentials(symmetricKey, SecurityAlgorithms.HmacSha256);

        JwtHeader header = new(signingCredentials);
        JwtPayload payload = new(
            _jwtOptions.Issuer,
            _jwtOptions.Audience,
            claims,
            null, 
            DateTime.UtcNow.AddMinutes(_jwtOptions.ExpireMinutes)            
        );

        var token = new JwtSecurityToken(header, payload);

        return (token: new JwtSecurityTokenHandler().WriteToken(token), _jwtOptions.ExpireMinutes);
    }
    public string? ValidateToken(string token)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var symmetricSecurityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtOptions.Key));

        try
        {
            tokenHandler.ValidateToken(token, new TokenValidationParameters
            {
                IssuerSigningKey = symmetricSecurityKey,
                ValidateIssuerSigningKey = true,
                ValidateIssuer = false,
                ValidateAudience = false,
                ClockSkew = TimeSpan.Zero
            }, out SecurityToken validateToken);

            var jwtToken = (JwtSecurityToken)validateToken;

            return jwtToken.Claims.First(e => e.Type == JwtRegisteredClaimNames.Sub).Value;
        }
        catch
        {
            return null;
        }
    }
}
