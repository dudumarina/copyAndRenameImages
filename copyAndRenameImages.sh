#!/bin/bash 
 
############################################################################################################################################ 
# Script: bulkCopyImages.sh
# Version: 1.00 
# 
# Descripcion: Copia y renombra a yyyymmdd_HMS_nombre_fichero el listado de ficheros que contenidos en el fichero que recibe como argumento
# 
# (Descripcion de los codigos de salida del script) 
# Salida: 0 = Con exito 
#         !=0 Finalizacion incorrecta (error de parametros o anulado por usuario) 
# 
# Control de versiones: 
#   v.1.00 (Nov 2023):  Creacion del script 
# 
############################################################################################################################################# 
 

# 
### -------------------- Gestion de senyales -------------------------- #### 
# 
 
trap 'f_signal 1; exit' 1 
trap 'f_signal 2; exit' 2 
trap 'f_signal 3; exit' 3 
trap 'f_signal 9; exit' 9 # 9 no es atrapable 
trap 'f_signal 10; exit' 10 
trap 'f_signal 11; exit' 11 
trap 'f_signal 14; exit' 14 
trap 'f_signal 15; exit' 15 
trap 'f_signal 19; exit' 19 
trap 'f_signal 23; exit' 23 
trap 'f_signal 30; exit' 30 
trap 'f_signal 31; exit' 31 
 
# 
### -------------------- Variables -------------------------- #### 
# 
 
# Globales 
 
PARAMETROS=$@ 
MIN_PARAM=2 
MAX_PARAM=2 
CERO=0 
YES="Y" 
NO="N" 
 
# Directorios 
 
# Ficheros 
 
# Global 
 
# Errores criticos contemplados 
 
ERR_PARAM=1 # Parametros pasados al script erroneos 
ERR_NO_FILE_INPUT=2 # No se puede leer el fichero
 
# 
### -------------------- Funciones -------------------------- #### 
# 
 
f_fecha_hora() 
{ 
 # Escribe la fecha y la hora en un mismo formato para todo el script 
 # Llamar a esta funcion cada vez que se quiera escribir la hora 
 # Hacer llamadas frecuentes para controlar los tiempos de cada fase del proceso 
 
 FECHA=`date +'%d-%m-%Y'` 
 HORA=`date +'%H:%M:%S'` 
 echo "[${FECHA} ${HORA}]" 

# Ejemplo de uso:
# echo "`f_fecha_hora` - [`basename $0`] : Que me estas contando" | tee -a ${LOGFILE}
 
} 
 
f_signal () 
{ 
 
# Funcion que gestiona las senyales atrapadas mediante trap 
 
 SALIDA=300 
 SIGNAL=$1 
 echo | tee -a ${LOGFILE} 
 echo | tee -a ${LOGFILE} 
 echo " f_fecha_hora **** INTERRUPCION -> RECIBIDA SIGNAL ${SIGNAL} !!!" | tee -a ${LOGFILE} 
 echo | tee -a ${LOGFILE} 
 echo " DETENIDO POR EL USUARIO !!!" | tee -a ${LOGFILE} 
 echo " DETENIDO POR EL USUARIO !!!" | tee -a ${LOGFILE} 
 echo " DETENIDO POR EL USUARIO !!!" | tee -a ${LOGFILE} 
 echo | tee -a ${LOGFILE} 
 echo " f_fecha_hora **** INTERRUPCION -> RECIBIDA SIGNAL ${SIGNAL} !!!" | tee -a ${LOGFILE} 
 echo | tee -a ${LOGFILE} 
 echo "`f_fecha_hora` - Ejecucion interrumpida" | tee -a ${LOGFILE} 
 mv $LOGFILE echo $LOGFILE | sed 's#\.log#.KO.log#g' 
 
} 
 
f_checkExec ()  
{ 
 
# Si el primer parametro que recibe es distinto de 0 sale con ese codigo 
 
 C_EXIT=${1} 
 C_MESSAGE=${2} 
 
 if [ "X${C_EXIT}" != "X0" ] 
 then 
   echo "${C_MESSAGE} : ERROR ${C_EXIT}" 
   exit ${C_EXIT} 
 fi 
 
} 
 
f_help () 
{ 
 
# Funcion de ayuda 
 
 echo 
 echo " + Script: `basename $0`" 
 echo 
 echo " + Descripcion: Copia y renombra a yyyymmdd_HMS_nombre_fichero el listado de ficheros que contenidos en el fichero que recibe como argumento" 
 echo "" 
 echo " + Pre-requisitos:" 
 echo "" 
 echo "   El fichero que recibe como primer argumento puede obtenerse mediante la ejecucion y posterior filtrado, en el caso de fotos, de:" 
 echo "   nohup find . -name  "*.JPEG" -o -name "*.JPG" -o -name "*.PNG" -o -name "*.BMP" -o -name "*.TIFF" -o -name "*.RAW" -o -name "*.jpeg" -o -name "*.jpg" -o -name "*.png" -o -name "*.bmp"-o -name "*.tiff" -o -name "*.raw" > lista_fotos.txt & "
 echo ""
 echo "  Desplegar el script en el mismo directorio en el que hayamos generado el listado de ficheros y ejecutar como indicamos a continuacion"
 echo 
 echo " + Ejecucion:" 
 echo 
 echo " `basename $0` -f:file_input -dir_output:dir_output" 
 echo 
 echo " + Ejemplo de ejecucion:" 
 echo 
 echo " `basename $0` -a:lista_fotos.txt -dir_output:output_imagenes" 
 
} 
 
f_getParams () 
{ 
 
 # Funcion encargada del trato de parametros. 
 
 if [ $# -lt $MIN_PARAM ] || [ $# -gt $MAX_PARAM ] 
 then 
   f_help 
   f_checkExec $ERR_PARAM "- ERROR $ERR_PARAM: Parametros incorrectos" 
 fi 
 
 for i in "$@" 
 do 
   ARG=$i 
   PARAM=`echo $ARG | cut -d":" -f1` 
   VALOR=`echo $ARG | cut -d":" -f2` 
 
   case $PARAM in 
   -f) 
        FILE_INPUT=$VALOR
   ;; 
   -dir_output) 
        DIR_OUTPUT=$VALOR
   ;; 
    *) 
        f_help 
        f_checkExec $ERR_PARAM "- ERROR $ERR_PARAM: Parametros incorrectos" 
   esac 
 
 done 
 
 # Comprobamos parametros

 if ! [ -r "$FILE_INPUT" ]
 then
   f_help
   f_checkExec $ERR_NO_FILE_INPUT "- ERROR $ERR_NO_FILE_INPUT: El fichero $FILE_INPUT NO se puede leer."
 fi 

 mkdir -p "$DIR_OUTPUT" 
 
}

f_bulkCopyAndRename ()
{

# Funcion que copia y renombra los ficheros al directorio destino

 while read -r LINE 
 do

   # Modification time en segundos desde epoch

   MODIFICATION_TIME=$(stat -c %Y "$LINE")

   # Formateamos el tiempo como YYYYMMDD_HHMMSS

   FORMATTED_TIME=$(date -d "@$MODIFICATION_TIME" "+%Y%m%d_%H%M%S")

   DESTINATION_FILE_NAME=${FORMATTED_TIME}_`basename "$LINE"`

   #echo $DESTINATION_FILE_NAME

   cp -p "$LINE" "${DIR_OUTPUT}/${DESTINATION_FILE_NAME}"

 done <$FILE_INPUT

}
 
# 
### -------------------- Main - Principal ------------------------- #### 
#

f_getParams "$@"

f_bulkCopyAndRename

