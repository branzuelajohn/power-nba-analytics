player_tab <- argonTabItem(
  tabName = "player_section",
  argonDashHeader(
    gradient = TRUE,
    color = "warning",
    top_padding = 8,
    bottom_padding = 8,
    argonRow(
      width = 12,
      
        argonCard(
          width = 12,
          status = "success",
          border_level = 0,
          hover_shadow = TRUE,
          argonH1("Weighted Ranks within Team", display = 4),
          p(strong("Do note that a higher rank (which is denoted by smaller number) correlates to better performance")),
          sidebarLayout(sidebarPanel(helpText("View weighted ranks within the team chosen"),
                                     selectInput(inputId ="teamWeight", 
                                                 label = "Choose a Team to display",
                                                 choices = list("WAS", "PHI", "ATL", "NYK", "MEM", "UTA", "BOS", "BKN", "LAL", "PHX", 
                                                                "DAL", "LAC", "MIA", "MIL", "POR", "DEN", "GSW", "IND", "SAS", "CHA",
                                                                "TOR", "HOU", "CLE", "ORL", "DET", "CHI", "MIN", "NOP", "OKC", "SAC"),
                                                 selected = "WAS"), 
                                     numericInput("weight_1", "FG_PCT", min = 0, max = 1, value = 0), 
                                     numericInput("weight_2", "FG3_PCT", min = 0, max = 1, value = 0), 
                                     numericInput("weight_3", "FT_PCT", min = 0, max = 1, value = 0), 
                                     numericInput("weight_4", "REB_PER_MIN", min = 0, max = 1, value = 0), 
                                     numericInput("weight_5", "AST_PER_MIN", min = 0, max = 1, value = 0), 
                                     numericInput("weight_6", "STL_PER_MIN", min = 0, max = 1, value = 0), 
                                     numericInput("weight_7", "BLK_PER_MIN", min = 0, max = 1, value = 0), 
                                     numericInput("weight_8", "PTS_PER_MIN", min = 0, max = 1, value = 0)), 
                        mainPanel(withSpinner(plotOutput(outputId = "ranks")))),
          argonButton(
            name = "Explain Chart",
            status = "primary",
            icon = argonIcon("atom"),
            size = "lg",
            toggle_modal = TRUE,
            modal_id = "modal1"
          ), 
          argonModal(
            id = "modal1",
            title = "Explanation on Weighted Ranks Chart",
            status = "primary",
            gradient = TRUE,
            #strong("Weighted"),
            p(strong("Select one team by clicking the drop down list and do the same for the other team")),
            p(strong("Enter the weightage of how important you think the Field goal points,3 Pointers,Free Throw Points, Rebounds per minute ,Assists per minute,Steals per minute , Blocks per minute and Points per min.")),
            p(strong("Note they should all add up to 1")),
            p(strong("Do note that a higher rank (which is denoted by smaller number) correlates to better performance"))
            ,tags$head(tags$style("#window .modal-footer{margin:auto}
                                       .modal-header .close{display:none}"))
          )
          
        ) ,
        argonCard(
          width = 12,
          background_color = "default",
          hover_lift = TRUE,
          hover_shadow = TRUE,
          argonH1("Player Statistics Within Team", display = 4) %>% argonTextColor(color = "white"),
          argonRow(
          sidebarPanel(helpText("View each team's statistic across players with option to 
               choose underperforming percentage"),
                       
                       selectInput(inputId ="teamPlayer", 
                                   label = "Choose a Team to display",
                                   choices = list("WAS", "PHI", "ATL", "NYK", "MEM", "UTA", "BOS", "BKN", "LAL", "PHX", 
                                                  "DAL", "LAC", "MIA", "MIL", "POR", "DEN", "GSW", "IND", "SAS", "CHA",
                                                  "TOR", "HOU", "CLE", "ORL", "DET", "CHI", "MIN", "NOP", "OKC", "SAC"),
                                   selected = "WAS"),
                       
                       selectInput(inputId ="stat", 
                                   label = "Choose a Stat to display",
                                   choices = list("FG_PCT", "FG3_PCT", "FT_PCT", "REB_PER_MIN", "AST_PER_MIN", "STL_PER_MIN",
                                                  "BLK_PER_MIN", "PTS_PER_MIN"),
                                   selected = "FG_PCT"),
                       
                       sliderInput(inputId ="percentile", 
                                   label = "Percentile under which player is underperforming:",
                                   min = 0, max = 1, value = 0.25 )
          ),
          
          mainPanel(
            withSpinner(plotOutput(outputId = "team_performance"))
          ))
        ),
        argonCard(
          width = 12,
          status = "success",
          border_level = 0,
          hover_shadow = TRUE,
          argonH1("Player Valuation", display = 4),
          argonRow(
          sidebarPanel(helpText("View weighted ranks against mean salaries in 2020. The regression 
                                                              line could be an indication of fair value for a player of certain weighted rank.
                                                              Any player paid more could be overvalued and switched for a player paid less.
                                                              Use your mouse to highlight and Zoom into selected players, represented by the points."),
                       numericInput("weights_1", "FG_PCT", min = 0, max = 1, value = 0), 
                       numericInput("weights_2", "FG3_PCT", min = 0, max = 1, value = 0), 
                       numericInput("weights_3", "FT_PCT", min = 0, max = 1, value = 0), 
                       numericInput("weights_4", "REB_PER_MIN", min = 0, max = 1, value = 0), 
                       numericInput("weights_5", "AST_PER_MIN", min = 0, max = 1, value = 0), 
                       numericInput("weights_6", "STL_PER_MIN", min = 0, max = 1, value = 0), 
                       numericInput("weights_7", "BLK_PER_MIN", min = 0, max = 1, value = 0), 
                       numericInput("weights_8", "PTS_PER_MIN", min = 0, max = 1, value = 0)), 
          mainPanel(withSpinner(plotlyOutput(outputId = "fairvalue"))
        )) 
      ) 
    )
  )
)
