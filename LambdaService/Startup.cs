using LambdaApplication.Impl;
using LambdaApplication.Interfaces;
using LambdaDomain.Repositories;
using LambdaRepository.Repositories;

namespace LambdaService;

public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllers();
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen();
        services.AddScoped<IWeatherForecastService, WeatherForecastService>();
        services.AddScoped<IWeatherForecastRepository, WeatherForecastRepository>();
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        app.UseRouting();
        if (env.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }
        
        app.UseHttpsRedirection();

        app.UseAuthorization();

        app.UseEndpoints(x => x.MapControllers());
    }
}