--@Autor(es):       Jorge Rodríguez
--@Fecha creación:  dd/mm/yyyy
--@Descripción:     Validación de resultados de la práctica 06. El script crea
--                  los objetos de validación en cada contenedor que se
--                  valida (CDB$ROOT y la PDB2) y los elimina antes de pasar
--                  al siguiente. El usuario system (no sys) es dueño de los
--                  objetos de validación, mismo criterio establecido en la
--                  práctica 03. Conectarse a la PDB2 vía su alias de
--                  servicio prueba de punta a punta que el listener y
--                  tnsnames.ora están bien configurados.
--
--                  NOTA sobre numeración: este es el 8o archivo de
--                  validación generado para la práctica (después de
--                  s-01..s-05 y svg-06-main-enc.sh, sv-07.sql). El
--                  consecutivo sv-<nn> cuenta todo archivo entregado, no
--                  solo los que tienen lógica nueva — ver sv-07.sql y
--                  build.sh para el caso del validador shell (06), que no
--                  tiene ninguna línea propia de esta práctica.

whenever sqlerror continue

----------------------------------------------------------------------
-- 1. Para estudiantes:
-- Modificar los valores de las siguientes variables según corresponda
----------------------------------------------------------------------

--Password de sys/system (mismo para ambos en el curso)
define sys_pwd = system2

--Iniciales del estudiante
define p_iniciales = jrc

--Asignatura
define p_asignatura = bda

------------------------------------------------------------------------
-- 2. Las variables siguientes ya no requieren cambios
--  No modificar a partir de este punto
------------------------------------------------------------------------

define p_pdb = '&p_iniciales&p_asignatura._s2'
define p_spool = 'p06-sql-output.txt'

spool &p_spool

set verify off
set feedback off
set linesize window

----------------------------------------------------------------------
-- Conectando como sysdba para otorgar privilegios a system
----------------------------------------------------------------------

prompt ==> Conectando como sysdba para otorgar privilegios a system...
connect sys/&&sys_pwd as sysdba

prompt ==> Otorgando privilegio de dbms_crypto en todos los contenedores...
grant execute on dbms_crypto to public container=all;

prompt ==> Otorgando privilegio de select any dictionary en todos los contenedores...
grant select any dictionary to system container=all;

prompt ==> Otorgando privilegio de dbms_dictionary_check en todos los contenedores...
grant execute on dbms_dictionary_check to system container=all;

----------------------------------------------------------------------
-- TRAMO 1: Validación en CDB$ROOT
----------------------------------------------------------------------

prompt ================================================================
prompt   TRAMO 1: Validación en CDB$ROOT (PDB2 vista desde la raíz y
prompt   diccionario de datos)  --  Tomar captura al finalizar este tramo
prompt ================================================================

prompt ==> Creando objetos de validación en CDB$ROOT...
connect system/&&sys_pwd
set serveroutput on
set linesize 500
@sv-00-fx.plb
@sv-02.plb
@sv-07.plb

prompt ==> Validando desde CDB$ROOT...
declare
  v_ok boolean;
begin
  vcore.init('&p_asignatura', vcore.calculate_semester, '06');
  vcore.verify(
    upper(sys_context('userenv', 'con_name')) = 'CDB$ROOT',
    'Conexión aterrizó en el contenedor esperado (CDB$ROOT)',
    'con_name = CDB$ROOT',
    'con_name = ' || sys_context('userenv', 'con_name')
      || ' — el connect anterior pudo haber fallado, dejando la sesión en'
      || ' el contenedor previo. Los resultados de este bloque no son'
      || ' confiables.'
  );
  valida_pdb('&p_pdb');
  valida_datos_instancia;
  v_ok := vcore.finalize;
end;
/

prompt ==> Limpiando objetos de validación en CDB$ROOT...
begin
  vcore.cleanup_validation;
end;
/
drop package if exists vutils;
drop package if exists vcore;

----------------------------------------------------------------------
-- TRAMO 2: Validación de la PDB2, conectando vía alias de servicio
----------------------------------------------------------------------

prompt ================================================================
prompt   TRAMO 2: Validación de &p_pdb (conectando vía alias de
prompt   servicio) -- Tomar captura al finalizar este tramo
prompt ================================================================

prompt ==> Conectando a &p_pdb vía alias de servicio...
connect system/&&sys_pwd@&&p_pdb
set serveroutput on

prompt ==> Creando objetos de validación en &p_pdb...
@sv-00-fx.plb
@sv-02.plb
@sv-07.plb

prompt ==> Validando desde &p_pdb...
declare
  v_ok       boolean;
  v_dd_ok    boolean := true;
begin
  vcore.init('&p_asignatura', vcore.calculate_semester, '06');
  vcore.verify(
    upper(sys_context('userenv', 'con_name')) = upper('&p_pdb'),
    'Conexión aterrizó en el contenedor esperado (&p_pdb)',
    'con_name = ' || sys_context('userenv', 'con_name'),
    'con_name = ' || sys_context('userenv', 'con_name')
      || ' — el connect anterior pudo haber fallado, dejando la sesión en'
      || ' el contenedor previo. Los resultados de este bloque no son'
      || ' confiables.'
  );
  valida_pdb('&p_pdb');
  valida_datos_instancia;

  begin
    dbms_dictionary_check.full;
  exception
    when others then
      v_dd_ok := false;
  end;
  vcore.verify(
    v_dd_ok,
    'Ejecución de dbms_dictionary_check.full',
    'Verificación completa sin errores (ver detalle arriba)',
    'dbms_dictionary_check.full reportó errores — revisar el detalle impreso arriba'
  );

  v_ok := vcore.finalize;
end;
/

prompt ==> Limpiando objetos de validación en &p_pdb...
begin
  vcore.cleanup_validation;
end;
/
drop package if exists vutils;
drop package if exists vcore;

spool off

!c=$(sha256sum &p_spool | awk '{print $1}'); printf 'CHK:%s\n' "$(printf '%s' "$c" | rev)">>&p_spool
exit
