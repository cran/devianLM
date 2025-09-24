test_that("Package loads correctly", {
  expect_true("devianLM" %in% .packages(all.available = TRUE))
})

test_that("devianlm_stats runs on simple example", {
  set.seed(123)
  x <- as.matrix(rnorm(50))
  y <- 2 * x + rnorm(50)
  
  result <- devianlm_stats(y, x, n_sims = 100) # small n_sims for quick test
  
  expect_true(is.list(result) || is.data.frame(result) || is.numeric(result))
})
