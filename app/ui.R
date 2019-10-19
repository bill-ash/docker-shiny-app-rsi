library(shiny)
library(tidyquant)
library(janitor)
library(gridExtra)

theme_set(theme_light())

SP500 <- read_csv("SP500.csv")
tickers <- SP500 %>% 
    distinct(symbol) %>% 
    unlist() %>% 
    as.vector()
# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
    
    # Application title
    titlePanel("Company RSI"),
    
    # Select some inputs 
    sidebarLayout(
        sidebarPanel(
            shiny::selectInput(inputId = "ticker", 
                               label = "Ticker", 
                               multiple = FALSE, 
                               choices = tickers),
            shiny::dateRangeInput(inputId = "date", 
                                  label = "Date Range:", 
                                  start = "2019-01-01", 
                                  end = Sys.Date())
        ),
        
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("RSI")
        )
    )
))