set SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER TRG_INICIALIZA_ESTADISTICAS
    AFTER INSERT ON SELECCION
    FOR EACH ROW
DECLARE

BEGIN
    INSERT INTO ESTADISTICA(NOMBRE, JUGADOS, GANADOS, EMPATADOS, PERDIDOS, GOLESFAVOR, GOLESCONTRA, PUNTOS)
    VALUES (:NEW.NOMBRE, 0, 0, 0, 0, 0, 0, 0);
END;
/
CREATE OR REPLACE TRIGGER TRG_ACTULIZA_ESTADISTICAS
    AFTER INSERT ON PARTIDO
    FOR EACH ROW
DECLARE
V_NOMBRE_VISITA VARCHAR2(10);
V_NOMBRE_LOCAL VARCHAR2(10);
BEGIN 
    --OBTENER EL IDENTIFICADOR COMUN 
    SELECT NOMBRE INTO V_NOMBRE_VISITA
    FROM seleccion
    WHERE idseleccion = :NEW.idvisit;
    
    SELECT NOMBRE INTO V_NOMBRE_LOCAL
    FROM seleccion
    WHERE idseleccion = :NEW.idlocal;
    
    --ACTILIZAR COSAS PARAMETROS COMUNES (PARTIDOS JUGADOS)
    UPDATE estadistica
    SET jugados = jugados +1
    WHERE nombre IN (V_NOMBRE_VISITA,V_NOMBRE_LOCAL);
    
     -- Actualizar goles a favor y en contra
    UPDATE ESTADISTICA
    SET GOLESFAVOR = GOLESFAVOR + :NEW.GOLESLOCAL,
        GOLESCONTRA = GOLESCONTRA + :NEW.GOLESVISIT
    WHERE NOMBRE = v_nombre_local;

    UPDATE ESTADISTICA
    SET GOLESFAVOR = GOLESFAVOR + :NEW.GOLESVISIT,
        GOLESCONTRA = GOLESCONTRA + :NEW.GOLESLOCAL
    WHERE NOMBRE = v_nombre_visitA;
    
    --rESULTADOS UNICOS
    
    IF :NEW.goleslocal = :NEW.golesvisit THEN
        UPDATE estadistica
        SET empatados = empatados +1,PUNTOS = PUNTOS + 1
        WHERE nombre IN (V_NOMBRE_VISITA,V_NOMBRE_LOCAL);
    ELSE
        IF :NEW.goleslocal > :NEW.golesvisit THEN
            UPDATE estadistica
            SET ganados = ganados +1,PUNTOS = PUNTOS + 3
            WHERE nombre = V_NOMBRE_LOCAL;
            
            UPDATE estadistica
            SET perdidos = perdidos +1
            WHERE nombre = V_NOMBRE_VISITA;
        ELSE 
            UPDATE estadistica
            SET ganados = ganados +1,PUNTOS = PUNTOS + 3
            WHERE nombre = V_NOMBRE_VISITA;
            
            UPDATE estadistica
            SET perdidos = perdidos +1
            WHERE nombre = V_NOMBRE_LOCAL;
        END IF;
    END IF;

END;
/
SELECT * FROM estadistica ORDER BY puntos DESC;
/


/*
--sin cursores
CREATE or replace PROCEDURE PR_MOSTRAR_PARTIDOS
(P_NOMBRE varchar2) 
IS
V_IDSELECCION NUMBER;
BEGIN
    --vERIFICACION DE LA EXISTENCIA DEL VALOR  (FORMA EFICIENTE)
    SELECT IDSELECCION
    INTO V_IDSELECCION
    FROM seleccion
    WHERE nombre = p_nombre
        AND ROWNUM = 1;
    --mostrar todos los partidos
    dbms_output.put_line('Resultados de los partidos de la seleccion de '||P_NOMBRE);
    
    -- Mostrar los resultados directamente
    FOR partido IN (
        SELECT NUMFECHA,
               (SELECT NOMBRE FROM SELECCION WHERE IDSELECCION = P.IDLOCAL) AS LOCAL,
               GOLESLOCAL,
               (SELECT NOMBRE FROM SELECCION WHERE IDSELECCION = P.IDVISIT) AS VISITANTE,
               GOLESVISIT
        FROM PARTIDO P
        WHERE P.IDLOCAL = V_IDSELECCION OR P.IDVISIT = V_IDSELECCION
        ORDER BY NUMFECHA
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Fecha ' || partido.NUMFECHA || ': ' || partido.LOCAL || ' ' || partido.GOLESLOCAL || ' - ' || partido.VISITANTE || ' ' || partido.GOLESVISIT);
    END LOOP;
    
    
    
EXCEPTION
    WHEN no_data_found then
        dbms_output.put_line('Nombre de la seleccion no valido ');
END;
*/

--Usando cursor
CREATE or replace PROCEDURE PR_MOSTRAR_PARTIDOS
(P_NOMBRE varchar2) 
IS
V_IDSELECCION NUMBER;

CURSOR partido_cursor
    (C_idseleccion IN NUMBER) 
    IS
        SELECT p.numfecha,l.nombre as local,p.goleslocal,v.nombre as visitante,p.golesvisit
        FROM partido p
        JOIN seleccion L ON l.idseleccion = p.idlocal
        JOIN seleccion v ON v.idseleccion = p.idvisit
        where p.idlocal = C_idseleccion or p.idvisit = C_idseleccion
        order by p.numfecha;         
BEGIN
    --vERIFICACION DE LA EXISTENCIA DEL VALOR  (FORMA EFICIENTE)
    SELECT IDSELECCION
    INTO V_IDSELECCION
    FROM seleccion
    WHERE nombre = p_nombre
        AND ROWNUM = 1;
    --mostrar todos los partidos
    dbms_output.put_line('Resultados de los partidos de la seleccion de '||P_NOMBRE);
    
    -- Usar el FOR LOOP para recorrer el cursor
    FOR partido_row IN partido_cursor(V_IDSELECCION) LOOP
        DBMS_OUTPUT.PUT_LINE('Fecha ' || partido_row.NUMFECHA || ': ' || partido_row.LOCAL || ' ' || partido_row.GOLESLOCAL || ' - ' || partido_row.VISITANTE || ' ' || partido_row.GOLESVISIT);
    END LOOP;
EXCEPTION
    WHEN no_data_found then
        dbms_output.put_line('Nombre de la seleccion no valido ');
END;

/
BEGIN
    pr_mostrar_partidos('PERU');
END;
