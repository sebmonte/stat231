# 07-eventReactive

library(shiny)

#want update button to change graph instead of slider
#Can we prevent the graph from updating until we hit the button?

ui <- fluidPage(
  sliderInput(inputId = "num", 
    label = "Choose a number", 
    value = 25, min = 1, max = 100),
  actionButton(inputId = "go", 
    label = "Update"),
  plotOutput("hist")
)

server <- function(input, output) {
#Will invalidate expression when the go button is clicked
  data <- eventReactive(input$go, {
    rnorm(input$num) 
  })
#Now histogram depends on reactive expression that only invalidates
#When someone clicks the button
  output$hist <- renderPlot({
    hist(data())
  })
}

shinyApp(ui = ui, server = server)
