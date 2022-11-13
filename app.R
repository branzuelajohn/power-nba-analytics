# Shiny libraries
library(shiny)
library(argonR)
library(argonDash)
library(magrittr)
library(shinyWidgets)
library(shinycssloaders)
library(shinyjs)
library(dygraphs)
library(shinydisconnect)
library(shinyscreenshot)
library(shinyBS)

#other libraries
library(htmltools)
library(tidyr)
library(fmsb)
library(ggplot2)
library(readxl)
library(dplyr)
library(plotly)
library(tidyr)
library(fmsb)

# Get data
game_details_data <- read.csv("data/games_details.csv")
game_data <- read.csv("data/games.csv")
ranking<-read.csv("data/ranking.csv")
players_salary <- read_excel("data/player salary.xlsx")

##1. Replace '' in MIN in game_details with '0' and Convert MIN column to format HH.MM instead of HH:MM and convert to numeric
game_details_data <- mutate(game_details_data, MINS = gsub(':', '.', MIN))
game_details_data$MINS[game_details_data$MINS==''] <- '0'
game_details_data$MINS <- as.numeric(game_details_data$MINS)
##2.Add new column to show the season of each game played by matching season to game_ID in game_details_data dataframe
game_season <- game_data[c('GAME_ID', 'SEASON')]
game_details_season <- merge(game_details_data, game_season, by = "GAME_ID", all=T)
# get subset of data for 2020 season
game_details_2020 <- game_details_season[game_details_season$SEASON == 2020, ]
# get subset of data for players who played >0 MINS
game_details_2020 <- game_details_2020[game_details_2020$MINS >0, ]
#get subset of data for line graph
df<-ranking%>%group_by(TEAM,SEASON_ID)%>%summarise(overall_average_by_team=mean(W_PCT),overall_average=mean(ranking$W_PCT))
df$SEASON_ID<-as.factor(df$SEASON_ID)
game_details_data_with_season <- merge(game_details_data, game_season, by = "GAME_ID", all=T)
nba_2020_avg <- game_details_data_with_season[game_details_data_with_season$MINS > 0 & game_details_data_with_season$SEASON == 2020,]
nba_2020_avg <- nba_2020_avg %>% select('FG_PCT', 'FG3_PCT', 'FT_PCT', 'PTS', 'REB', 'AST', 'STL', 'BLK', 'TO', 'SEASON') %>% group_by(SEASON)
nba_2020_avg <- sapply(nba_2020_avg, mean)




#R scripts
source("load.R")
source("components/data.R")
# elements
source("components/team_tab.R")
source("components/player_tab.R")
source("components/about_us_tab.R")
#template
source("components/header.R")
source("components/sidebar.R")
source("components/footer.R")



#App
bsModalNoClose <-function(...) {
  b = bsModal(...)
  b[[2]]$`data-backdrop` = "static"
  b[[2]]$`data-keyboard` = "false"
  return(b)
}

