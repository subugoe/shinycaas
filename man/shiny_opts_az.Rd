% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/azure.R
\name{shiny_opts_az}
\alias{shiny_opts_az}
\title{Shiny options for Azure}
\usage{
shiny_opts_az()
}
\description{
Set shiny options as \href{https://docs.microsoft.com/en-us/azure/app-service/containers/configure-custom-container}{required for an Azure Webapp}:
\itemize{
\item \verb{options(shiny.port = as.integer(Sys.getenv('PORT'))}.
Your custom container is expected to listen on \code{PORT}, an environment variable set by Azure.
If your image suggests \code{EXPOSE}d ports, that may be respected by Azure (undocumented behavior).
\item \code{options(shiny.host = "0.0.0.0")} to make your shiny application accessable to the Azure Webapp hosting environment.
}
}
\concept{azure functions}
