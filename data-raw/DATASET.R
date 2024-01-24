## code to prepare `DATASET` dataset goes here

dt_sankey_1 <- links <- data.frame(
  from=c("therapie","therapie", "doel niet behaald", "doel niet behaald"),
  to=c("doel behaald","doel niet behaald", "doel behaald <br> na operatie", "doel niet behaald <br> na operatie"),
  weight=c(55, 45, 65, 35)
)

dt_sankey_2 <- links <- data.frame(
  from=c("operatie", "operatie"),
  to=c("doel behaald","doel niet behaald"),
  weight=c(60, 40)
)

usethis::use_data(dt_sankey_1,
                  dt_sankey_2,
                  overwrite = TRUE)
