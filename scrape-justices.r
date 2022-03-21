library(tidyverse)
library(kableExtra)
library(robotstxt) 
library(rvest) 
library(purrr) 


url <- "https://en.wikipedia.org/wiki/List_of_justices_of_the_Supreme_Court_of_the_United_States"

justice_table <- url %>%
  read_html() %>%
  html_elements("#mw-content-text > div.mw-parser-output > table") %>%
  pluck(2) %>%
  html_table() %>% 
  # Clean up variable names
  janitor::clean_names()

write_csv(justice_table, "justices.csv")
