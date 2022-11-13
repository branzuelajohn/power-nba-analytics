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


