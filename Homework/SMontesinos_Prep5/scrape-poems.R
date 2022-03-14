library(tidyverse)
library(kableExtra)
library(robotstxt) 
library(rvest) 
library(purrr) 

##################################
# Collect list of poems and URLs #
##################################

# Identify URL
url_poem_list <- "https://en.wikipedia.org/wiki/List_of_Emily_Dickinson_poems"

# Check if bots are allowed
paths_allowed(url_poem_list)

# Grab table of poems
poem_table <- url_poem_list %>%
  read_html() %>%
  # Only one matching table so use singular `html_element()` (no "s")
  html_element("#mw-content-text > div.mw-parser-output > table") %>%
  html_table() %>% 
  # Clean up variable names
  janitor::clean_names() %>%
  select(title = first_line_often_used_as_title)

# Grab URL of each poem 
url_href <- url_poem_list %>% 
  read_html() %>% 
  html_elements("#mw-content-text > div.mw-parser-output > table > tbody > tr > td > a") %>% 
  html_attr("href")

# Grab display text of each URL (i.e., poem title)
url_text <- url_poem_list %>% 
  read_html() %>% 
  html_elements("#mw-content-text > div.mw-parser-output > table > tbody > tr > td > a") %>% 
  html_text()

# Combine text and link into a dataframe
url_table <- tibble(title = url_text, href = url_href)

# Join with original poem table
poem_table <- poem_table %>% 
  left_join(url_table)


####################
# Scrape all poems #
####################

# Identify number of iterations (start with 1, 5, 20, 50, etc.)
n_links <- nrow(poem_table)

# Pre-allocate space for poem text
poem_tibble <- poem_table %>% 
  mutate(text = "") 

# Iterate through links to grab text
for(i in seq_len(n_links)){
  
  # Identify url
  link <- poem_table$href[i] 
  
  # Fix some wonky links
  ## Redirect to link with poem
  if(!is.na(link) & 
     link == "https://en.wikisource.org/wiki/I_never_lost_as_much_but_twice"){
    link <- "https://en.wikisource.org/wiki/Poems_(Dickinson)/I_never_lost_as_much_but_twice,"
  }
  
  ## Don't bother scraping; this is a subset of another poem
  if(!is.na(link) &
     link == "https://en.wikisource.org/wiki/The_earth_has_many_keys,"){
    link <- NA # poem already exists in Further in Summer than the birds Version 1
  }
  
  # Scrape poem text, using tryCatch() to handle errors
  poem_tibble$text[i] <- tryCatch(
    
    # Return "Missing" instead of poem text when error is thrown
    error = function(cnd) {
      return("Missing")
    },
    
    # Try to scrape poem text
    
    if(!is.na(link) &
       link == "https://en.wikisource.org/wiki/The_Himmaleh_was_known_to_stoop"){
      
      # Scrape div p text
      link %>% 
        read_html() %>% 
        html_elements("div p") %>% 
        pluck(1) %>% 
        html_text() %>% 
        return()
      
    } else {
      
      link %>% 
        read_html() %>% 
        html_elements(".poem, .wst-block-center, div p") %>% 
        html_text() %>% 
        str_remove(fixed(".mw-parser-output .dropinitial{float:left;text-indent:0}.mw-parser-output .dropinitial .dropinitial-fl{float:left;position:relative;vertical-align:top;line-height:1}.mw-parser-output .dropinitial .dropinitial-initial{float:left;line-height:1em;text-indent:0}")) %>% 
        return()
    }
  )
}

# Write poems to file (you may need to be more specific with your filepath)
write_csv(poem_tibble, "dickinson-poems.txt")
