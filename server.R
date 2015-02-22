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