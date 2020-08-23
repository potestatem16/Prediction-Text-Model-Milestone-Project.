#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(markdown)
library(dplyr)
library(tm)
library(magrittr)
shinyUI(
    navbarPage("Predict2Word!",
               theme = shinytheme("spacelab"),
               tabPanel("Home",
                        HTML("<strong>Author: Manuel Diaz</strong>"),
                        br(),
                        tags$img(src = "NLP.png", width=850, height=200),
                        fluidPage(
                            titlePanel("Home"),
                            sidebarLayout(
                                sidebarPanel(
                                    textInput("userInput",
                                              "Enter a word or phrase:",
                                              value =  "",
                                              placeholder = "Enter text here"),
                                    br(),
                                    sliderInput("numPredictions", "Number of Predictions:",
                                                value = 1.0, min = 1.0, max = 3.0, step = 1.0)
                                ),
                                mainPanel(
                                    h4("Input text"),
                                    verbatimTextOutput("userSentence"),
                                    br(),
                                    h4("Predicted words"),
                                    verbatimTextOutput("prediction1"),
                                    verbatimTextOutput("prediction2"),
                                    verbatimTextOutput("prediction3")
                                )
                            )
                        )
               ),
               tabPanel("Instructions and More About.",
                        tags$img(src="beautiful.jpg", height=250, width=850),
                        h3("About Predict2Word!"),
                        br(),
                        div("'Predict2Word!' is a Shiny app that uses a text
                            prediction algorithm to predict the next word or words
                            based on text entered.",
                            br(),
                            br(),
                            "The method used to achieve this is based on the methods of NLP or 
                            natural language processing.
                            The predicted word or words, will be shown when the app
                            detects that you have finished typing one or more
                            words.",
                            br(),
                            br(),
                            "Use the slider tool to select up to three next
                            word predictions. The user can choose to predict one, 
                            two or three next words.")
               )
    )
)