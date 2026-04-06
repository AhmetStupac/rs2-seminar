using eCommerce.Services;
using Microsoft.Extensions.Hosting;

namespace eCommerce.WebAPI.HostedServices
{
    public class RecommenderTrainingHostedService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<RecommenderTrainingHostedService> _logger;

        public RecommenderTrainingHostedService(
            IServiceScopeFactory scopeFactory,
            ILogger<RecommenderTrainingHostedService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                await Task.Delay(2000, stoppingToken);

                using var scope = _scopeFactory.CreateScope();
                PersonalTrainerService.TrainRecommenderAtStartup(scope.ServiceProvider);
            }
            catch (OperationCanceledException)
            {
                // App is shutting down.
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while training personal trainer recommender model at startup.");
            }
        }
    }
}
