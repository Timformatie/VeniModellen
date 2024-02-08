## code to prepare `DATASET` dataset goes here

dt_sankey_1 <- links <- data.frame(
  from=c("therapie","therapie", "doel niet behaald", "doel niet behaald"),
  to=c("doel behaald","doel niet behaald", "doel behaald <br> na operatie", "doel niet behaald <br> na operatie"),
  weight=c(70, 30, 85, 15)
)

dt_sankey_2 <- links <- data.frame(
  from=c("operatie", "operatie"),
  to=c("doel behaald","doel niet behaald"),
  weight=c(80, 20)
)

dt_sankey_3 <- links <- data.frame(
  from=c("therapie","therapie", "doel niet behaald", "doel niet behaald", "operatie", "operatie"),
  to=c("doel behaald","doel niet behaald", "operatie", "geen operatie", "doel behaald ", "doel niet behaald "),
  weight=c(75, 25, 30, 70, 85, 15)
)

# dt_sankey_3 <- links <- data.frame(
#   from=c("therapie","therapie", "doel niet behaald", "doel niet behaald", "operatie", "operatie"),
#   to=c("doel behaald","doel niet behaald", "operatie", "geen operatie", "doel behaald ", "doel niet behaald "),
#   weight=c(75, 25, 30*0.25, 70*0.25, 85*0.3*0.25, 15*0.3*0.25)
# )

dt_sankey_4 <- links <- data.frame(
  from=c("therapie","therapie", "doel niet behaald", "doel niet behaald"),
  to=c("doel behaald","doel niet behaald", "doel behaald <br> na operatie", "doel niet behaald <br> na operatie"),
  weight=c(55, 45, 65, 35)
)

dt_sankey_5 <- links <- data.frame(
  from=c("operatie", "operatie"),
  to=c("doel behaald","doel niet behaald"),
  weight=c(60, 40)
)

model <- get(load("rfe_result_gbm_20231102.RData"))
dt_train <- model$fit$trainingData

usethis::use_data(dt_sankey_1,
                  dt_sankey_2,
                  dt_sankey_3,
                  dt_sankey_4,
                  dt_sankey_5,
                  dt_train,
                  overwrite = TRUE)
