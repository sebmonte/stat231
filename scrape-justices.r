
url <- "https://en.wikipedia.org/wiki/List_of_justices_of_the_Supreme_Court_of_the_United_States"

justice_table <- url %>%
  read_html() %>%
  html_element("#content > #bodyContent >#mw-content-text > #mw-parser-output > table") %>%
  html_table() %>% 
  # Clean up variable names
  janitor::clean_names()
