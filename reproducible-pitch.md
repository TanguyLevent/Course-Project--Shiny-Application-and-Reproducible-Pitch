Shiny Application & Reproducible Pitch
========================================================
author: Rahul Tomar
date: 22nd Feb. 2015

Description
========================================================

This app is to generate the cloud of words by selecting the available book from the list , frequency of words as they appear and the maximum number of words to be displayed. There are 3 books in the list.

- The Thirty-nine Steps
- Greenmantle
- Mr. Standfast

global.R
========================================================


```r
library(tm)
library(wordcloud)
library(memoise)

# The list of valid books
books <<- list("The Thirty-Nine Steps by John Buchan" = "39-steps",
               "Greenmantle by John Buchan" = "Greenmantle",
               "Mr. Standfast by John Buchan" = "Standfast")

# Using "memoise" to automatically cache the results
getTermMatrix <- memoise(function(book) {
    # Careful not to let just any name slip in here; a
    # malicious user could manipulate this value.
    if (!(book %in% books))
        stop("Unknown book")
    
    text <- readLines(sprintf("./%s.txt", book),
                      encoding="UTF-8")
    
    myCorpus = Corpus(VectorSource(text))
    myCorpus = tm_map(myCorpus, content_transformer(tolower))
    myCorpus = tm_map(myCorpus, removePunctuation)
    myCorpus = tm_map(myCorpus, removeNumbers)
    myCorpus = tm_map(myCorpus, removeWords,
                      c(stopwords("SMART"), "thy", "thou", "thee", "the", "and", "but"))
    
    myDTM = TermDocumentMatrix(myCorpus,
                               control = list(minWordLength = 1))
    
    m = as.matrix(myDTM)
    
    sort(rowSums(m), decreasing = TRUE)
})
```

server.R
========================================================


```r
# Text of the books downloaded from:
# The Thirty-Nine Steps by John Buchan:
#  https://www.gutenberg.org/ebooks/558.txt.utf-8
# Greenmantle by John Buchan:
#  https://www.gutenberg.org/ebooks/559.txt.utf-8
# Mr. Standfast by John Buchan:
#  https://www.gutenberg.org/ebooks/560.txt.utf-8

function(input, output, session) {
    # Define a reactive expression for the document term matrix
    terms <- reactive({
        # Change when the "update" button is pressed...
        input$update
        # ...but not for anything else
        isolate({
            withProgress({
                setProgress(message = "Processing corpus...")
                getTermMatrix(input$selection)
            })
        })
    })
    
    # Make the wordcloud drawing predictable during a session
    wordcloud_rep <- repeatable(wordcloud)
    
    output$plot <- renderPlot({
        v <- terms()
        wordcloud_rep(names(v), v, scale=c(4,0.5),
                      min.freq = input$freq, max.words=input$max,
                      colors=brewer.pal(8, "Dark2"))
    })
}
```

```
function(input, output, session) {
    # Define a reactive expression for the document term matrix
    terms <- reactive({
        # Change when the "update" button is pressed...
        input$update
        # ...but not for anything else
        isolate({
            withProgress({
                setProgress(message = "Processing corpus...")
                getTermMatrix(input$selection)
            })
        })
    })
    
    # Make the wordcloud drawing predictable during a session
    wordcloud_rep <- repeatable(wordcloud)
    
    output$plot <- renderPlot({
        v <- terms()
        wordcloud_rep(names(v), v, scale=c(4,0.5),
                      min.freq = input$freq, max.words=input$max,
                      colors=brewer.pal(8, "Dark2"))
    })
}
```

ui.R
========================================================


```r
fluidPage(
    # Application title
    titlePanel("Word Cloud"),
    
    sidebarLayout(
        # Sidebar with a slider and selection inputs
        sidebarPanel(
            selectInput("selection", "Choose a book:",
                        choices = books),
            actionButton("update", "Change"),
            hr(),
            sliderInput("freq",
                        "Minimum Frequency:",
                        min = 1,  max = 50, value = 15),
            sliderInput("max",
                        "Maximum Number of Words:",
                        min = 1,  max = 300,  value = 100)
        ),
        
        # Show Word Cloud
        mainPanel(
            plotOutput("plot")
        )
    )
)
```

Output
========================================================

![Result](image.png)
