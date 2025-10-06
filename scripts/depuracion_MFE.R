# 1. Carga de paquetes y datos necesarios
## 1.1. Limpiamos la RAM
rm(list = ls(all.names = TRUE))
pacman::p_unload(pacman::p_loaded(), character.only = TRUE)

## 1.2. Cargamos el paquete "sf"
library(sf)
library(dplyr)
library(stringr)

## 1.3. Cargamos el MFE
### 1.3.1. Establecemos la ruta del archivo
ruta <- "outputs/MFE.shp"

### 1.3.2. Cargamos el archivo como un objeto "sf" con st_read()
MFE <- st_read(ruta)

# 2. Depuramos la capa del Mapa Forestal de España
## 2.1. Filtramos las filas que contengan alguna especie de pino 
pinos <- MFE %>% 
  filter(str_detect(tolower(),
                    "//bpinus//b"))

## 2.2. Depuramos las columnas para quedarnos con la columna de especies y la de geometría
