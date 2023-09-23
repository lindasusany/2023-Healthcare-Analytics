COVIDdata <- read_excel("/Users/zsl/Downloads/COVIDdata.xlsm")
new_infection_real = COVIDdata$`Newly Positive (Confirmed Infections)`
new_infection_real <- new_infection_real[!is.na(new_infection_real)]

# Define ranges for beta, gamma, and theta
beta_range <- seq(0, 1e-3, length.out = 11)
gamma_range <- seq(0.9, 1, length.out = 11)
theta_range <- seq(0, 1e-2, length.out = 11)

best_params <- c(beta = NA, gamma = NA, theta = NA)
min_rmse <- Inf

# Iterate over all combinations of parameter values
for (beta in beta_range) {
  for (gamma in gamma_range) {
    for (theta in theta_range) {
      solution <- SIERModel(beta = beta, gamma = gamma, theta = theta, 
                            S0 = 2040000, E0 = 1400, I0 = 0, R0 = 0, times = seq(0, 21))
      pred_new_infection <- diff(solution[, "I"] + solution[, "R"])
      rmse <- sqrt(mean((pred_new_infection - new_infection_real)^2))
      
      # Update best_params and min_rmse if current RMSE is smaller
      if (rmse < min_rmse) {
        best_params <- c(beta = beta, gamma = gamma, theta = theta)
        min_rmse <- rmse
      }
    }
  }
}

cat("Best parameters: beta =", best_params["beta"], ", gamma =", best_params["gamma"], 
    ", theta =", best_params["theta"], "\n")
cat("Min RMSE:", min_rmse, "\n")

# Assign new_cases to the last column of data
COVIDdata$`Forecasted Newly Positive`[1:22] <- round(pred_new_infection)
# Assign min_rmse
COVIDdata$`Forecasted Newly Positive`[24]<-min_rmse
# Load the writexl package
library(writexl)
write_xlsx(COVIDdata,'/Users/zsl/downloads/COVIDdata_new.xlsm')