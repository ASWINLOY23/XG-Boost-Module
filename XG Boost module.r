library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinycssloaders)
library(shinyWidgets)
library(DT)
library(caret)
library(pROC)
library(xgboost)
library(plotly)

# =========================================================
# UI
# =========================================================

ui <- dashboardPage(
  
  skin = "black",
  
  dashboardHeader(
    title = tags$span(
      style = "font-weight:700; font-size:18px;",
      "XGBoost Analytics Studio"
    )
  ),
  
  dashboardSidebar(
    
    width = 260,
    
    sidebarMenu(
      id = "tabs",
      
      menuItem(
        "Data & Model Setup",
        tabName = "setup",
        icon = icon("database")
      ),
      
      menuItem(
        "Model Results",
        tabName = "results",
        icon = icon("chart-line")
      ),
      
      menuItem(
        "Predictions",
        tabName = "pred",
        icon = icon("table")
      )
    )
  ),
  
  dashboardBody(
    
    useShinyjs(),
    
    # =====================================================
    # CUSTOM CSS
    # =====================================================
    
    tags$head(
      tags$style(HTML("
        
        body {
          font-family: 'Segoe UI', sans-serif;
        }
        
        .content-wrapper,
        .right-side {
          background-color: #f4f7fb;
        }
        
        .content {
          padding: 25px;
        }
        
        .skin-black .main-header .logo {
          background: linear-gradient(90deg,#0f172a,#1e293b);
          color: white;
          font-weight: 700;
          border-bottom: 0px;
        }
        
        .skin-black .main-header .navbar {
          background: linear-gradient(90deg,#0f172a,#1e293b);
        }
        
        .skin-black .main-sidebar {
          background-color: #111827;
        }
        
        .skin-black .sidebar-menu > li.active > a {
          background-color: #2563eb;
          color: white;
          border-left-color: #60a5fa;
        }
        
        .skin-black .sidebar-menu > li > a {
          color: #d1d5db;
          font-size: 14px;
        }
        
        .skin-black .sidebar-menu > li:hover > a {
          background-color: #1f2937;
        }
        
        .box {
          border-radius: 18px;
          border-top: 0px;
          background: white;
          box-shadow: 0px 4px 20px rgba(0,0,0,0.08);
          transition: all 0.3s ease;
        }
        
        .box:hover {
          transform: translateY(-2px);
          box-shadow: 0px 8px 28px rgba(0,0,0,0.12);
        }
        
        .box-header {
          font-weight: 700;
          font-size: 16px;
        }
        
        .small-box {
          border-radius: 18px;
          box-shadow: 0px 4px 15px rgba(0,0,0,0.08);
        }
        
        .btn-success {
          background: linear-gradient(90deg,#2563eb,#1d4ed8);
          border: none;
          border-radius: 10px;
          font-size: 16px;
          padding: 10px 22px;
        }
        
        .btn-primary {
          border-radius: 10px;
        }
        
        .form-control {
          border-radius: 10px;
          border: 1px solid #d1d5db;
        }
        
        .hero-box {
          background: linear-gradient(135deg,#0f172a,#1e40af);
          color: white;
          border-radius: 20px;
          padding: 35px;
          margin-bottom: 25px;
          box-shadow: 0px 6px 25px rgba(0,0,0,0.15);
        }
        
        .hero-title {
          font-size: 34px;
          font-weight: 700;
        }
        
        .hero-subtitle {
          font-size: 16px;
          opacity: 0.9;
        }
        
      "))
    ),
    
    # =====================================================
    # TABS
    # =====================================================
    
    tabItems(
      
      # ===================================================
      # SETUP TAB
      # ===================================================
      
      tabItem(
        tabName = "setup",
        
        fluidRow(
          
          column(
            12,
            
            div(
              class = "hero-box",
              
              div(
                class = "hero-title",
                "Enterprise XGBoost Platform"
              ),
              
              br(),
              
              div(
                class = "hero-subtitle",
                "Advanced gradient boosting platform for enterprise-scale predictive analytics and high-performance machine learning."
              )
            )
          )
        ),
        
        fluidRow(
          
          box(
            title = "XGBoost Configuration",
            width = 12,
            
            br(),
            
            fluidRow(
              
              column(
                4,
                
                fileInput(
                  "file",
                  "Upload CSV Dataset",
                  accept = ".csv"
                )
              ),
              
              column(
                4,
                uiOutput("id_ui")
              ),
              
              column(
                4,
                uiOutput("target_ui")
              )
            ),
            
            br(),
            
            checkboxInput(
              "select_all",
              "Select All Predictors",
              FALSE
            ),
            
            uiOutput("predictor_ui"),
            
            br(),
            
            fluidRow(
              
              column(
                6,
                
                sliderInput(
                  "split",
                  "Training Percentage",
                  min = 50,
                  max = 90,
                  value = 70
                )
              ),
              
              column(
                6,
                
                sliderInput(
                  "nrounds",
                  "Boosting Rounds (nrounds)",
                  min = 50,
                  max = 2000,
                  value = 100,
                  step = 50
                )
              )
            ),
            
            fluidRow(
              
              column(
                6,
                
                sliderInput(
                  "eta",
                  "Learning Rate (eta)",
                  min = 0.01,
                  max = 0.5,
                  value = 0.1,
                  step = 0.01
                )
              ),
              
              column(
                6,
                
                sliderInput(
                  "max_depth",
                  "Maximum Tree Depth",
                  min = 2,
                  max = 15,
                  value = 6
                )
              )
            ),
            
            fluidRow(
              
              column(
                6,
                
                sliderInput(
                  "gamma",
                  "Minimum Loss Reduction",
                  min = 0,
                  max = 10,
                  value = 0,
                  step = 0.1
                )
              ),
              
              column(
                6,
                
                sliderInput(
                  "subsample",
                  "Subsample Ratio",
                  min = 0.5,
                  max = 1,
                  value = 1,
                  step = 0.05
                )
              )
            ),
            
            fluidRow(
              
              column(
                6,
                
                sliderInput(
                  "colsample_bytree",
                  "Column Subsample Ratio",
                  min = 0.5,
                  max = 1,
                  value = 1,
                  step = 0.05
                )
              ),
              
              column(
                6,
                
                prettySwitch(
                  "use_weights",
                  "Apply Class Weights",
                  status = "primary",
                  fill = TRUE
                )
              )
            ),
            
            br(),
            
            div(
              style = "text-align:center;",
              
              actionButton(
                "run_model",
                "Run XGBoost Model",
                icon = icon("play"),
                class = "btn-success btn-lg"
              )
            ),
            
            br()
          )
        )
      ),
      
      # ===================================================
      # RESULTS TAB
      # ===================================================
      
      tabItem(
        tabName = "results",
        
        fluidRow(
          
          valueBoxOutput("auc_box", width = 3),
          valueBoxOutput("accuracy_box", width = 3),
          valueBoxOutput("sensitivity_box", width = 3),
          valueBoxOutput("threshold_box", width = 3)
        ),
        
        fluidRow(
          
          column(
            width = 6,
            
            box(
              title = "ROC Curve",
              width = 12,
              height = 420,
              
              withSpinner(
                plotlyOutput("roc_plot", height = 320),
                type = 4
              )
            ),
            
            box(
              title = "Confusion Matrix",
              width = 12,
              height = 420,
              
              div(
                style = "
                  height:320px;
                  overflow-y:auto;
                  overflow-x:auto;
                  white-space: pre-wrap;
                  font-size:13px;
                ",
                
                verbatimTextOutput("conf_matrix")
              )
            )
          ),
          
          column(
            width = 6,
            
            box(
              title = "Feature Importance",
              width = 12,
              height = 420,
              
              withSpinner(
                plotOutput("feat_imp", height = 320),
                type = 4
              )
            ),
            
            box(
              title = "Prediction Probability Distribution",
              width = 12,
              height = 420,
              
              withSpinner(
                plotlyOutput("dist_plot", height = 320),
                type = 4
              )
            )
          )
        )
      ),
      
      # ===================================================
      # PREDICTIONS TAB
      # ===================================================
      
      tabItem(
        tabName = "pred",
        
        fluidRow(
          
          box(
            title = "Prediction Results",
            width = 12,
            
            div(
              style = "margin-bottom:15px;",
              
              downloadButton(
                "download_pred",
                "Download Predictions",
                class = "btn-primary"
              )
            ),
            
            DTOutput("prediction_table")
          )
        )
      )
    )
  )
)

# =========================================================
# SERVER
# =========================================================

server <- function(input, output, session) {
  
  observe({
    
    shinyjs::disable(selector = "a[data-value='results']")
    shinyjs::disable(selector = "a[data-value='pred']")
  })
  
  # =======================================================
  # DATA
  # =======================================================
  
  data <- reactive({
    
    req(input$file)
    
    read.csv(
      input$file$datapath,
      stringsAsFactors = FALSE
    )
  })
  
  # =======================================================
  # ID VARIABLE
  # =======================================================
  
  output$id_ui <- renderUI({
    
    req(data())
    
    selectInput(
      "id_var",
      "Unique Identifier",
      choices = c("None", names(data())),
      selected = "None"
    )
  })
  
  # =======================================================
  # TARGET VARIABLE
  # =======================================================
  
  output$target_ui <- renderUI({
    
    req(data())
    
    vars <- names(data())
    
    if(input$id_var != "None"){
      vars <- vars[vars != input$id_var]
    }
    
    selectInput(
      "target",
      "Target Variable",
      choices = vars
    )
  })
  
  # =======================================================
  # PREDICTOR VARIABLES
  # =======================================================
  
  output$predictor_ui <- renderUI({
    
    req(data(), input$target)
    
    vars <- names(data())
    
    if(input$id_var != "None"){
      vars <- vars[vars != input$id_var]
    }
    
    vars <- vars[vars != input$target]
    
    selectizeInput(
      "predictors",
      "Predictor Variables",
      choices = vars,
      multiple = TRUE
    )
  })
  
  # =======================================================
  # SELECT ALL
  # =======================================================
  
  observe({
    
    req(data(), input$target)
    
    vars <- names(data())
    
    if(input$id_var != "None"){
      vars <- vars[vars != input$id_var]
    }
    
    vars <- vars[vars != input$target]
    
    if(isTRUE(input$select_all)){
      
      updateSelectizeInput(
        session,
        "predictors",
        selected = vars
      )
    }
  })
  
  # =======================================================
  # MODEL TRAINING
  # =======================================================
  
  model_results <- eventReactive(input$run_model,{
    
    withProgress(
      message = "Training XGBoost Model...",
      value = 0,
      {
        
        df <- na.omit(data())
        
        req(input$target, input$predictors)
        
        df[[input$target]] <- as.factor(df[[input$target]])
        
        set.seed(123)
        
        train_index <- sample(
          1:nrow(df),
          (input$split/100)*nrow(df)
        )
        
        train <- df[train_index,]
        test <- df[-train_index,]
        
        incProgress(
          0.2,
          detail = "Encoding predictors..."
        )
        
        train_data <- train[, input$predictors, drop = FALSE]
        test_data  <- test[, input$predictors, drop = FALSE]
        
        train_matrix_numeric <- model.matrix(
          ~ . - 1,
          data = train_data
        )
        
        test_matrix_numeric <- model.matrix(
          ~ . - 1,
          data = test_data
        )
        
        train_matrix <- xgb.DMatrix(
          data = train_matrix_numeric,
          label = as.numeric(train[[input$target]]) - 1
        )
        
        test_matrix <- xgb.DMatrix(
          data = test_matrix_numeric,
          label = as.numeric(test[[input$target]]) - 1
        )
        
        incProgress(
          0.5,
          detail = "Training gradient boosting engine..."
        )
        
        # =================================================
        # CLASS WEIGHTS
        # =================================================
        
        if (input$use_weights) {
          
          label_counts <- table(train[[input$target]])
          
          weight0 <- as.numeric(
            label_counts[2] / sum(label_counts)
          )
          
          weight1 <- as.numeric(
            label_counts[1] / sum(label_counts)
          )
          
          scale_pos_weight <- weight1 / weight0
          
        } else {
          
          scale_pos_weight <- 1
        }
        
        params <- list(
          
          objective = "binary:logistic",
          eval_metric = "auc",
          eta = input$eta,
          max_depth = input$max_depth,
          gamma = input$gamma,
          subsample = input$subsample,
          colsample_bytree = input$colsample_bytree,
          scale_pos_weight = scale_pos_weight
        )
        
        model <- xgb.train(
          params = params,
          data = train_matrix,
          nrounds = input$nrounds,
          verbose = 0
        )
        
        incProgress(
          0.7,
          detail = "Generating predictions..."
        )
        
        test$prob <- predict(
          model,
          test_matrix
        )
        
        roc_obj <- roc(
          test[[input$target]],
          test$prob
        )
        
        threshold <- as.numeric(
          coords(
            roc_obj,
            "best",
            ret = "threshold"
          )
        )
        
        test$predicted_class <- ifelse(
          test$prob >= threshold,
          1,
          0
        )
        
        test$predicted_class <- as.factor(
          test$predicted_class
        )
        
        cm <- confusionMatrix(
          test$predicted_class,
          test[[input$target]],
          positive = "1"
        )
        
        incProgress(1)
        
        list(
          model = model,
          roc = roc_obj,
          auc = auc(roc_obj),
          threshold = threshold,
          cm = cm,
          predictions = test,
          train_matrix_numeric = train_matrix_numeric
        )
      }
    )
  })
  
  # =======================================================
  # ENABLE TABS
  # =======================================================
  
  observeEvent(model_results(),{
    
    shinyjs::enable(selector = "a[data-value='results']")
    shinyjs::enable(selector = "a[data-value='pred']")
    
    updateTabItems(session, "tabs", "results")
  })
  
  # =======================================================
  # KPI BOXES
  # =======================================================
  
  output$auc_box <- renderValueBox({
    
    req(model_results())
    
    valueBox(
      round(model_results()$auc,4),
      "AUC Score",
      icon = icon("chart-line"),
      color = "blue"
    )
  })
  
  output$accuracy_box <- renderValueBox({
    
    req(model_results())
    
    valueBox(
      round(model_results()$cm$overall["Accuracy"]*100,2),
      "Accuracy %",
      icon = icon("bullseye"),
      color = "green"
    )
  })
  
  output$sensitivity_box <- renderValueBox({
    
    req(model_results())
    
    valueBox(
      round(model_results()$cm$byClass["Sensitivity"]*100,2),
      "Sensitivity %",
      icon = icon("heartbeat"),
      color = "purple"
    )
  })
  
  output$threshold_box <- renderValueBox({
    
    req(model_results())
    
    valueBox(
      round(model_results()$threshold,4),
      "Threshold",
      icon = icon("sliders-h"),
      color = "yellow"
    )
  })
  
  # =======================================================
  # OUTPUTS
  # =======================================================
  
  output$roc_plot <- renderPlotly({
    
    req(model_results())
    
    roc_df <- data.frame(
      specificity = rev(model_results()$roc$specificities),
      sensitivity = rev(model_results()$roc$sensitivities)
    )
    
    plot_ly(
      roc_df,
      x = ~specificity,
      y = ~sensitivity,
      type = 'scatter',
      mode = 'lines',
      line = list(color = '#2563eb', width = 4)
    ) %>%
      layout(
        xaxis = list(title = "Specificity"),
        yaxis = list(title = "Sensitivity"),
        template = "plotly_white"
      )
  })
  
  output$dist_plot <- renderPlotly({
    
    req(model_results())
    
    plot_ly(
      x = model_results()$predictions$prob,
      type = "histogram"
    ) %>%
      layout(
        xaxis = list(title = "Predicted Probability"),
        yaxis = list(title = "Frequency"),
        template = "plotly_white"
      )
  })
  
  output$conf_matrix <- renderPrint({
    
    req(model_results())
    
    model_results()$cm
  })
  
  output$feat_imp <- renderPlot({
    
    req(model_results())
    
    importance_matrix <- xgb.importance(
      feature_names = colnames(
        model_results()$train_matrix_numeric
      ),
      
      model = model_results()$model
    )
    
    xgb.plot.importance(
      importance_matrix
    )
  })
  
  output$prediction_table <- renderDT({
    
    req(model_results())
    
    datatable(
      model_results()$predictions,
      
      extensions = 'Buttons',
      
      options = list(
        scrollX = TRUE,
        pageLength = 10,
        autoWidth = TRUE,
        dom = 'Bfrtip',
        buttons = list()
      ),
      
      class = "stripe hover compact"
    )
  })
  
  # =======================================================
  # DOWNLOAD
  # =======================================================
  
  output$download_pred <- downloadHandler(
    
    filename = function(){
      paste0(
        "Predictions_XGBoost_",
        Sys.Date(),
        ".csv"
      )
    },
    
    content = function(file){
      
      write.csv(
        model_results()$predictions,
        file,
        row.names = FALSE
      )
    }
  )
}

# =========================================================
# RUN APP
# =========================================================

shinyApp(ui, server)