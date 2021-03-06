#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # App title ----
    titlePanel("Uploading Data"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        
        # Sidebar panel for inputs ----
        sidebarPanel(
            
            # Input: Select a file ----
            fileInput("file1", "Choose CSV File",
                      multiple = FALSE,
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv")),
            
            # Horizontal line ----
            tags$hr(),
            
            # Input: Checkbox if file has header ----
            checkboxInput("header", "Header", TRUE),
            
            # Input: Select separator ----
            radioButtons("sep", "Separator",
                         choices = c(Comma = ",",
                                     Semicolon = ";",
                                     Tab = "\t"),
                         selected = ","),
            
            # Input: Select quotes ----
            radioButtons("quote", "Quote",
                         choices = c(None = "",
                                     "Double Quote" = '"',
                                     "Single Quote" = "'"),
                         selected = '"'),
            
            # Horizontal line ----
            tags$hr(),
            
            # Input: Select number of rows to display ----
            radioButtons("disp", "Display",
                         choices = c(Head = "head",
                                     All = "all"),
                         selected = "head"),
            
            tags$hr(),
            radioButtons("cc", "Column Check",
                         choices = c(No = "cc_no",
                                     Yes = "cc_yes"),
                         selected = "cc_no"),
            radioButtons("verLoc", "Verbatim Locality",
                         choices = c(No = "vl_no",
                                     Yes = "vl_yes"),
                         selected = "vl_no"),
            conditionalPanel(
                condition = "input.verLoc == 'vl_yes'",
                checkboxGroupInput("verLoc_cols",
                                   "Temp Checkbox",
                                   c("label 1" = "option1",
                                     "label 2" = "option2")),
            ),
            radioButtons("mst", "Material Sample Type",
                         choices = c(No = "mst_no",
                                     Yes = "mst_yes"),
                         selected = "mst_no"),
            radioButtons("conv", "Unit Conversions",
                         choices = c(No = "conv_no",
                                     Yes = "conv_yes"),
                         selected = "conv_no"),
            conditionalPanel(
                condition = "input.conv == 'conv_yes'",
                radioButtons("len", "Current Length Values",
                             choices = c(Inches = "in",
                                         Centimeters = "cm",
                                         Meters = "m",
                                         Millimeters = "mm"),
                             selected = "mm"),
                radioButtons("wght", "Current Weight Values",
                             choices = c(Pounds = "lbs",
                                         Kilograms = "kg",
                                         Milligrams = "mg",
                                         Grams = "g"),
                             selected = "g")
            ),
            radioButtons("s", "sex",
                         choices = c(No = "s_no",
                                     Yes = "s_yes"),
                         selected = "s_no"),
            radioButtons("yc", "Year Collected",
                         choices = c(No = "yc_no",
                                     Yes = "yc_yes"),
                         selected = "yc_no"),
            radioButtons("cv", "Country Validity",
                         choices = c(No = "cv_no",
                                     Yes = "cv_yes"),
                         selected = "cv_no"),
            radioButtons("msID", "Material Sample ID",
                          choices = c(No = "msID_no",
                                      Yes = "msID_yes"),
                          selected = "msID_no"),
            radioButtons("melt", "Data Melt",
                         choices = c(No = "melt_no",
                                     Yes = "melt_yes"),
                         selected = "melt_no"),
            conditionalPanel(
                condition = "input.melt == 'melt_yes'",
                checkboxGroupInput("dm_cols",
                                   "Temp Checkbox",
                                   c("label 1" = "option1",
                                     "label 2" = "option2")),
            ),
            #uiOutput("choose_columns")
        ),
        
        
        
        
        mainPanel(
            titlePanel("Data Pre-cleaning"),
            tableOutput("contents"),
            titlePanel("Data After Cleaning"),
            tableOutput("clean_data"),
            verbatimTextOutput("text")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        req(input$file1)
        
        df <- open_df(input$file1$datapath)
        
        if(input$disp == "head") {
            return(head(df))
        }
        else {
            return(df)
        }
    })
    
    output$clean_data <- renderTable({
        req(input$file1)
        
        df <- open_df(input$file1$datapath)
        df <- remove_rcna(df)
        ##----------------------------------------------------------------------
        if (input$verLoc == "vl_yes"){
            if (!is.null(input$verLoc_cols)){
                arr = c(input$verLoc_cols)
                df <- verLocal(df,arr)
            }
        }
        ##----------------------------------------------------------------------
        if (input$s == "s_yes"){
            df <- sex(df)
        }
        ##----------------------------------------------------------------------
        if (input$yc == "yc_yes"){
            df <- yc(df)
        }
        ##----------------------------------------------------------------------
        if (input$conv == "conv_yes") {
            if (input$len == "in") {
                df <- inConv(df)
            }
            if (input$len == "cm") {
                df <- cmConv(df)
            }
            if (input$len == "m") {
                df <- mConv(df)
            }
        }
        ##----------------------------------------------------------------------
        if (input$conv == "conv_yes") {
            if (input$wght == "lbs") {
                df <- lbsConv(df)
            }
            if (input$wght == "mg") {
                df <- mgConv(df)
            }
            if (input$wght == "kg") {
                df <- kgConv(df)
            }
        }
        if (input$melt == "melt_yes"){
            if (!is.null(input$dm_cols)){
                arr = c(input$dm_cols)
                df <- dataMelt(df,arr)
            }
        }
        ##----------------------------------------------------------------------
        if (input$disp == "head") {
            return(head(df))
        }
        else {
            return(df)
        }
    })
    
    observe({
        req(input$file1)
        df <- open_df(input$file1$datapath)
        df <- remove_rcna(df)
        df_cols <- names(df)
        cols <- list()
        cols[df_cols] <- df_cols
        #print(cb_options)
        updateCheckboxGroupInput(session, "verLoc_cols",
                                 label = "Select Desired columns",
                                 choices = cols,
                                 selected = NULL)
        updateCheckboxGroupInput(session, "dm_cols",
                                 label = "Select Desired columns",
                                 choices = cols,
                                 selected = NULL)
    })
    
    output$text <- renderPrint({
        req(input$file1)
        df <- open_df(input$file1$datapath)
        df <- remove_rcna(df)
        if (input$cc == "cc_yes"){
            cat(colcheck(df))
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
