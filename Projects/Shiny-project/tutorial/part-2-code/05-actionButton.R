# 05-actionButton

library(shiny)

ui <- fluidPage(
  actionButton(inputId = "clicks", 
    label = "Click me")
)


server <- function(input, output) {
#Update whenever button is clicked because first argument is name of button
#when it updates it will run block of code that was given
#Will print number of clicks on r console
  observeEvent(input$clicks, {
    print(as.numeric(input$clicks))
  })
}

shinyApp(ui = ui, server = server)