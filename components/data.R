#libraries
library(ggplot2)
library(readxl)
library(dplyr)
library(plotly)
library(tidyr)
library(fmsb)


getSeasonData <- function(season) {
  game_details_by_season <- game_details_season[game_details_season$SEASON == season, ]
  # get subset of data for players who played >0 MINS
  game_details_by_season <- game_details_season[game_details_season$MINS >0, ]
  
  return (game_details_by_season)
}


plotWinRateLine <- function(data, team1, team2) {
  p <- df %>%filter(TEAM==team1|TEAM==team2)%>%ggplot(aes(x=SEASON_ID))+geom_line(aes(y=overall_average_by_team,color=TEAM,group=TEAM))+geom_line(aes(y=overall_average,color="overall_average",group=1))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = 6), axis.text.y = element_text(size = 6), panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    xlab('Season ID') + ylab('Win Rate')
  
  ggplotly(p) %>% add_trace(showlegend = T, hoverinfo = 'text') %>% 
    layout(hovermode = "x unified")
}

getNBADataBySeason <- function(season) {
  gd <- game_details_season
  nba <- gd[gd$MINS > 0 & gd$SEASON == season,]
  return(nba)
}


  


