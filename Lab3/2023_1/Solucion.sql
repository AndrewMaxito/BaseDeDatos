
--pREGUNTA 1
CREATE OR REPLACE PROCEDURE xx_SuspenderConductor(
    c_apellido_paterno IN VARCHAR2,
    c_apellido_materno IN VARCHAR2,
    c_nombres IN VARCHAR2
)IS
    ID_CONDUCTOR_ENCONTRADO NUMBER;
BEGIN
    --BUSCAR cONDUCTOR
    SELECT ID_CONDUCTOR INTO ID_CONDUCTOR_ENCONTRADO
    FROM et_conductor
    WHERE 
        UPPER(apellido_paterno) = UPPER(c_apellido_paterno)
        AND UPPER(apellido_materno) = UPPER(c_apellido_materno)
        AND UPPER(nombres) = UPPER(c_nombres)
    ;
    --actualzia la tabla
    update et_conductor
    set estado = 'S'
    where id_conductor = ID_CONDUCTOR_ENCONTRADO;
    
    --SAlida en pantalla
    DBMS_OUTPUT.put_line ('Conductor suspendido');
EXCEPTION
    WHEN no_data_found then
    DBMS_OUTPUT.PUT_LINE( 'No existe el conductor indicado' );
END;
/
begin
    xx_SuspenderConductor('Valle','RETAMOZO','ROBERTO Carlos');
end;
/
begin
    xx_SuspenderConductor('Valverde','Alvarado','Jessica');
end;
/


--Pregunta 2
CREATE or REPLACE FUNCTION xx_ObtenerConductoresActivos(
    P_fecha date, 
    P_sentido char, 
    P_horaIni char, 
    P_horaFin char
) RETURN VARCHAR2 IS
    cantidad_conductores NUMERIC;
    V_RESULTADO VARCHAR2(100);
BEGIN
    SELECT count(*) into  cantidad_conductores 
    FROM et_turno T
    JOIN et_conductor C on c.id_conductor = t.id_conductor
    WHERE
        c.estado = 'A'
        and t.fecha = p_fecha
        and t.sentido = P_sentido
        and (t.hora_partida between  P_horaIni and P_horaFin);
    V_RESULTADO := 'Se cuenta con '||cantidad_conductores||' conductores activos en el horario consultado.';
    RETURN V_RESULTADO;
    
    EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END; 

/
select xx_ObtenerConductoresActivos(to_date('01/03/2023','dd/mm/yyyy'),'I','0900','1130')
from dual;
/

--Pregunta 3

CREATE OR REPLACE PROCEDURE xx_InsertarParadero(
    P_nombreParadero VARCHAR2,
    P_NombreDistrito VARCHAR2,
    P_Tipo CHAR
)IS 
    id_distritoEnc CHAR(6);
    V_id_paradero NUMBER;
BEGIN
    --busca Id del distrito
    SELECT id_distrito into id_distritoEnc 
    FROM et_distrito DI
    where  upper(di.nombre)  =  upper(P_NombreDistrito);
    
    --busca el ultimo Id del paradero para crear uno nuevo (ASUMIEND QUE SE ENCUENTREN DE FORMA CONTINUA)
    SELECT NVL(MAX(p.id_paradero),0)+1 INTO V_id_paradero 
    FROM et_paradero p;
    /*
    --FORMA ALTERNATIVO
    SELECT ID_PARADERO INTO V_ID_PARADERO
    FROM (
        SELECT ID_PARADERO FROM ET_PARADERO
        ORDER BY ID_PARADERO DESC
    )WHERE ROWNUM=1;
    */
    
    --Inserta los valores del nuevo distrito
    INSERT INTO et_paradero(id_paradero,NOMBRE,ID_DISTRITO,TIPO,ESTADO) 
    VALUES (V_id_paradero,P_NombreDistrito,id_distritoEnc,P_Tipo,'A');
    
    --Salida en pantalla
    dbms_output.put_line('Paradero ingresado con exito');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('El dsitrito '||P_NombreDistrito||' No esta registrado');
END;     
/
BEGIN 
    xx_insertarparadero('Parque Kennedy','MIRAFLORES','N');
END;
/
--Pregunta 4
CREATE OR REPLACE PROCEDURE xx_LimpiarBuses 
IS
v_cantidad_eliminados NUMBER;
BEGIN
    -- Eliminar los buses sin turnos registrados
    DELETE FROM et_bus
    WHERE id_bus NOT IN (
        SELECT DISTINCT id_bus --DISTINCT ES PARA SELECCIONAR VALORES UNICOS
        FROM et_turno
        WHERE id_bus IS NOT NULL --asEGURA QUE NO HAYAN BUSES CON ID NULL (BUENA PRACTICA)
    );
    v_cantidad_eliminados := SQL%ROWCOUNT; --Capturar la cantidad de registros eliminados
    -- Mensaje de confirmación
    DBMS_OUTPUT.PUT_LINE(v_cantidad_eliminados||' ELIMINADOS');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar buses: ' || SQLERRM);
