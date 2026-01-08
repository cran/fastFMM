## ----preamble, include = FALSE------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE, 
  comment = "#>", 
  # eval = F, 
  cache = T
)

## ----setup, include = FALSE---------------------------------------------------
suppressMessages(library(dplyr))

## ----cran install, eval = FALSE-----------------------------------------------
# install.packages("fastFMM")

## ----install github, eval = FALSE---------------------------------------------
# if (!require("devtools")) install.packages("devtools")
# devtools::install_github("awqx/fastFMM", dependencies = TRUE)

## ----fastFMM library, message = F---------------------------------------------
library(fastFMM)

## ----read lick----------------------------------------------------------------
lick <- fastFMM::lick

## -----------------------------------------------------------------------------
class(lick$photometry)
dim(lick$photometry)

## -----------------------------------------------------------------------------
lick <- cbind(
  lick %>% select(-photometry, -lick), 
  # this unravels the matrices into data frames
  as.data.frame(lick$photometry), 
  as.data.frame(lick$lick)
)

## ----see scalars, echo = F----------------------------------------------------
lick %>% 
  select(session:lick_rate_200) %>%
  head(5) %>%
  knitr::kable()

## ----lick colnames, echo = F--------------------------------------------------
lick %>%
    select(id:trial, photometry_1:photometry_3, lick_1:lick_3) %>%
    head(5) %>% 
    knitr::kable()

## ----candidate models---------------------------------------------------------
# Random intercept 
mod1 <- fui(
  photometry ~ lick_rate_050 + (1 | id), 
  data = lick, var = FALSE, silent = TRUE 
)

# Random slope and intercept
mod2 <- fui(
  photometry ~ lick_rate_050 + (lick_rate_050 | id), 
  data = lick, var = FALSE, silent = TRUE 
)

# Fixed effects for trial and session, radom intercept and slope
mod3 <- fui(
  photometry ~ lick_rate_050 + trial + session + (lick_rate_050 | id), 
  data = lick, var = FALSE, silent = TRUE 
)

## ----candidate model AIC, echo = F--------------------------------------------
temp <- list(mod1, mod2, mod3)
dummy <- lapply(
  1:length(temp), 
  function(x) {
    message(
      "Model ", x, " AIC: ", 
      round(mean(temp[[x]]$aic[, "AIC"]), digits = 1), "\t",
      "BIC: ", round(mean(temp[[x]]$aic[, "BIC"]), digits = 1)
    )
  }
)

## ----lick_rate_050------------------------------------------------------------
lick_rate_050 <- fui(
  photometry ~ lick_rate_050 + trial + session + (lick_rate_050 | id), 
  data = lick, 
  silent = TRUE
)

## ----lick_conc----------------------------------------------------------------
# Remove conflicting columns
lick_ <- dplyr::select(lick, -lick_rate_050:-lick_rate_200)
lick_conc <- fui(
  photometry ~ lick + trial + session + (lick | id), 
  data = lick_, 
  concurrent = TRUE, 
  # uncomment the below line to parallelize the calculation
  # parallel = TRUE, n_cores = 4, 
  silent = TRUE
)

## ----plot models, fig.width = 6, fig.height = 4-------------------------------
# Sending outputs to a dummy variable makes the output cleaner
dummy <- fastFMM::plot_fui(lick_rate_050)
dummy <- fastFMM::plot_fui(lick_conc)

## ----x axis, fig.width = 6, fig.height = 4------------------------------------
align_time <- 0.4 # cue onset is at 2 seconds
sampling_Hz <- 12.5 # sampling rate
# plot titles: interpretation of beta coefficients
plot_names <- c("Intercept", "Lick(s)", "Trial", "Session") 
lick_conc_outs <- plot_fui(
  lick_conc,
  x_rescale = sampling_Hz, # rescale x-axis to sampling rate
  align_x = align_time, # align to cue onset
  title_names = plot_names,
  xlab = "Time (s)",
  num_row = 2, 
  return = TRUE
) 

## ----see outs-----------------------------------------------------------------
names(lick_conc_outs)

