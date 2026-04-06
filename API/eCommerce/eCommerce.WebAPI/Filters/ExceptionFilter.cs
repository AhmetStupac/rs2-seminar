using eCommerce.Model;
using eCommerce.Model.Requests;
using eCommerce.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

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

            var (statusCode, key, message) = context.Exception switch
            {
                UnauthorizedAccessException ex => (HttpStatusCode.Forbidden, "unauthorized", ex.Message),
                KeyNotFoundException ex => (HttpStatusCode.NotFound, "notFound", ex.Message),
                ArgumentException ex => (HttpStatusCode.BadRequest, "validation", ex.Message),
                InvalidOperationException ex => (HttpStatusCode.BadRequest, "invalidOperation", ex.Message),
                UserException ex => (HttpStatusCode.BadRequest, "userError", ex.Message),
                _ => (HttpStatusCode.InternalServerError, "error", "Server side error, please check logs")
            };

            var errors = new Dictionary<string, IEnumerable<string>>
            {
                [key] = new[] { message }
            };

            context.Result = new JsonResult(new { errors })
            {
                StatusCode = (int)statusCode
            };

            context.ExceptionHandled = true;
        }
    }
}

