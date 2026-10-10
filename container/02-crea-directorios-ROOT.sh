#!/bin/bash
#@Autor(es):       Jorge Rodríguez
#@Fecha creación:  dd/mm/yyyy
#@Descripción:     Crea un contenedor de Docker para la práctica 05

# set -euo pipefail hace que el script se detenga si ocurre un error, si se usa
# una variable no definida, o si un comando ejecutado vía pipe falla.
set -euo pipefail
. /etc/profile.d/99-custom-env.sh

echo "Verificando la ejecución del script como root"
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script debe ejecutarse como root"
  exit 1
fi

export ORACLE_SID=free

echo "Verificando existencia de directorio para data files"

if [ -d "/opt/oracle/oradata/${ORACLE_SID^^}" ]; then
  echo "Directorio para data files ya existe, se omite creación"
else
  echo "1. Creando directorios para data files de cdb\$root"
  cd /opt/oracle
  mkdir -p oradata/${ORACLE_SID^^}
  chown -R oracle:oinstall oradata
  chmod -R 750 oradata
fi;

echo "Verificando existencia de directorio para pdb\$seed"

if [ -d "/opt/oracle/oradata/${ORACLE_SID^^}/pdbseed" ]; then
  echo "Directorio para data files ya existe, se omite creación"
else
  echo "1. Creando directorios para pdbseed"
  cd /opt/oracle/oradata/${ORACLE_SID^^}
  mkdir pdbseed
  chown oracle:oinstall pdbseed
  chmod 750 pdbseed
fi;


echo "2. Creando directorios para Redo Logs y control files"

if [ -d "${UNAM_HOME}/bda/disks/d01/app/oracle/oradata/${ORACLE_SID^^}" ]; then
  echo "Directorio para control files y redo logs d01 ya existe";
else
  cd ${UNAM_HOME}/bda/disks/d01
  mkdir -p app/oracle/oradata/${ORACLE_SID^^}
  chown -R oracle:oinstall app
  chmod -R  750 app
fi;

if [ -d "${UNAM_HOME}/bda/disks/d02/app/oracle/oradata/${ORACLE_SID^^}" ]; then
  echo "Directorio para control files y redo logs d02 ya existe";
else
  cd ${UNAM_HOME}/bda/disks/d02
  mkdir -p app/oracle/oradata/${ORACLE_SID^^}
  chown -R oracle:oinstall app
  chmod -R  750 app
fi;

if [ -d "${UNAM_HOME}/bda/disks/d03/app/oracle/oradata/${ORACLE_SID^^}" ]; then
  echo "Directorio para control files y redo logs d03 ya existe";
else
  cd ${UNAM_HOME}/bda/disks/d03
  mkdir -p app/oracle/oradata/${ORACLE_SID^^}
  chown -R oracle:oinstall app
  chmod -R  750 app
fi;

echo "Mostrando directorio de data files"
ls -l /opt/oracle/oradata

echo "Mostrando directorios para control files y Redo Logs"
ls -l ${UNAM_HOME}/bda/disks/d0*/app/oracle/oradata

read -p  "Eliminando contenido de directorios en caso de existir [Enter] para continuar, Ctrl -C para cancelar"

rm -f ${UNAM_HOME}/bda/disks/d01/app/oracle/oradata/FREE/*
rm -f ${UNAM_HOME}/bda/disks/d02/app/oracle/oradata/FREE/*
rm -f ${UNAM_HOME}/bda/disks/d03/app/oracle/oradata/FREE/*

rm -f /opt/oracle/oradata/${ORACLE_SID^^}/*.dbf
rm -f /opt/oracle/oradata/${ORACLE_SID^^}/pdbseed/*.dbf

echo "Mostrando directorio de datafiles"
ls -l /opt/oracle/oradata
echo "Mostrando direcotrios para controlfiles y redologs"
ls -l ${UNAM_HOME}/bda/disks/d0*/app/oracle/oradata