END;   
/
begin
    xx_LimpiarBuses;
end;
/
--pREGUNTA 5


SELECT * FROM ET_TURNO T
WHERE T.FECHA = TO_DATE('01/03/2023','dd/mm/yyyy');
/
CREATE OR REPLACE PROCEDURE xx_ActualizarHoraLlegadaReal(
    p_fecha date,
    p_hora_inicio char,
    p_hora_fin char,
    p_horas_retraso numeric
)
IS
BEGIN
    UPDATE ET_TURNO T
    SET HORA_LLEGADA_REAL = TO_CHAR(TO_DATE(HORA_LLEGADA_PROGRAMADA,'HH24MI')+
                                    NUMTODSINTERVAL(p_horas_retraso, 'HOUR'),--PASA UN NUMERO A FORMATO DE HORA PARA OPERACIONES A FECHAS
                            'HH24MI')
    WHERE 
        fecha = p_fecha
        AND (T.HORA_PARTIDA BETWEEN p_hora_inicio AND p_hora_fin) AND
        HORA_LLEGADA_REAL IS NULL
    ;
END;
/
BEGIN
    xx_ActualizarHoraLlegadaReal(TO_DATE('01/03/2023','dd/mm/yyyy'),'0630','0730',1);
END;
/
SELECT * FROM ET_TURNO T
WHERE T.FECHA = TO_DATE('01/03/2023','dd/mm/yyyy');
/
--pREGUNTA 6

CREATE OR REPLACE FUNCTION xx_obtenerHorasRealesTrab(
    V_APELLIDO_PATERNO VARCHAR2,
    V_APELLIDO_MATERNO VARCHAR2,
    V_NOMBRES VARCHAR2,
    V_FECHA_INI DATE,
    V_FECHA_FIN DATE
    ) 
RETURN NUMBER
IS
v_total_horas NUMBER := 0;
BEGIN

    -- Calcular las horas trabajadas sumando diferencias entre partida y llegada
    
        --Repazar lo de case
    SELECT SUM(
        CASE 
            WHEN hora_llegada_real IS NOT NULL THEN
                (TO_DATE(hora_llegada_real, 'HH24MI') - TO_DATE(hora_partida, 'HH24MI')) * 24
            ELSE
                (TO_DATE(hora_llegada_programada, 'HH24MI') - TO_DATE(hora_partida, 'HH24MI')) * 24
        END
    )
    INTO V_TOTAL_HORAS
    FROM et_turno T
    JOIN et_conductor C ON T.ID_CONDUCTOR = C.ID_CONDUCTOR
    WHERE UPPER(C.APELLIDO_PATERNO) = UPPER(V_APELLIDO_PATERNO)
      AND UPPER(C.APELLIDO_MATERNO) = UPPER(V_APELLIDO_MATERNO)
      AND UPPER(C.NOMBRES) = UPPER(V_NOMBRES)
      AND T.FECHA BETWEEN V_FECHA_INI AND V_FECHA_FIN;

    -- Retornar el total de horas trabajadas
    RETURN V_TOTAL_HORAS;

END;
/
select xx_obtenerHorasRealesTrab(
    'Angeles','Meza','Alvaro Stefano',to_date('01/03/2023','dd/mm/yyyy'),
    to_date('01/04/2023','dd/mm/yyyy')
)
from dual;
/
--PREGUNTA 7
CREATE OR REPLACE PROCEDURE xx_obtenerCantitadSB(
    V_DISTRITO VARCHAR2,
    V_FECHA DATE
)
IS
    v_total_suben NUMBER := 0;
    v_total_bajan NUMBER := 0;
    V_ID_DISTRITO CHAR(6);
BEGIN
    --Encuentra el id del distrito
    SELECT ID_DISTRITO INTO V_ID_DISTRITO
    FROM ET_DISTRITO WHERE UPPER(NOMBRE) = UPPER(V_DISTRITO);
    -- Sumar los pasajeros que subieron y bajaron
    SELECT NVL(SUM(tp.PASAJEROS_SUBIDA), 0), NVL(SUM(tp.PASAJEROS_BAJADA), 0)--repazr esta parte
    INTO v_total_suben, v_total_bajan
    FROM ET_TURNO_PARADERO TP
    JOIN ET_TURNO T ON TP.ID_TURNO = T.ID_TURNO_VIAJE
    JOIN ET_PARADERO P ON TP.ID_PARADERO = P.ID_PARADERO
    WHERE V_ID_DISTRITO = p.id_distrito
      AND T.FECHA = V_FECHA;

    -- Mostrar el resultado en pantalla
    DBMS_OUTPUT.PUT_LINE('En el distrito '||V_DISTRITO||' subieron '||
                         v_total_suben||' y bajaron '||v_total_bajan
                         ||' pasajeros el dia '||to_char(V_FECHA,'dd-MON-yy'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE( 'El distrito '||V_DISTRITO||' no existe en el sistema' );
END;
/
BEGIN
    xx_obtenerCantitadSB('BARRANCO',to_date('01/04/2023','dd/mm/yyyy'));
END;
/







