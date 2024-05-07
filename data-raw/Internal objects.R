library(data.table)
library(readxl)

# Objects saved in R/sysdata.rda ----
color_list <- list(grey = '#69696990',
                   green = '#69ac3c',
                   red = '#cc4140bf')

# Models
model <- get(load(paste0(app_sys(), "/extdata/model_train_gbm_after_rfe_20240311.RData")))

# Domains with reverse scale with respect to for example tintelingen or doofheid
reverse_domains <- c("kracht", "uiterlijk", "activiteiten uitvoeren", "soepelheid/beweeglijkheid", "werk uitvoeren")

# Table containing chances patient want to continue with surgery
dt_continue_surgery <- data.table(read_excel(paste0(app_sys(), "/extdata/continue_surgery.xlsx"), range = "A2:L5"))
dt_continue_surgery = dcast(melt(dt_continue_surgery, id.vars = "PMG waarde"), variable ~ `PMG waarde`)

# Table containing track and track types with respect to diagnosis
dt_diagnosis_track <- data.table(read_excel(paste0(app_sys(), "/extdata/features gbm.xlsx"), range = "B20:F26"))

# Table containing questions texts with respect to input variables
dt_questions <- data.table(read_excel(paste0(app_sys(), "/extdata/features gbm.xlsx"), range = "A1:J16"))

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
