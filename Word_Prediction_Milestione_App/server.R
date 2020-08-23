#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

setwd("C:/Users/aleja/Documents/Cursos/Coursera R pratices/Milestone_Final_Assignment_Shiny App NLP/Word_Prediction_Milestione_App")

readRDS("start-word.RData")->start_word
readRDS("df_bigram.RData")->bigram
readRDS("df_trigram.RData")->trigram
readRDS("df_quadgram.RData")->quadgram
head(bigram)
head(trigram)
head(quadgram)


# load bad words file
"bad-words.txt"->bad_words
readLines(file(bad_words, open = "r"),
          encoding = "latin1", skipNul = TRUE)->vulgarity


matching_words<- function(userInput, ngrams) {
    
    # quadgram (and higher)
    if (ngrams > 3) {
        userInput3 <- paste(userInput[length(userInput) - 2],
                            userInput[length(userInput) - 1],
                            userInput[length(userInput)])
        dataTokens <- quadgram %>% filter(token == userInput3)
        if (nrow(dataTokens) >= 1) {
            return(dataTokens$quadgram[1:3])
        }
        # backoff to trigram
        return(matching_words(userInput, ngrams - 1))
    }
    
    # trigram
    if (ngrams == 3) {
        userInput1 <- paste(userInput[length(userInput)-1], userInput[length(userInput)])
        dataTokens <- trigram %>% filter(token == userInput1)
        if (nrow(dataTokens) >= 1) {
            return(dataTokens$trigram[1:3])
        }
        # backoff to bigram
        return(matching_words(userInput, ngrams - 1))
    }
    
    # bigram (and lower)
    if (ngrams < 3) {
        userInput1 <- userInput[length(userInput)]
        dataTokens <- bigram %>% filter(token == userInput1)
        return(dataTokens$bigram[1:3])
    }
    return(NA)
}

text_cleaning <- function(input) {
    
    if (input == "" | is.na(input)) {
        return("")
    }

    input <- input %>% 
        tolower()
    
    
    # remove URL, email addresses, Twitter handles and hash tags
    input <- gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", input,  perl = TRUE)
    input <- gsub("\\S+[@]\\S+", "", input,  perl = TRUE)
    input <- gsub("@[^\\s]+", "", input,  perl = TRUE)
    input <- gsub("#[^\\s]+", "", input,  perl = TRUE)
    
    # remove ordinal numbers
    input <- gsub("[0-9](?:st|nd|rd|th)", "", input,  perl = TRUE)
    
    # remove profane words
    input <- removeWords(input, vulgarity)
    
    # remove punctuation
    input <- gsub("[^\\p{L}'\\s]+", "", input,  perl = TRUE)
    
    # remove punctuation (leaving ')
    input <- gsub("[.\\-!]", " ", input,  perl = TRUE)
    
    # trim leading and trailing whitespace
    input <- gsub("^\\s+|\\s+$", "", input)
    input <- stripWhitespace(input)
    
    # debug
    #print(paste0("output: ", input))
    #print("---------------------------------------")
    
    if (input == "" | is.na(input)) {
        return("")
    }
    
    input <- unlist(strsplit(input, " "))
    
    return(input)
    
}
predict_word <- function(input, word = 0) {
    
    input <- text_cleaning(input)
    
    if (input[1] == "") {
        output <- start_word
    } else if (length(input) == 1) {
        output <- matching_words(input, ngrams = 2)
    } else if (length(input) == 2) {
        output <- matching_words(input, ngrams = 3)
    } else if (length(input) > 2) {
        output <- matching_words(input, ngrams = 4)
    }
    
    if (word == 0) {
        return(output)
    } else if (word == 1) {
        return(output[1])
    } else if (word == 2) {
        return(output[2])
    } else if (word == 3) {
        return(output[3])
    }
    
}

shinyServer(function(input, output) {
    
    # original sentence
    output$userSentence <- renderText({input$userInput});
    
    # reactive controls
    observe({
        numPredictions <- input$numPredictions
        if (numPredictions == 1) {
            output$prediction1 <- reactive({predict_word(input$userInput, 1)})
            output$prediction2 <- NULL
            output$prediction3 <- NULL
        } else if (numPredictions == 2) {
            output$prediction1 <- reactive({predict_word(input$userInput, 1)})
            output$prediction2 <- reactive({predict_word(input$userInput, 2)})
            output$prediction3 <- NULL
        } else if (numPredictions == 3) {
            output$prediction1 <- reactive({predict_word(input$userInput, 1)})
            output$prediction2 <- reactive({predict_word(input$userInput, 2)})
            output$prediction3 <- reactive({predict_word(input$userInput, 3)})
        }
    })
    
})