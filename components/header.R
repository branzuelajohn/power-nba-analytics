argonHeader <- argonDashHeader(
  gradient = TRUE,
  color = "default",
  separator = TRUE,
  separator_color = "secondary",
  argonCard(
    argonH1("Welcome to the Power NBA Analytics App", display = 4),
    hover_lift = FALSE,
    shadow = TRUE,
    shadow_size = NULL,
    hover_shadow = FALSE,
    border_level = 0,
    status = "primary",
    background_color = NULL,
    gradient = FALSE, 
    floating = FALSE,
    p(strong("Scroll below to use the features"), style = "font-size:13px;"),
    p(strong("Click on the 'About Us' page to find out more about the application"), style = "font-size:12px;"),
  ),
)

