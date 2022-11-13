team_tab <- argonTabItem(
  tabName = "team_section",
  argonDashHeader(
    gradient = TRUE,
    color = "secondary",
    separator = TRUE,
    separator_color = "secondary",
    top_padding = 8,
    bottom_padding = 8,
    argonRow(
      width = 12,
        argonCard(
          width = 12,
          background_color = "info",
          hover_lift = TRUE,
          hover_shadow = TRUE,
          argonH1("Team Win Rate Comparison", display = 4) %>% argonTextColor(color = "white"),
          argonRow(sidebarPanel(helpText("View win rate of teams by SEASONID, the blue line and red line are the teams you select while the green is the overall average in the NBA"),
                                selectInput(inputId ="TEAM", 
                                            label = "Choose a Team to display",
                                            choices =unique(ranking$TEAM)),
                                selectInput(inputId ="TEAM2", 
                                            label = "Choose a Team to display",
                                            selected = "Denver",
                                            choices =unique(ranking$TEAM))), mainPanel(withSpinner(plotlyOutput(outputId = "line"))))
        ) %>% argonMargin(orientation = "t", value = -100),
        argonCard(
          width = 12,
          status = "success",
          border_level = 0,
          hover_shadow = TRUE,
          argonH1("Team Performance Against NBA", display = 4),
          argonRow(sidebarPanel(helpText("Overview of Chosen Team vs NBA Average, Blue denotes the chosen team and the other colour denotes NBA average"),
                                selectInput(inputId ="team", 
                                            label = "Choose a Team to display",
                                            choices =unique(ranking$TEAM)),
                                selectInput(inputId ="season", 
                                            label = "Choose a Year to display",
                                            choices =unique(game_details_season$SEASON))), 
                                mainPanel(withSpinner(plotOutput('spiderplot')))
          
    )
  )))
)
