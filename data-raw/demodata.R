library(data.table)

dt_train <- data.table(model$trainingData)
dt_train = dt_train[, ".outcome" := NULL]

from_therapie_nl <- c("therapie", "therapie", "doel niet <br> behaald", "doel niet <br> behaald", "operatie", "operatie")
to_therapie_nl <- c("doel <br> behaald", "doel niet <br> behaald", "operatie", "geen <br> operatie", "doel <br> behaald ", "doel niet <br> behaald ")
from_therapie_en <- c("nonsurgical <br> treatment", "nonsurgical <br> treatment", "goal not <br> obtained", "goal not <br> obtained", "surgical <br> treatment", "surgical <br> treatment")
to_therapie_en <- c("goal <br> obtained", "goal not <br> obtained", "surgical <br> treatment", "no surgical <br> treatment", "goal <br> obtained ", "goal not <br> obtained ")

from_injection_nl <- c("injectie", "injectie", "doel niet <br> behaald", "doel niet <br> behaald", "operatie", "operatie")
to_injection_nl <- c("doel <br> behaald", "doel niet <br> behaald", "operatie", "geen <br> operatie", "doel <br> behaald ", "doel niet <br> behaald ")
from_injection_en <- c("injection", "injection", "goal not <br> obtained", "goal not <br> obtained", "surgical <br> treatment", "surgical <br> treatment")
to_injection_en <- c("goal <br> obtained", "goal not <br> obtained", "surgical <br> treatment", "no surgical <br> treatment", "goal <br> obtained ", "goal not <br> obtained ")

from_operatie_nl <- c("operatie", "operatie")
to_operatie_nl <- c("doel <br> behaald", "doel niet <br> behaald")
from_operatie_en <- c("surgical <br> treatment", "surgical <br> treatment")
to_operatie_en <- c("goal <br> obtained", "goal not <br> obtained")


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
                  from_injection_nl,
                  from_injection_en,
                  to_injection_nl,
                  to_injection_en,
                  from_operatie_nl,
                  to_operatie_nl,
                  from_operatie_en,
                  to_operatie_en,
                  model,
                  overwrite = TRUE)
