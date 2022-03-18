library(sf)
library(dplyr)
library(elevatr)
library(readr)
e_valp <- st_read("files/e_valp_points.gpkg") %>%
  st_transform(32719)

elev <- get_elev_point(e_valp, src = "aws", z = 14)

elev <- 
elev %>%
  select(Name, elevation) %>%
  mutate(x = st_coordinates(.)[,1], y = st_coordinates(.)[,2]) %>%
  st_drop_geometry() %>%
  as_tibble() %>%
  mutate(dist_eucl = if_else(Name == lag(Name), sqrt((lag(x) - x)^2 + (lag(y) - y)^2), NA_real_), 
         `pendiente %` = 100*(elevation - lag(elevation))/dist_eucl) %>%
  rename(ruta = Name, elevación = elevation) %>%
  write_excel_csv("output/elev_quilp.csv")
