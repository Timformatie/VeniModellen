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

# dt_sankey_3 <- links <- data.frame(
#   from=c("therapie",
#          "therapie",
#          "doel niet behaald",
#          "doel niet behaald",
#          "operatie",
#          "operatie"
#          ),
#   to=c("doel behaald",
#        "doel niet behaald",
#        "operatie",
#        "geen operatie",
#        "doel behaald ",
#        "doel niet behaald "
#        ),
#   weight=c(75, 25, 30, 70, 85, 15)
# )

dt_sankey_3 <- links <- data.frame(
  from=c("therapie","therapie", "doel niet <br> behaald", "doel niet <br> behaald", "operatie", "operatie"),
  to=c("doel <br> behaald","doel niet <br> behaald", "operatie", "geen <br> operatie", "doel <br> behaald ", "doel niet <br> behaald "),
  weight=c(75, 25, 30*0.25, 70*0.25, 85*0.3*0.25, 15*0.3*0.25),
  label=c(75, 25, 30, 70, 85, 15)
)

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

dt_train <- data.table::data.table(model$trainingData)
dt_train = dt_train[, ".outcome" := NULL]

from_therapie_nl <- c("therapie","therapie", "doel niet <br> behaald", "doel niet <br> behaald", "operatie", "operatie")
to_therapie_nl <- c("doel <br> behaald","doel niet <br> behaald", "operatie", "geen <br> operatie", "doel <br> behaald ", "doel niet <br> behaald ")
from_therapie_en <- c("nonsurgical <br> treatment","nonsurgical <br> treatment", "goal not <br> obtained", "goal not <br> obtained", "surgical <br> treatment", "surgical <br> treatment")
to_therapie_en <- c("goal <br> obtained","goal not <br> obtained", "surgical <br> treatment", "no surgical <br> treatment", "goal <br> obtained ", "goal not <br> obtained ")

from_operatie_nl <- c("operatie", "operatie")
to_operatie_nl <- c("doel <br> behaald","doel niet <br> behaald")
from_operatie_en <- c("surgical <br> treatment","surgical <br> treatment")
to_operatie_en <- c("goal <br> obtained","goal not <br> obtained")


usethis::use_data(dt_sankey_1,
                  dt_sankey_2,
                  dt_sankey_3,
                  dt_sankey_4,
                  dt_sankey_5,
                  dt_train,
                  from_therapie_nl,
                  from_therapie_en,
                  to_therapie_nl,
                  to_therapie_en,
                  from_operatie_nl,
                  to_operatie_nl,
                  from_operatie_en,
                  to_operatie_en,
                  model,
                  reverse_domains,
                  overwrite = TRUE)
