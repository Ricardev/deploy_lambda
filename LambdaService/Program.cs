using LambdaApplication.Impl;
using LambdaApplication.Interfaces;
using LambdaDomain.Repositories;
using LambdaRepository.Repositories;

namespace LambdaService;

public static class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);
        builder.Services.AddControllers();
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();
        builder.Services.AddScoped<IWeatherForecastService, WeatherForecastService>();
        builder.Services.AddScoped<IWeatherForecastRepository, WeatherForecastRepository>();
        var app = builder.Build();
        
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseHttpsRedirection();

        app.UseAuthorization();

        app.MapControllers();

        app.Run();
    }
}