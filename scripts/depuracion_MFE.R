# 1. Carga de paquetes y datos necesarios
## 1.1. Limpiamos la RAM
rm(list = ls(all.names = TRUE))
pacman::p_unload(pacman::p_loaded(), character.only = TRUE)

## 1.2. Cargamos los paquetes necesarios
pacman::p_load(sf, dplyr, stringr)

## 1.3. Cargamos el MFE
### 1.3.1. Establecemos la ruta del archivo
ruta <- "outputs/MFE/MFE.gpkg"

### 1.3.2. Cargamos el archivo como un objeto "sf" con st_read()
MFE <- st_read(ruta)

# 2. Depuramos la capa del Mapa Forestal de España
## 2.1. Depuramos las columnas para quedarnos con la columna de especies y la de geometría
MFE_depurado <- MFE %>% 
  select(geom, Especie1)

# - Liberar RAM
rm(MFE)

## 2.2. Filtramos las filas que contengan alguna especie de pino 
## También cambiamos el nombre de la columna a "especie"
pinos <- MFE_depurado %>% 
  rename(especie = Especie1) %>% 
  filter(str_detect(tolower(especie),
                    "\\bpinus\\b")) 

# - Liberamos la RAM
rm(MFE_depurado)
gc()

# - Comprobamos que tan solo se han guardado las especies de pinos
especies_pinos <- pinos %>% 
  distinct(especie)

# 3. Guardamos el resultado
st_write(pinos,
         dsn = "outputs/pinos/pinos.gpkg",
         delete_dsn = TRUE)