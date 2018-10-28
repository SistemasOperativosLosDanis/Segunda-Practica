#!/bin/bash

MPOINT="./mount-point"
TEMPD="./temp"
FICH_ORIG1="./src/fuseLib.c"
FICH_ORIG2="./src/myFS.h"
FICH_CP1="./mount-point/fuseLib.c"
FICH_CP2="./mount-point/myFS.h"
FICH_CP3="./mount-point/nuevo.txt"
BLOCK_SIZE=4096
AUDITAR="./my-fsck"
VIRTUALDISK="./virtual-disk"
FICHERO="./nuevo.txt"


#Apartado a)
rm -R -f temp
mkdir temp

echo "Copiando los archivos en nuestro SF y en /temp"
cp $FICH_ORIG1 $MPOINT/
cp $FICH_ORIG1 $TEMPD/
cp $FICH_ORIG2 $MPOINT/
cp $FICH_ORIG2 $TEMPD/

read -p "Pulsa enter para seguir. Apartado b)"

#Apartado b)
echo "Auditando..."
$AUDITAR $VIRTUALDISK
DIFF1=$(diff $FICH_ORIG1 $FICH_CP1)

if [ DIFF1 = "" ]; then
	echo "$FICH_ORIG1 y $FICH_CP1 son iguales" 
else
	echo "$FICH_ORIG1 y $FICH_CP1 son distintos" 
fi;

DIFF2=$(diff $FICH_ORIG2 $FICH_CP2)
if [ DIFF2 = "" ]; then
	echo "$FICH_ORIG2 y $FICH_CP2 son iguales" 
else
	echo "$FICH_ORIG2 y $FICH_CP2 son distintos" 
fi;

#CON esto averiguamos el tamaño de bloque del archivo
SIZE_FICH_ORIG1=$(stat -c%s "$FICH_ORIG1")

NEW_SIZE1=`expr $SIZE_FICH_ORIG1 - $BLOCK_SIZE`

echo "Nuevo tamaño: $NEW_SIZE1"

echo "Vamos a truncar el 1º fichero en el archivo temporal"
truncate --size=$NEW_SIZE1 ./temp/fuseLib.c

echo "Vamos a truncar el 1º fichero en nuestro archivo SF"
truncate --size=$NEW_SIZE1 $FICH_CP1

read -p "Pulsa enter para seguir. Apartado c)"

#Apartado c)
echo "Auditando..."
$AUDITAR $VIRTUALDISK

DIFF1=$(diff "$FICH_ORIG1" "$FICH_CP1")
if [ DIFF1 = "" ]; 
then
	echo "$FICH_ORIG1 y $FICH_CP1 son iguales despues de truncarlos" 
else
	echo "$FICH_ORIG1 y $FICH_CP1 son distintos despues de truncarlos" 
fi;

read -p "Pulsa enter para seguir. Apartado d)"

#Apartado d)
echo "Fichero nuevo" > $FICHERO
cp $FICHERO $MPOINT

read -p "Pulsa enter para seguir. Apartado e)"

#Apartado e)
echo "Auditando..."
$AUDITAR $VIRTUALDISK

DIFF3=$(diff "$FICHERO" "$FICH_CP3")
if [ DIFF3 = "" ]; 
then
	echo "$FICHERO y $FICH_CP3 son iguales." 
else
	echo "$FICHERO y $FICH_CP3 son diferentes. "
fi;
read -p "Pulsa enter para seguir. Apartado f)"

#Apartado f)
#CON esto averiguamos el tamaño de bloque del archivo
SIZE_FICH_ORIG2=$(stat -c%s "$FICH_ORIG2")

NEW_SIZE2=`expr $SIZE_FICH_ORIG2 + $BLOCK_SIZE`
echo "Nuevo tamaño: $NEW_SIZE2"

echo "Vamos a truncar el 2º fichero en el archivo temporal"
truncate --size=$NEW_SIZE2 ./temp/myFS.h

echo "Vamos a truncar el 2º fichero en nuestro archivo SF"
truncate --size=$NEW_SIZE2 $FICH_CP2

read -p "Pulsa enter para seguir. Apartado g)"

echo "Auditando..."
$AUDITAR $VIRTUALDISK

DIFF2=$(diff "$FICH_ORIG2" "$FICH_CP2")
if [ DIFF2 = "" ]; 
then
	echo "$FICH_ORIG2 y $FICH_CP2 son iguales despues de truncarlos" 
else
	echo "$FICH_ORIG2 y $FICH_CP2 son distintos despues de truncarlos" 
fi;
read -p "Hemos terminado. Pulsa enter"
