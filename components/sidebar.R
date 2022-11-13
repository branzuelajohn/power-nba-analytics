argonSidebar <- argonDashSidebar(
  vertical = TRUE,
  skin = "light",
  background = "white",
  size = "lg",
  side = "left",
  id = "my_sidebar",
  brand_logo = "https://i.ibb.co/mGQ8919/basketball-team-logo-2.png",
  dropdownMenus = 
    argonSidebarHeader(title = "Navigation"),
  argonSidebarMenu(
    argonSidebarHeader(title = "Power NBA Analytics"),
    argonSidebarItem(
      tabName = "team_section",
      icon = argonIcon(name = "user-run", color = "warning"),
      "Team Overview"
    ),
    argonSidebarItem(
      tabName = "player_section",
      icon = argonIcon(name = "chart-pie-35", color = "grey"),
      "Player Analysis"
    ),
    argonSidebarDivider(),
    argonSidebarHeader(title = "Other"),
    argonSidebarItem(
      tabName = "about_us",
      icon = argonIcon(name = "circle-08", color = "grey"),
      "About Us"
    ),
    argonSidebarDivider(),
    actionButton("screenshot", "Take a screenshot"),
    argonSidebarDivider()
  )
)

