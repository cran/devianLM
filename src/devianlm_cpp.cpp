// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
// [[Rcpp::plugins(openmp)]]
#include <omp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector devianlm_cpp(const arma::mat & X, const arma::uword n_sims, const int nthreads) {
  
  arma::uword n = X.n_rows, k = X.n_cols;
  
  NumericVector Max_( n_sims );
  
  // Perform threaded Monte-Carlo simulations:
  #ifdef _OPENMP
    omp_set_num_threads(nthreads);
  #else
    if (nthreads > 1)
      Rcpp::Rcout << "The OpenMP library is not available on this machine: running in single-threaded mode.\n";
  #endif

#pragma omp parallel for if(nthreads > 1)
  for( arma::uword sim_i = 0; sim_i < n_sims; sim_i++ ) {
    
    //generates a vector 'y' of 'n' normal values:
    const arma::vec y( n, arma::fill::randn );
    
    const arma::colvec coef = arma::solve(X, y);
    const arma::colvec resid = y - X*coef;  //residuals
    
    // compute the diagonal of the influence / hat matrix :
    // H = X(X^{T}X)^{-1}X^{T} or in R: X %*% solve(t(X) %*% X) %*% t(X)
    // or for a direct computation one can use: const arma::mat XtX_inv = arma::inv( X.t() * X );
    const arma::mat XtX_inv = arma::solve( X.t() * X, arma::eye( X.n_cols, X.n_cols ), arma::solve_opts::likely_sympd );
    const arma::colvec d = arma::sum( X % ( X * XtX_inv ), 1 );
    // alternatively, one can use arma::sympd() instead of solve():
    // const arma::mat XtX = X.t() * X;
    // const arma::mat XtX_inv = arma::inv_sympd(0.5 * (XtX + XtX.t()));
    
    // Compute residual variance
    const double total_resid_squared = arma::dot(resid, resid); // Dot product for squared sum
    const double rdf = n - coef.n_rows; // Residual degrees of freedom
    const double MSRes = total_resid_squared / rdf; // Residual mean squares
    const double inv_c = 1.0 / (n - k - 1); // Reciprocal of scaling factor
    
    // Compute s2i
    const arma::vec s2i = ( (n - k) * MSRes * inv_c ) - ( arma::square( resid ) / (1.0 - d) ) * inv_c;
    
    // Compute studentized (external) residuals
    const arma::vec scale_factors = arma::sqrt(s2i % (1.0 - d));
    const arma::vec stud_res = resid / scale_factors;
    
    // Compute and return the threshold statistic
    Max_[sim_i] = arma::max(arma::abs(stud_res));
  }
  
  return Max_;
  
}
