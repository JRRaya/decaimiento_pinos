# 1. Carga de paquetes y datos necesarios
## 1.1. Limpiamos la RAM
rm(list = ls(all.names = TRUE))
pacman::p_unload(pacman::p_loaded(), character.only = TRUE)

## 1.2. Cargamos el paquete "sf"
library(sf)
library(dplyr)

## 1.3. Cargamos los datos de cada una de las CCAA
### 1.3.1. Definimos las rutas delas capas
rutas <- list.files("data/mfe_ccaa", 
                    pattern = "^MFE_.*\\.shp$", 
                    recursive = TRUE, 
                    full.names = TRUE)

rutas <- c("data/mfe_ccaa/andalucia/MFE_61.shp",
           "data/mfe_ccaa/aragon/MFE_24.shp",
           "data/mfe_ccaa/asturias/MFE_12.shp",
           "data/mfe_ccaa/cantabria/MFE_13.shp",
           "data/mfe_ccaa/catalunia/MFE_51.shp",
           "data/mfe_ccaa/galicia/MFE_11.shp",
           "data/mfe_ccaa/leon/MFE_41.shp",
           "data/mfe_ccaa/madrid/MFE_30.shp",
           "data/mfe_ccaa/mancha/MFE_42.shp",
           "data/mfe_ccaa/murcia/MFE_62.shp",
           "data/mfe_ccaa/navarra/MFE_22.shp",
           "data/mfe_ccaa/pais_vasco/MFE_21.shp",
           "data/mfe_ccaa/rioja/MFE_23.shp",
           "data/mfe_ccaa/valencia/MFE_52.shp")

# Filtramos para excluir archivos .shp.xml
rutas <- rutas[!grepl("\\.xml$", rutas)]

### 1.3.2. Definimos los nombres de las capas
nombres <- basename(dirname(rutas))

nombres <- c("andalucia",
             "aragon",
             "asturias",
             "cantabria",
             "catalunia",
             "galicia",
             "leon",
             "madrid",
             "mancha",
             "murcia",
             "navarra",
             "pais_vasco",
             "rioja",
             "valencia")

### 1.3.3. Creamos una lista donde guardar las capas cargadas
lista <- list()

### 1.3.4. Establecemos el CRS objetivo a partir de la capa de madrid (comprobado en QGIS)
m <- st_read(rutas[8])
crs_objetivo <- st_crs(m)
rm(m)
gc()

### 1.3.5. Cargamos las capas
for(ruta in rutas) {
  # 1. Comprobamos si existe el archivo
  # True, se detiene el bucle
  # False, se carga la capa
  if(file.exists(ruta)) {
    capa <- st_read(ruta, quiet = FALSE) 
  } else{ 
    stop("Error: Archivo no encontrado")
  }
  
  # 2.Comprobamos si la capa no tiene crs asignado
  # True, se detiene el bucle
  # False, se detecta si no coincide con crs_objetivo
    # True, se reproyecta acrs_objetivo
  if(is.na(st_crs(capa))) {
    stop("Error: Capa sin CRS asignado")
  } else {
    if (st_crs(capa) != crs_objetivo) {
      capa <- st_transform(capa, crs = crs_objetivo)
    }
  }
  
  # 3. Comprobamos que la capa contenga inconsistencias
  # True, se hace valida mediante st_make_valid()
  if(any(!st_is_valid(capa))) {
    capa <- st_make_valid(capa)
  }
  
  # 4. Guardamos la capa final en la lista de capas
  lista[[length(lista) + 1]] <- capa
  
  # 5. Liberamos la memoria RAM
  rm(capa)
  gc()
}

### 1.3.6. Nombramos las capas de la lista
names(lista) <- nombres

# 2. Unimos los atributos de todas las capas en una sola capa vectorial
espana <- bind_rows(lista)

## 2.1. Eliminamos la lista, de modo que que liberemos la RAM
rm(lista)
gc()

## 2.1. Comprobamos que no se hayan creado geometrias invalidas
if(any(!st_is_valid(espana))) {
  espana <- st_make_valid(espana)
}

# 3. Guardamos el resultado
st_write(espana,
         dsn = "outputs/espana.shp")