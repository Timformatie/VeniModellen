# Objects saved in R/sysdata.rda ----
color_list <- list(grey = '#69696990',
                   green = '#69ac3c',
                   red = '#cc4140bf')

# Models
#model_gbm <- get(load("inst/extdata/rfe_result_gbm_20231102.RData"))
#model <- get(load("inst/extdata/model_train_nnet_after_rfe_20240311.RData"))
model <- get(load("inst/extdata/model_train_gbm_after_rfe_20240311.RData"))

reverse_domains <- c("kracht", "uiterlijk", "activiteiten uitvoeren", "soepelheid/beweeglijkheid", "werk uitvoeren")

dt_continue_surgery <- data.table::data.table(readxl::read_excel("inst/extdata/continue_surgery.xlsx", range = "A2:L5"))
dt_continue_surgery = data.table::dcast(data.table::melt(dt_continue_surgery, id.vars = "PMG waarde"), variable ~ `PMG waarde`)

dt_diagnosis_track <- data.table::data.table(readxl::read_excel("inst/extdata/features gbm.xlsx", range = "B20:F26"))

dt_questions <- data.table::data.table(readxl::read_excel("inst/extdata/features gbm.xlsx", range = "A1:J16"))

usethis::use_data(
  color_list,
  model,
  reverse_domains,
  dt_continue_surgery,
  dt_diagnosis_track,
  dt_questions,
  internal = TRUE,
  overwrite = TRUE
)
