server <- shinyServer(function(input, output, session) {
    
    SP500 <- read_csv("SP500.csv")
    tickers <- SP500 %>% 
        distinct(symbol) %>% 
        unlist() %>% 
        as.vector()
    
    
    z <- SP500 %>% 
        split(f = .["symbol"]) 
    
    
    vec <- vector("list")
    
    for (i in seq_along(z)) {
        vec[[i]] <- TTR::RSI(z[[i]][7])
    }
    
    p <- map_df(vec, tibble, .id = "RSI") 
    
    screen <- bind_cols(SP500, p) %>% janitor::clean_names()
    
    
    dat <- reactive({
        screen %>% 
            filter(symbol %in% input$ticker, 
                   date >= input$date[1], date <= input$date[2]) 
            
    })
    
    
    top <- reactive({
        
         dat() %>% 
            ggplot(aes(date, dbl))+
            geom_line()+
            geom_hline(yintercept = 30, color = "green")+
            geom_hline(yintercept = 70, color = "red")+
            labs(title = paste(input$ticker),
                 x = "", 
                 y = "RSI")+
            labs(x = "", y = "RSI")+
            scale_x_date(date_breaks = "1 month", date_labels = "%m-%d") 
        #theme(axis.text.x = element_text(angle = 45, hjust = 1))
        
        
    })
    
    bottom <- reactive({
        
        screen %>% 
            filter(symbol %in% input$ticker, 
                   date >= input$date[1], date <= input$date[2]) %>%  
            group_by(symbol) %>% 
            mutate(rtn = close/ lag(close)-1,
                   rtn = ifelse(is.na(rtn), 0, rtn), 
                   cumrtn = cumsum(rtn), 
                   xmin = ifelse(dbl < 30 | dbl > 70, date, NA), 
                   xmax = ifelse(dbl < 30 | dbl > 70, date +1, NA), 
                   xmin = as.Date(xmin), 
                   xmax = as.Date(xmax)) %>% 
            ungroup() %>% 
            ggplot(aes(date, cumrtn))+
            geom_line()+
            geom_rect(mapping = aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf),  color = "grey", alpha = 0.1)+
            scale_x_date(date_breaks = "1 month", date_labels = "%m-%d-%y")+
            scale_y_continuous(labels = scales::percent_format()) +
            labs(x = "", 
                 y = "Return") 
        #theme(axis.text.x = element_text(angle = 45, hjust = 1))
        
        
        
    })
    
    output$RSI <- renderPlot(grid.arrange(top(), bottom(), ncol = 1))
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("data-", Sys.Date(), ".csv", sep="")
        },
        content = function(file) {
            write.csv(dat(), file)
        }
    ) 
        
        })
    