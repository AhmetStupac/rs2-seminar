using eCommerce.Model;
using eCommerce.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Logging;
using System.Net;

namespace eCommerce.WebAPI.Filters
{
    public class ExceptionFilter : ExceptionFilterAttribute
    {
        private readonly ILogger<ExceptionFilter> _logger;
        public ExceptionFilter(ILogger<ExceptionFilter> logger){
                _logger = logger;
        }
        public override void OnException(ExceptionContext context)
        {
            _logger.LogError(context.Exception, context.Exception.Message);

            var (statusCode, message) = context.Exception switch
            {
                UnauthorizedAccessException ex => (HttpStatusCode.Forbidden, ex.Message),
                KeyNotFoundException ex        => (HttpStatusCode.NotFound, ex.Message),
                ArgumentException ex           => (HttpStatusCode.BadRequest, ex.Message),
                InvalidOperationException ex   => (HttpStatusCode.BadRequest, ex.Message),
                UserException ex               => (HttpStatusCode.BadRequest, ex.Message),
                _                              => (HttpStatusCode.InternalServerError, "Server side error, please check logs")
            };

            context.Result = new JsonResult(new { message })
            {
                StatusCode = (int)statusCode
            };

            context.ExceptionHandled = true;
        }
    }
}

