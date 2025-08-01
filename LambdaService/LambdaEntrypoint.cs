using Amazon.Lambda.AspNetCoreServer;

namespace LambdaService;

public class LambdaEntrypoint : APIGatewayProxyFunction
{
    protected override void Init(IWebHostBuilder builder)
    {
        builder.UseStartup<Startup>();
        base.Init(builder);
    }
}