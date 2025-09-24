\name{devianLM-package}
\alias{devianLM-package}
\alias{devianLM}
\docType{package}
\title{Detection of Poorly Explained Values in Gaussian Linear Models}

\description{
The \pkg{devianLM} package provides tools to detect values that are poorly explained 
by a Gaussian linear model. The method is based on the maximum absolute value of 
studentized residuals, a statistic that is independent of the model parameters. 
This approach generalizes several procedures used to detect abnormal values, 
such as during the longitudinal monitoring of certain biological markers.
}

\details{
The package offers two main functions:
\itemize{
  \item \code{\link{get_devianlm_threshold}}: Computes the detection threshold via Monte Carlo simulations.
  \item \code{\link{devianlm_stats}}: Fits a Gaussian linear model and flags potential outliers based on the computed threshold.
}
These methods are particularly useful for regression diagnostics, quality control, 
and longitudinal monitoring in applied statistics.
}

\author{
Guillaume Saulière \email{guillaumesauliere@hotmail.com} \\
Geoffroy Berthelot \email{geoffroy.berthelot@insep.fr} \\
Jérôme Dedecker \email{jerome.dedecker@u-paris.fr} \\
}

\keyword{package}

\examples{
set.seed(123)
x <- as.matrix(rnorm(50))
y <- 2 * x + rnorm(50)

# Small n_sims for quick example
result <- devianlm_stats(y, x, n_sims = 100)
}
