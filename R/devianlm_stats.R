#' get_devianlm_threshold : Compute threshold using Monte Carlo simulations
#' @description This package determines whether the maximum of the absolute values
#' of the studentized residuals of a Gaussian regression is abnormally high.
#' The distribution of the maximum of the absolute of the studentized residuals
#' (depending on the design matrix) is computed via Monte-Carlo simulations (with n_sims simulations).
#' @param x either a numeric variable or several numeric variables
#' (explanatory variables) concatenated in a data frame.
#' @param n_sims optional value which is the number of simulations, is set to 50.000 by default.
#' @param alpha quantile of interest, is set to 0.95 by default.
#' @param nthreads optional value which is the number of CPU cores to use, is set to "number of CPU cores - 1"
#' by default.
#' @return Numeric value. \item{threshold}{The quantile of order 1-alpha of the distribution of the maximum of the absolute of the studentized residuals (depending on the design matrix) is computed via Monte-Carlo simulations (with n_sims simulations).}
#' @export
#' @useDynLib devianLM, .registration = TRUE
#' @importFrom Rcpp sourceCpp
#' @import parallel


get_devianlm_threshold <- function(x, n_sims = 50000, nthreads = detectCores() - 1, alpha = 0.95) {
  sims <- devianlm_cpp(x, n_sims, nthreads)
  quantile(sims, probs = alpha)
}


#' Identify outliers using devianLM method
#'
#' @param y a numeric variable
#' @param x either a numeric variable or several numeric variables
#' (explanatory variables) concatenated in a data frame.
#' @param threshold numeric or NULL; if NULL, computed using devianlm_cpp()
#' @param n_sims optional value which is the number of simulations, is set to 50.000 by default.
#' @param alpha quantile of interest, is set to 0.95 by default.
#' @param nthreads optional value which is the number of CPU cores to use, is set to "number of CPU cores - 1" by default.
#' @param ... additional arguments for get_devianlm_threshold()
#' @return devianlm returns an object of class \emph{list} with the following components:
#' \describe{
#'   \item{reg_residuals}{Numeric vector. The studentized residuals from the linear model.}
#'   \item{outliers}{Integer vector. The indices (positions in the original data) of observations identified as outliers based on the threshold.}
#'   \item{threshold}{Numeric value. The cutoff applied to the absolute value of the studentized residuals to flag outliers. If not provided, it is estimated using \code{get_devianlm_threshold()}.}
#'   \item{is_outliers}{Integer vector. A binary vector (0 or 1) of the same length as \code{reg_residuals}, indicating whether each observation is considered an outlier (1) or not (0).}
#' }
#' @importFrom stats .lm.fit lm.influence quantile rnorm complete.cases
#' @import parallel
#' @examples
#' set.seed(123)
#' y <- salary$hourly_earnings_log
#' x <- cbind(salary$age, salary$educational_attainment, salary$children_number)
#' 
#' test_salary <- devianlm_stats(y, x, n_sims = 100, alpha = 0.95)
#' 
#' plot(test_salary$reg_residuals,
#'   pch = 16, cex = .8,
#'   ylim = c(-1 * max(abs(test_salary$reg_residuals)), max(abs(test_salary$reg_residuals))),
#'   xlab = "", ylab = "Studentized residuals",
#'   col = ifelse(test_salary$is_outliers, "red", "black"))
#' 
#' # Ajouter les lignes de seuil
#' abline(h = c(-test_salary$threshold, test_salary$threshold), col = "chartreuse2", lwd = 2)
#'  
#' @export
devianlm_stats <- function(y, x, threshold = NULL, n_sims = 50000, nthreads = detectCores() - 1, alpha = 0.95, ...) {
  
  if (length(y) != NROW(x)) stop("y and x must have compatible lengths")
  
  if (is.null(threshold)) {
    threshold <- get_devianlm_threshold(x, ...)
  }
  
  # dealing with NA
  complete_cases <- complete.cases(y, x)
  y_clean <- y[complete_cases]
  x_clean <- x[complete_cases, , drop = FALSE]
  
  # add noise if ties are detected
  y_mod <- y_clean
  if (any(duplicated(y_clean))) {
    v <- min(y_clean, na.rm = T) / 1e6
    if (v < 1e-16) v <- .Machine$double.eps
    y_mod <- y_clean + ifelse(duplicated(y_clean), rnorm(length(y_clean), mean = 0, sd = v), 0)
    message("Ties were detected in the data, they have been randomly broken")
  }
  
  reg <- .lm.fit(cbind(1, x_clean), y_mod)
  reg$qr <- reg
  inf <- lm.influence(reg, do.coef = FALSE)
  reg_residuals <- inf$wt.res / (inf$sigma * sqrt(1 - cbind(inf$hat)))
  
  outliers <- which(abs(reg_residuals) > threshold)
  is_outliers <- integer(length(reg_residuals))
  is_outliers[outliers] <- 1
  
  list(
    reg_residuals = reg_residuals,
    outliers = outliers,
    threshold = threshold,
    is_outliers = is_outliers
  )
}
