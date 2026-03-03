using DotNetEnv;
using eCommerce.EmailService;

// Load .env file for local development.
// In Docker, environment variables are injected by docker-compose and this is a no-op.
try
{
    var possiblePaths = new[]
    {
        Path.Combine(Directory.GetCurrentDirectory(), ".env"),
        Path.Combine(Directory.GetCurrentDirectory(), "..", ".env"),
        Path.Combine(Directory.GetCurrentDirectory(), "..", "..", ".env"),
    };
    var envFile = possiblePaths.FirstOrDefault(File.Exists);
    if (envFile != null)
        Env.Load(envFile);
}
catch (FileNotFoundException) { /* Docker supplies env vars directly */ }

IHost host = Host.CreateDefaultBuilder(args)
    .ConfigureServices(services =>
    {
        services.AddHostedService<Worker>();
    })
    .Build();

await host.RunAsync();
