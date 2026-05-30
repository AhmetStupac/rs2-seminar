using DotNetEnv;
using eCommerce.Model.Validators;
using eCommerce.Services;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using eCommerce.Services.Repository;
using eCommerce.Services.SignalR;
using eCommerce.WebAPI.Filters;
using eCommerce.WebAPI.HostedServices;
using eCommerce.WebAPI.Middleware;
using FluentValidation;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

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

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IRoleService, RoleService>();
builder.Services.AddScoped<IPersonalTrainerService, PersonalTrainerService>();
builder.Services.AddScoped<ITrainingPlanService, TrainingPlanService>();
builder.Services.AddScoped<IExerciseService, ExerciseService>();
builder.Services.AddScoped<IMuscleGroupService, MuscleGroupService>();
builder.Services.AddScoped<IEquipmentService, EquipmentService>();
builder.Services.AddScoped<ITrainingService, TrainingService>();
builder.Services.AddScoped<IImageMetadataService, ImageMetadataService>();
builder.Services.AddScoped<IBlobStorageService, BlobStorageService>();
builder.Services.AddScoped<IBlobStorageRepository, BlobStorageRepository>();
builder.Services.AddScoped<IExercisePlanService, ExercisePlanService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserDuplicateChecker, UserDuplicateChecker>();
builder.Services.AddScoped<INutritionPlanService, NutritionPlanService>();
builder.Services.AddScoped<IGymService, GymService>();
builder.Services.AddScoped<ICountryService, CountryService>();
builder.Services.AddScoped<ICityService, CityService>();
builder.Services.AddScoped<ITrainingSessionService, TrainingSessionService>();
builder.Services.AddScoped<eCommerce.Services.States.InitialTrainingSessionState>();
builder.Services.AddScoped<eCommerce.Services.States.PendingTrainingSessionState>();
builder.Services.AddScoped<eCommerce.Services.States.ConfirmedTrainingSessionState>();
builder.Services.AddScoped<eCommerce.Services.States.CompletedTrainingSessionState>();
builder.Services.AddScoped<eCommerce.Services.States.CancelledTrainingSessionState>();
builder.Services.AddScoped<eCommerce.Services.States.NoShowTrainingSessionState>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IPersonalTrainerRatingService, PersonalTrainerRatingService>();
builder.Services.AddScoped<IMonthlyTrainingStatisticsService, MonthlyTrainingStatisticsService>();
builder.Services.AddScoped<IGroupTrainingSessionService, GroupTrainingSessionService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IMembershipService, MembershipService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddSingleton<IRabbitMQPublisher, RabbitMQPublisher>();
builder.Services.AddScoped<IDashboardReportService, DashboardReportService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddHostedService<RecommenderTrainingHostedService>();
builder.Services.AddHttpContextAccessor();


builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        var tokenKey = builder.Configuration["TokenKey"]
            ?? throw new Exception("Token key not found - program.cs");
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenKey)),
            ValidateIssuer = false,
            ValidateAudience = false
        };
        
        // Enable JWT for SignalR
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                {
                    context.Token = accessToken;
                }
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = true;
    options.SupportedProtocols.Add("json");
});

builder.Services.AddMapster();
builder.Services.AddValidatorsFromAssemblyContaining<ExerciseValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<GymValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<PaymentValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<CreateMessageValidator>();



// Configure database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found. Set it in appsettings.json or environment variables.");
builder.Services.AddDatabaseServices(connectionString);

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("SignalRPolicy", policy =>
    {
        policy.RequireAuthenticatedUser();
    });
});



builder.Services.AddControllers(options =>
{
    options.Filters.Add<ExceptionFilter>();
});
builder.Services.AddScoped<TrainingOwnershipFilter>();
builder.Services.AddScoped<PersonalTrainerOnlyFilter>();
builder.Services.AddScoped<AdminOrTrainerOnlyFilter>();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT Authorization header using the Bearer scheme. Enter your token in the text input below."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme 
            { 
                Reference = new OpenApiReference 
                { 
                    Type = ReferenceType.SecurityScheme, 
                    Id = "Bearer" 
                } 
            },
            new string[] { }
        }
    });
});

var allowedOrigins = builder.Configuration
    .GetSection("Cors:AllowedOrigins")
    .Get<string[]>() ?? [];

builder.Services.AddCors(options =>
{
    options.AddPolicy("SignalRCors", corsBuilder =>
    {
        corsBuilder
            .WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

var app = builder.Build();


// Ensure database is created and migrations are applied
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<IB210033DbContext>();
    dbContext.Database.Migrate();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (app.Environment.IsDevelopment() && Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") != "true")
{
    app.Urls.Clear();
    app.Urls.Add("https://localhost:7093");  // HTTPS for API/Swagger
    app.Urls.Add("http://localhost:7094");   // HTTP for SignalR
}

app.UseCors("SignalRCors");

app.UseAuthentication();
app.UseAuthorization();

app.UseMiddleware<BanCheckMiddleware>();


app.MapControllers();
app.MapHub<PresenceHub>("/hubs/presence");
app.MapHub<MessageHub>("/hubs/messages");

app.Run();
