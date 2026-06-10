library(shiny)
library(shinydashboard)
library(plotly)
library(tidyverse)
library(lubridate)
# =====================================================
# Chargement server séparés
# =====================================================

source("server/axe1_server.R", local = TRUE)
source("server/axe2_server.R", local = TRUE)
source("server/axe3_server.R", local = TRUE)
source("server/axe4_server.R", local = TRUE)


# =====================================================
# SERVER PRINCIPAL
# =====================================================

shinyServer(function(input, output, session) {
  
  axe1_server(input, output, session)

  axe2_server(input, output, session)

  axe3_server(input, output, session)

  axe4_server(input, output, session)

})