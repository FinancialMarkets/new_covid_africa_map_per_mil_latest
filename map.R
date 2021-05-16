library(highcharter)
library(tidyverse)
library(htmlwidgets)

mapdata <- get_data_from_map(download_map_data("custom/africa"))

options(browser = "/usr/bin/firefox")

data <- read_csv("./african_latest_data.csv")
data$updated_date <- as.Date(data$last_updated_date, format="%Y/%m/%d")

data_graphic <- data[, c("updated_date", "iso_code", "last_updated_date", "location", "total_cases_per_million", "new_cases_per_million", "total_cases", "new_cases", "total_deaths", "new_deaths")]

## remove france

data_graphic <- subset(data_graphic, location != "France")
data_graphic <- subset(data_graphic, location != "Seychelles")

## rename
data_graphic$`iso-a3` <- data_graphic$iso_code

## get latest day
latest_day <- max(unique(data_graphic$updated_date))

data_graphic_latest <- subset(data_graphic, updated_date == latest_day) 

## graphic

x <- c("Country", "New Cases Latest Day", "Total Number of Cases", "Number Cases Per Million", "Number of Deaths Latest Day", "Total Deaths")
y <- c( "{point.location}" , "{point.new_cases}", "{point.total_cases}", sprintf("{point.%s:.2f}", c("total_cases_per_million")), "{point.new_deaths}", "{point.total_deaths}")

tltip <- tooltip_table(x, y)

carmine <- "#960018"
dark_midnight_blue <- "#003366"
white <- "#FFFFFF"
milken <- "#0066CC"
milken_red <- "#ff3333"

## map cases per of pop
map_cases_per_mil <- hcmap("custom/africa", data = data_graphic_latest, value = "total_cases_per_million",
      joinBy = c("iso-a3"), name = "Confirmed Cases per Million",
      #dataLabels = list(enabled = TRUE, format = '{point.name}'),
      borderColor = "#FAFAFA", borderWidth = 0.1) %>%
     # tooltip = list(valueDecimals = 2, valuePrefix = "", valueSuffix = "")) %>%
      hc_tooltip(useHTML = TRUE, headerFormat = "", pointFormat = tltip) %>%
    hc_legend(align = "center", layout = "horizontal", verticalAlign = "middle", x = -160, y= 120, valueDecimals = 0) %>%
    hc_colorAxis(minColor = "#FFFFFF", maxColor = milken_red,
             type = "logarithmic")
  #    hc_legend(align = 'left') %>%
#      hc_add_theme(hc_theme_google())
map_cases_per_mil

## Save vis
saveWidget(map_cases_per_mil, file="map_cases_per_mil.html")
