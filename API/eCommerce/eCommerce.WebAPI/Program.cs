using DotNetEnv;
using eCommerce.Model.Validators;
using eCommerce.Services;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using eCommerce.Services.Repository;
using eCommerce.Services.SignalR;
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

// Add services to the container.
//builder.Services.AddTransient<IProductService, ProductService>();
builder.Services.AddTransient<IUserService, UserService>();
//builder.Services.AddTransient<IProductTypeService, ProductTypeService>();
builder.Services.AddTransient<IRoleService, RoleService>();
//builder.Services.AddTransient<IUnitOfMeasureService, UnitOfMeasureService>();

//builder.Services.AddTransient<BaseProductState>();
//builder.Services.AddTransient<InitialProductState>();
//builder.Services.AddTransient<DraftProductState>();
//builder.Services.AddTransient<ActiveProductState>();
//builder.Services.AddTransient<DeactivatedProductState>();
builder.Services.AddTransient<IPersonalTrainerService, PersonalTrainerService>();
builder.Services.AddTransient<ITrainingPlanService, TrainingPlanService>();
builder.Services.AddTransient<IExerciseService, ExerciseService>();
builder.Services.AddTransient<IMuscleGroupService, MuscleGroupService>();
builder.Services.AddTransient<IEquipmentService, EquipmentService>();
builder.Services.AddTransient<ITrainingService, TrainingService>();
builder.Services.AddScoped<IImageMetadataService, ImageMetadataService>();
builder.Services.AddScoped<IBlobStorageService, BlobStorageService>();
builder.Services.AddScoped<IBlobStorageRepository, BlobStorageRepository>();
builder.Services.AddScoped<IExercisePlanService, ExercisePlanService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<INutritionPlanService, NutritionPlanService>();
builder.Services.AddTransient<IGymService, GymService>();
builder.Services.AddScoped<ITrainingSessionService, TrainingSessionService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IPersonalTrainerRatingService, PersonalTrainerRatingService>();
builder.Services.AddScoped<IMonthlyTrainingStatisticsService, MonthlyTrainingStatisticsService>();
builder.Services.AddScoped<IGroupTrainingSessionService, GroupTrainingSessionService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddSingleton<IRabbitMQPublisher, RabbitMQPublisher>();
builder.Services.AddScoped<IDashboardReportService, DashboardReportService>();
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
//builder.Services.AddValidatorsFromAssemblyContaining<TrainingPlanValidator>();
//builder.Services.AddValidatorsFromAssemblyContaining<ExercisePlanValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<GymValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<PaymentValidator>();



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



builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
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

//builder.Services.AddCors(options =>
//{
//    options.AddPolicy("SignalRCors", builder =>
//    {
//        builder.WithOrigins("http://localhost:3000",
//            "http://10.0.2.2:7093") // Your client URL
//               .AllowAnyHeader()
//               .AllowAnyMethod()
//               .AllowCredentials();
//    });
//});

builder.Services.AddCors(options =>
{
    options.AddPolicy("SignalRCors", builder =>
    {
        builder.SetIsOriginAllowed(_ => true)  // Allow all origins in dev
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

//app.UseHttpsRedirection();
app.UseCors("SignalRCors");

app.UseAuthentication();
app.UseAuthorization();

app.UseMiddleware<BanCheckMiddleware>();


app.MapControllers();
app.MapHub<PresenceHub>("/hubs/presence");
app.MapHub<MessageHub>("/hubs/messages");

// Train the personal trainer recommender model in background after startup
_ = Task.Run(async () =>
{
    await Task.Delay(2000);
    using (var trainingScope = app.Services.CreateScope())
    {
        PersonalTrainerService.TrainRecommenderAtStartup(trainingScope.ServiceProvider);
    }
});

app.Run();