ui <- argonDashPage(disconnectMessage(), title="Power NBA Analytics", author="Group 7", description ="Analyze NBA statistics", header=argonHeader, sidebar= argonSidebar,
 body = argonDashBody(useShinyjs(), bsModal("window", "Window", img = img(src="https://i.ibb.co/mGQ8919/basketball-team-logo-2.png", width=250, align='center'),
                                                               text = h1("Welcome to Power NBA Analytics!", align='center'),
                                                               text = h3("With this application you can: ", align='center'),
                                                               text= h4("1.View teams' win rates across seasons", align='center'),
                                            text= h4("2.Compare performance between teams", align='center'),
                                            text= h4("3.Analyse players' performance within teams ", align='center'),
                                            text= h4("4.Evaluate a players' valuation", align='center'),
                                                               title="",size='large',
                                                               footer = h5("Do remember not to click other buttons while the page is loading any content! There will be no response.",align='center'),
                                                               text = h3("Enjoy! And remember to maximise the window to have the best experience!", align='center'),
                                                               tags$head(tags$style("#window .modal-footer{margin:auto}
                                       .modal-header .close{display:none}"),tags$script("$(document).ready(function(){$('#window').modal();});"))),tags$style(".fa-arrow-down {color:#f5365c}"), tags$style(".fa-arrow-up {color:#2dce89}"),
                                         tags$head(tags$style("#render_stats{color: white;
                                 font-size: 15px;
                                 }" )), argonTabItems(team_tab, player_tab, about_us_tab)), footer=argonFooter)


#Define server logic
server <- function(input, output) {
  # Win Rates
  output$line<-renderPlotly({
    req(input$TEAM, input$TEAM2)
    plotWinRateLine(getLineGraphData(), input$TEAM, input$TEAM2)
  })
  
  teamspider <- reactive({game_details_season %>% filter(TEAM_CITY==input$team & SEASON ==input$season & MINS > 0) %>% select('FG_PCT', 'FG3_PCT', 'FT_PCT', 'PTS', 'REB', 'AST', 'STL', 'BLK', 'TO', 'SEASON') %>% group_by(SEASON)})

  #SPIDERPLOT
  output$spiderplot <- renderImage({
    req(input$team, input$season)
    teamData <- teamspider()
    teamData <- sapply(teamData, mean)
    avgNbaDataSeason <- getNBADataBySeason(input$season) %>% select('FG_PCT', 'FG3_PCT', 'FT_PCT', 'PTS', 'REB', 'AST', 'STL', 'BLK', 'TO', 'SEASON') %>% group_by(SEASON)
    avgNbaDataSeason <- sapply(nba_2020_avg, mean)
    nbaData <- avgNbaDataSeason
    statsVector <- c('FG_PCT', 'FG3_PCT', 'FT_PCT', 'PTS', 'REB', 'AST', 'STL', 'BLK')
    team_stats <- teamData[statsVector]
    nba_stats <- nbaData[statsVector]
    df <- data.frame(Statistic=names(team_stats), Average_value=team_stats)
    df2 <-data.frame(Statistic=names(nba_stats), Average_value=nba_stats)
    df2$baseline <- df2$Average_value/df2$Average_value
    df$compare <- df$Average_value/df2$Average_value
    radardf <- merge(df[,c('Statistic','compare')], df2[,c('Statistic', 'baseline')])
    tidy <- radardf[,c('compare', 'baseline')]
    tidy <- spread(radardf, Statistic, compare)
    dat <- tidy[,2:9]
    radDf <- rbind(rep(1.2,8), rep(0.8,8), dat, rep(1,8))
    rownames(radDf) <- c('Max.', 'Min.', 'Team', 'Avg')
    radDf <- radDf * 100
   
    img <- htmltools::capturePlot({
      radarchart(radDf, cglty = 1, title="Spider Plot of Team Average vs NBA Average", cglcol = "grey", pcol = 2:4, plwd = 2, pfcol = c(rgb(0, 0.4, 1, 0.25), rgb(1,0,0,0.25)), caxislabels= seq(0,100,20))
    }, height = 400, width = 400)
    list(src = img, width = 550, height = 550)
  },deleteFile = TRUE)

  
 
  team <- reactive({game_details_2020 <- game_details_2020 %>% filter(TEAM_ABBREVIATION==input$teamWeight) %>% group_by(PLAYER_NAME) %>% summarise(FG_PCT = mean(FG_PCT), FG3_PCT = mean(FG3_PCT), FT_PCT = mean(FT_PCT), REB_PER_MIN = sum(REB)/sum(MINS),AST_PER_MIN = sum(AST)/sum(MINS), STL_PER_MIN = sum(STL)/sum(MINS), BLK_PER_MIN = sum(BLK)/sum(MINS), PTS_PER_MIN = sum(PTS)/sum(MINS), MINS = sum(MINS)) %>% 
    as.data.frame(.) })
  # Weighted Ranks
  output$ranks <- renderPlot({
    if ((input$weight_1 + input$weight_2 + input$weight_3 + input$weight_4 + input$weight_5 + input$weight_6 + input$weight_7 + input$weight_8) != 1)
    {stop('Sum of inputs should be 1')}
  
  selectedteam <- team() 
  
  # Assign rank based on each indicator 
  selectedteam$fg_rank <- rank(-selectedteam$FG_PCT)
  selectedteam$fg3_rank <- rank(-selectedteam$FG3_PCT)
  selectedteam$ft_rank <- rank(-selectedteam$FT_PCT)
  selectedteam$ast_rank <- rank(-selectedteam$AST_PER_MIN)
  selectedteam$pts_rank <- rank(-selectedteam$PTS_PER_MIN)
  selectedteam$stl_rank <- rank(-selectedteam$STL_PER_MIN)
  selectedteam$reb_rank <- rank(-selectedteam$REB_PER_MIN)
  selectedteam$blk_rank <- rank(-selectedteam$BLK_PER_MIN)
  
  # Create new column to consolidate weighted ranks
  ranked_subset <- mutate(selectedteam, weighted_rank=(fg_rank*input$weight_1 + fg3_rank*input$weight_2 + ft_rank*input$weight_3 + ast_rank*input$weight_4
                                                       + pts_rank*input$weight_5 +stl_rank*input$weight_6 + reb_rank*input$weight_7 + blk_rank*input$weight_8))
  
  # Plot team's ranksse
  ggplot() + geom_bar(data=ranked_subset, aes(x=reorder(PLAYER_NAME,-weighted_rank, sum), y=weighted_rank), stat='identity', fill='#8F00FF') + theme(axis.text.x = element_text(angle = 90), panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + ylab('Weighted Rank') + xlab('Player Name')
  
  })
  
  # Get subset of data for selected team and summary statistics for each player in selected team
  selectedteam_players <- reactive({ 
    game_details_2020[game_details_2020$TEAM_ABBREVIATION == input$teamPlayer,] %>% group_by(PLAYER_NAME) %>% summarise(FG_PCT = mean(FG_PCT), FG3_PCT = mean(FG3_PCT), FT_PCT = mean(FT_PCT), REB_PER_MIN = sum(REB)/sum(MINS),AST_PER_MIN = sum(AST)/sum(MINS), STL_PER_MIN = sum(STL)/sum(MINS), BLK_PER_MIN = sum(BLK)/sum(MINS), PTS_PER_MIN = sum(PTS)/sum(MINS), MINS = sum(MINS)) %>% as.data.frame(.)
  })
  
  # Player Statistics within team
  output$team_performance <-renderPlot(
    {
      selectedteam_players_subsset <- selectedteam_players()
      
      # Create new col to indicate underperforming players acc to selected underperforming percentile
      selectedteam_players_subsset <- mutate(selectedteam_players_subsset, 
                                             Underperforming
                                             =(percent_rank(selectedteam_players_subsset[[input$stat]])<input$percentile))
      
      yintercept <- quantile(selectedteam_players_subsset[[input$stat]], probs= input$percentile)
      
      # Plot selected stat: 
      ggplot(selectedteam_players_subsset) + geom_bar(aes(x=reorder(PLAYER_NAME, -!!sym(input$stat)), y=!!sym(input$stat), fill=Underperforming), 
                                                      stat="identity") + scale_fill_manual(values = c("TRUE" = "red", "FALSE" = "lightblue")) + geom_hline(aes(yintercept=yintercept), colour="red") + theme(axis.text.x = element_text(angle = 90), panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + xlab("Player Names")
    }
  )
  
  # Player Valuations
  output$fairvalue <- renderPlotly(
    { if ((input$weights_1 + input$weights_2 + input$weights_3 + input$weights_4 + input$weights_5 + input$weights_6 + input$weights_7 + input$weights_8) != 1)
    {stop('Sum of inputs should be 1')}
      
      selectedskill <- game_details_2020 %>% group_by(PLAYER_NAME) %>% summarise(FG_PCT = mean(FG_PCT), FG3_PCT = mean(FG3_PCT), FT_PCT = mean(FT_PCT), REB = sum(REB), AST = sum(AST), STL = sum(STL), BLK = sum(BLK), PTS=sum(PTS), MINS = sum(MINS)) %>% 
        mutate(PTS_PER_MIN = PTS/MINS, REB_PER_MIN = REB/MINS, AST_PER_MIN = AST/MINS, STL_PER_MIN= STL/MINS, BLK_PER_MIN = BLK/MINS) %>% as.data.frame(.) 
      
      # Assign rank based on each indicator 
      selectedskill$fg_rank <- rank(-selectedskill$FG_PCT)
      selectedskill$fg3_rank <- rank(-selectedskill$FG3_PCT)
      selectedskill$ft_rank <- rank(-selectedskill$FT_PCT)
      selectedskill$ast_rank <- rank(-selectedskill$AST_PER_MIN)
      selectedskill$pts_rank <- rank(-selectedskill$PTS_PER_MIN)
      selectedskill$stl_rank <- rank(-selectedskill$STL_PER_MIN)
      selectedskill$reb_rank <- rank(-selectedskill$REB_PER_MIN)
      selectedskill$blk_rank <- rank(-selectedskill$BLK_PER_MIN)
      
      # Create new column to consolidate weighted ranks
      ranked_subset <- mutate(selectedskill, weighted_rank=(fg_rank*input$weights_1 + fg3_rank*input$weights_2 + ft_rank*input$weights_3 + ast_rank*input$weights_4
                                                            + pts_rank*input$weights_5 +stl_rank*input$weights_6 + reb_rank*input$weights_7 + blk_rank*input$weights_8))
      
      # join to players_salary
      salary_ranked_subset <- left_join(ranked_subset, players_salary, by=c("PLAYER_NAME" = "PLAYER"))
      salary_ranked_subset$SALARY <- as.integer(salary_ranked_subset$SALARY)
      
      # Plot team's ranks
      p <- ggplot(data=salary_ranked_subset, aes(x=weighted_rank, y=SALARY)) + geom_point(aes(text=salary_ranked_subset$PLAYER_NAME, color = 'Individual Player'), alpha=0.3) + geom_smooth(size=.5, se=F, aes(color="Smoothed Mean-Regressed Salary")) + 
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
      ggplotly(p) %>% add_trace(hoverinfo = 'text', showlegend = T) %>% layout(hovermode = "x unified", legend=list(orientation = 'h'), xaxis = list(title = 'Weighted Rank'), 
                                                                               yaxis = list(title = 'Salary'))
    }
  )
  
  # Allow Screenshots
  observeEvent(input$screenshot, {
    screenshot()
  })
}



shinyApp(ui=ui, server=server)
