

library(tigris)
library(dplyr)
library(leaflet)
library(tidyverse)
library(sf)
library(rgdal)
library(htmlwidgets)

# Downloading the shapefiles for states at the lowest resolution
states <- states(cb=T)


states <- st_transform(states, CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

# get da csvs of historical fire percent for states
all <- read_csv("data/histAllStatePercent.csv")
mixed <- read_csv("data/histMixedStatePercent.csv")
replacement <- read_csv("data/histReplacementStatePercent.csv")
surface <- read_csv("data/histSurfaceStatePercent.csv")

states_fire1 <- geo_join(states, all, "NAME", "state", how = "inner")
states_fire2 <- geo_join(states_fire1, mixed, "NAME", "state")
states_fire3 <- geo_join(states_fire2, surface, "NAME", "state")
states_fireAll4 <- geo_join(states_fire3, replacement, "NAME", "state")


palAll <- colorNumeric("Reds", domain=states_fireAll4$percentAll)
palMixed <- colorNumeric("Reds", domain=states_fireAll4$percentMixed)
palReplacement <- colorNumeric("Reds", domain=states_fireAll4$percentReplacement)
palSurface <- colorNumeric("Reds", domain=states_fireAll4$percentSurface)


#################
tryAll <- leaflet(states_fireAll4) %>%
  # addTiles()  %>%
  setView( lat=38.89020900017848, lng=-97.85428689132351 , zoom=4) %>%
  addPolygons(fillColor = ~palAll(states_fireAll4$percentAll),
              stroke=TRUE,
              weight = 1,
              color = "grey",
              opacity = 5,
              fillOpacity = .9,
              group = "All fire types  combined (ranges from 0-25%)")%>%
addPolygons(fillColor = ~palMixed(states_fireAll4$percentMixed),
            stroke=TRUE,
            weight = 1,
            color = "grey",
            opacity = 5,
            fillOpacity = .9,
            group = "Mixed fire type (ranges from 0-3%)")%>%
addPolygons(fillColor = ~palReplacement(states_fireAll4$percentReplacement),
            stroke=TRUE,
            weight = 1,
            color = "grey",
            opacity = 5,
            fillOpacity = .9,
            group = "Replacement fire type (ranges from 0-15%)")%>%
addPolygons(fillColor = ~palSurface(states_fireAll4$percentSurface),
            stroke=TRUE,
            weight = 1,
            color = "grey",
            opacity = 5,
            fillOpacity = .9,
            group = "Surface fire type (ranges from 0-18%)") %>%

#
#   addLegend("bottomright", pal = palAll, values = ~states_fireAll4$percentAll,
#             title = "All fire types",
#             opacity = 1,
#             group = "All") %>%
#   addLegend("bottomright", pal = palMixed, values = ~states_fireAll4$percentMixed,
#             title = "Mixed Fires (25-75% top death)",
#             opacity = 1,
#             group = "Mixed") %>%
#   addLegend("bottomright", pal = palReplacement, values = ~states_fireAll4$percentReplacement,
#             title = "Replacement Fires (> 75% top death)",
#             opacity = 1,
#             group = "Replacement") %>%
#   addLegend("bottomright", pal = palSurface, values = ~states_fireAll4$percentSurface,
#             title = "Surface Fires (< 25% top death)",
#             opacity = 1,
#             group = "Surface") %>%



  addLayersControl(baseGroups = c("All Fire Types (ranges from 0-25%)", "Mixed fire type (ranges from 0-3%)", "Replacement fire type (ranges from 0-15%)", "Surface fire type (ranges from 0-18%)"),
                   options = layersControlOptions(collapsed = FALSE),
                   position = "bottomright")%>%
  htmlwidgets::onRender("
        function() {
            $('.leaflet-control-layers-overlays').prepend('<label style=\"text-align:center\">My Epic Title</label>');
        }
    ")

tryAll

tryAll %>% hideGroup(states_fireAll4$percentSurface)




