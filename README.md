# BDA-P06

# En el container

**Iniciar segundo container**

```shellsession
martin@pc-bda-mqr:~$ dockerBda2
c2-bda-mqr
bash-5.1# 
```

## 01-crea-spfile-ADMIN.sql

ejecutar con el usuario administrador

```shellsession
[martin@h2-bda-mqr container]$ sqlplus /nolog @01-crea-spfile-admin.sql 
```

## 02-crea-directorios-ROOT.sh

Ejecutar como root o con sudo

```shellsession
[martin@h2-bda-mqr container]$ sudo sh 02-crea-directorios-ROOT.sh 
```

## 03-crea-cdb-admin.sql

ejecutar como usuario admin

```shellsession
[martin@h2-bda-mqr container]$ sqlplus /nolog @03-crea-cdb-admin.sql 
```


