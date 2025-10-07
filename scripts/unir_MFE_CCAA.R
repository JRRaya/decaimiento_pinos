# 1. Carga de paquetes y datos necesarios
## 1.1. Limpiamos la RAM
rm(list = ls(all.names = TRUE))
pacman::p_unload(pacman::p_loaded(), character.only = TRUE)

## 1.2. Cargamos el paquete "sf"
pacman::p_load(sf, dplyr)

## 1.3. Cargamos los datos de cada una de las CCAA
### 1.3.1. Definimos las rutas delas capas
rutas <- list.files("data/mfe_ccaa", 
                    pattern = "^MFE_.*\\.shp$", 
                    recursive = TRUE, 
                    full.names = TRUE)

### 1.3.2. Filtramos para excluir archivos .shp.xml
rutas <- rutas[!grepl("\\.xml$", rutas)]

### 1.3.3. Definimos los nombres de las capas
nombres <- basename(dirname(rutas))

### 1.3.4. Creamos una lista donde guardar las capas filtradas y otra en la que guardar las no filtradas
lista_filtrada <- list()
lista_no_filtrada <- list()

### 1.3.5. Establecemos el CRS objetivo a partir de la capa de madrid (comprobado en QGIS)
m <- st_read(rutas[8])
crs_objetivo <- st_crs(m)
rm(m)
gc()

### 1.3.5. Definimos los nombres de las columnas a conservar
nombres_columnas <- c("Superficie",
                      "FCCARB",
                      "FORARB",
                      "FormArbol",
                      "Distribuci",
                      "n_sp1",
                      "Especie1",
                      "O1",
                      "n_estado1",
                      "Estado1",
                      "FCCTOT",
                      "TIPOBOSQUE",
                      "UsoIFN",
                      "UsoMFE",
                      "RegBio",
                      "LULUCF")

### 1.3.6. Cargamos las capas en al lista
for(ruta in rutas) {
  # 1. Comprobamos si existe el archivo
  # - True, se detiene el bucle
  # - False, se carga la capa
  if(file.exists(ruta)) {
    capa <- st_read(ruta, quiet = FALSE) 
  } else{ 
    stop("Error: Archivo no encontrado")
  }
  
  # 2.Comprobamos si la capa no tiene crs asignado
  # - True, se detiene el bucle
  # - False, se detecta si no coincide con crs_objetivo
    # - True, se reproyecta acrs_objetivo
  if(is.na(st_crs(capa))) {
    stop("Error: Capa sin CRS asignado")
  } else {
    if (st_crs(capa) != crs_objetivo) {
      capa <- st_transform(capa, crs = crs_objetivo)
    }
  }
  
  # 4. Guardamos la capa sin filtrar en la lista de capas sin filtrar
  lista_no_filtrada[[length(lista_no_filtrada) + 1]] <- capa
  
  # 4. Filtramos las columnas que quermos conservar
  # Estas vienen recogidas en el archivo .xlsx (adjuntado a la información cartográfica descargada) 
  capa_filtrada <- capa %>% 
    select(any_of(nombres_columnas))
  
  # 5. Comprobamos que la capa contenga inconsistencias
  # - True, se hace valida mediante st_make_valid()
  if(any(!st_is_valid(capa_filtrada))) {
    capa <- st_make_valid(capa_filtrada)
  }
  
  # 6. Guardamos la capa filtrada en la lista de capas filtradas
  lista_filtrada[[length(lista_filtrada) + 1]] <- capa_filtrada
  
  # 7. Liberamos la memoria RAM
  rm(capa)
  gc()
}

### 1.3.6. Nombramos las capas de la lista
names(lista_filtrada) <- nombres

# 2. Unimos los atributos de todas las capas en una sola capa vectorial
MFE <- bind_rows(lista_filtrada)

# MFE <- MFE %>% 
#   select(nombres_columnas)

## 2.1. Eliminamos las listas, de modo que que liberemos la RAM
rm(lista_no_filtrada)
rm(lista_filtrada)
gc()

## 2.2. Comprobamos que no se hayan creado geometrias invalidas
# if(any(!st_is_valid(MFE))) {
#   MFE <- st_make_valid(MFE)
# }

# 3. Guardamos el resultado
st_write(MFE,
         dsn = "outputs/MFE.gpkg",
         delete_dsn = TRUE)
