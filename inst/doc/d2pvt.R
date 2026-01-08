## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE, 
  comment = "#>", 
  eval = F, # uncomment to skip long renders
  cache = T
)

## ----libraries----------------------------------------------------------------
# suppressMessages(library(fastFMM))
# suppressMessages(library(dplyr))

## ----read data----------------------------------------------------------------
# d2pvt <- fastFMM::d2pvt

## ----read d2pvt, echo = FALSE-------------------------------------------------
# d2pvt <- d2pvt %>%
#   mutate(
#     session = session - 1, trial = trial - 1,
#     latency = latency - mean(latency)
#   ) %>%
#   mutate(
#     trial = trial / max(trial),
#     session = session / max(session)
#   )

## ----d2pvt columns------------------------------------------------------------
# class(d2pvt$photometry)
# dim(d2pvt$photometry)

## ----unravel------------------------------------------------------------------
# d2pvt <- cbind(
#   d2pvt %>% select(-photometry, -rewarded),
#   # this unravels the matrices into data frames
#   as.data.frame(d2pvt$photometry),
#   as.data.frame(d2pvt$rewarded)
# )

## ----no zero variance---------------------------------------------------------
# # Remove columns of all zeros or all ones
# zero_var <- sapply(
#   select(d2pvt, rewarded_1:rewarded_121),
#   function(x)
#     var(x) <= 0.01
# )
# 
# zero_var_cols <- c(
#   paste0("photometry_", which(zero_var)),
#   paste0("rewarded_", which(zero_var))
# )
# 
# d2pvt_nonzero <- d2pvt[, !colnames(d2pvt) %in% zero_var_cols]

## ----kable data, echo = FALSE-------------------------------------------------
# d2pvt_nonzero %>%
#   select(id, latency, rewarded_45:rewarded_50) %>%
#   head() %>%
#   knitr::kable()

## ----fit concurrent-----------------------------------------------------------
# concurrent <- fastFMM::fui(
#   photometry ~ SMS * rewarded + (SMS | id),
#   d2pvt_nonzero,
#   concurrent = TRUE,
#   silent = TRUE
# )

## ----plot models, fig.width = 6, fig.height = 4-------------------------------
# sampling_Hz <- 8
# 
# dummy <- fastFMM::plot_fui(
#   concurrent,
#   x_rescale = sampling_Hz,
#   # 30 / sampling_Hz corresponds to the discarded columns
#   align_x = 3 - 30 / sampling_Hz
# )

## ----fit nonconcurrent--------------------------------------------------------
# nonconcurrent <- fastFMM::fui(
#   photometry ~ SMS * latency + (SMS | id),
#   d2pvt,
#   concurrent = FALSE,
#   silent = TRUE
# )

## ----plot nc, fig.width = 6, fig.height = 4-----------------------------------
# sampling_Hz <- 8
# dummy <- fastFMM::plot_fui(
#   nonconcurrent,
#   x_rescale = sampling_Hz,
#   align_x = 3
# )

