SET SERVEROUTPUT ON;
--Pregunta 1
CREATE OR REPLACE FUNCTION FN_TOTAL_BUSES_TIPO(
    PA_ID_TIPO_BUS CHAR
) RETURN NUMBER IS
    CANTIDAD_TOTAL NUMBER;
    ID_EXISTE NUMBER;
BEGIN
    -- Verificar si el ID_TIPO_BUS existe en la tabla TIPO_BUS
    SELECT id_tipo_bus 
    INTO ID_EXISTE 
    FROM TIPO_BUS
    WHERE ID_TIPO_BUS = PA_ID_TIPO_BUS;

    -- Si existe, calcular la cantidad total
    SELECT NVL(SUM(CANTIDAD), 0)
    INTO CANTIDAD_TOTAL
    FROM DETALLE_ORD_PEDIDO
    WHERE ID_TIPO_BUS = PA_ID_TIPO_BUS;
    RETURN CANTIDAD_TOTAL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/
--CASO 1: TIPO DE BUS EXISTENTE CON PEDIDOS
SELECT fn_total_buses_tipo(1) FROM DUAL;
--CASO 2: TIPO DE BUS EXISTENTE SIN PEDIDOS
SELECT fn_total_buses_tipo(5) FROM DUAL;
--CASO 3: TIPO DE BUS NO EXISTE
SELECT fn_total_buses_tipo(999) FROM DUAL;

/
--Pregunta 2
CREATE OR REPLACE FUNCTION fn_eficiencia_entrega_sede 
(P_ID_SEDE CHAR) 
RETURN NUMBER
IS
    V_ID_SEDE_EXISTE CHAR (10);
    V_CANTIDAD_TOTAL_ORDENES NUMBER; 
    V_CANTIDAD_PARTE_ORDENES NUMBER;
    V_PORCENTAJE NUMBER;
BEGIN
    --VERIFICACION SI LA SEDE EXISTE (SI NO EXISTE IRA A EXCEPCIONES)
    SELECT id_sede
    INTO V_ID_SEDE_EXISTE
    FROM sede
    WHERE id_sede = p_id_sede;

    --EN CASO EXISTA:
    --1.SE EVALUA LA CANTIDAD TOTAL DE ORDENES 
    SELECT COUNT (*) 
    INTO V_CANTIDAD_TOTAL_ORDENES
    FROM ORDEN_PEDIDO OP 
    WHERE op.id_sede = p_id_sede
    AND OP.FECHA_ENTREGA IS NOT NULL;

    IF V_CANTIDAD_TOTAL_ORDENES = 0 THEN
        --DEVUELVE 0
        RETURN 0;
    ELSE
        --CALCULAR CANTIDAD ODENDES CON FECHA DE ENTREGA NO NULA
        SELECT COUNT (*)
        INTO V_CANTIDAD_PARTE_ORDENES 
        FROM ORDEN_PEDIDO OP
        WHERE  P_ID_SEDE = OP.id_sede 
        AND OP.fecha_entrega IS NOT NULL
        AND (OP.FECHA_ENTREGA - OP.fecha_registro) <= 30;
        V_PORCENTAJE := ROUND((V_CANTIDAD_PARTE_ORDENES/V_CANTIDAD_TOTAL_ORDENES)*100);
        RETURN V_PORCENTAJE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN 0;
END;
/
--CASO 1: SEDE CON ORDENES
SELECT fn_eficiencia_entrega_sede(1)FROM DUAL;
--CASO 2: SEDE SIN ORDENES
SELECT fn_eficiencia_entrega_sede(7)FROM DUAL;
--CASO 3: SEDE QUE NO EXISTE
SELECT fn_eficiencia_entrega_sede(999)FROM DUAL;

/
--Pregunta 3
CREATE OR REPLACE PROCEDURE sp_registrar_cliente
(p_ID_CLI CHAR,P_RAZON_SOCIAL CHAR ,P_RUC CHAR,P_TELEFONO CHAR,P_CORREO CHAR,P_DIRECCION_FISCAL CHAR) 
IS
V_EXISTE NUMBER;
FLAG NUMBER := 0;

BEGIN
    --EL ID DEL CLIENTE NO DEBE EXISTIR 
    SELECT COUNT(*)
    INTO V_EXISTE
    FROM CLIENTE
    WHERE ID_CLIENTE = p_ID_CLI;

    IF V_EXISTE != 0 THEN
        --CLIENTE EXISTENTE
        DBMS_OUTPUT.PUT_LINE('Error: El ID del cliente ya existe');
        RETURN;
    END IF;

    --SI EL CLIENTE ES NUEVO:
    FLAG :=0;

    --vERIFICAR QUE LOS CAMPOS PEDIDOS NO SEAN NULLO O VACIOS
    IF P_RAZON_SOCIAL IS NULL OR TRIM(P_RAZON_SOCIAL) = '' THEN
        DBMS_OUTPUT.PUT_LINE('Error: La razón social ES OBLIGATORIO');
        FLAG := 1;
    END IF;
    IF P_RUC IS NULL OR TRIM(P_RUC) = '' THEN
        DBMS_OUTPUT.PUT_LINE('Error: EL RUC ES OBLIGATORIO');
        FLAG := 1;
    END IF;
    IF P_TELEFONO IS NULL OR TRIM(P_TELEFONO) = '' THEN
        DBMS_OUTPUT.PUT_LINE('Error: TELEFONO ES OBLIGATORIO');
        FLAG := 1;
    END IF;
    IF P_CORREO IS NULL OR TRIM(P_CORREO) = '' THEN
        DBMS_OUTPUT.PUT_LINE('Error: CORREO ES OBLIGATORIO');
        FLAG := 1;
    END IF;

    IF FLAG = 1 THEN
        RETURN;
    END IF;

    --fIN VERIFICACION
    INSERT INTO cliente (ID_CLIENTE,RAZON_SOCIAL,RUC,TELEFONO,CORREO,DIRECCION_FISCAL)
    VALUES (p_ID_CLI,P_RAZON_SOCIAL ,P_RUC,P_TELEFONO,P_CORREO,P_DIRECCION_FISCAL);

    -- Mensaje de CONFIRMACION
    DBMS_OUTPUT.PUT_LINE('Cliente registrado exitosamente: ');
END;
/
--Caso 1: Cliente válido con todos los datos
EXEC sp_registrar_cliente(9, 'Transportes Express', '20505050505', '998877665','contact@express.com', 'Av. Principal 123');
--Caso 2: Cliente con campos nulos
EXEC sp_registrar_cliente(10, NULL, NULL, NULL, NULL, NULL);
--Caso 3: Cliente con campos vacíos
EXEC sp_registrar_cliente(11, '', '', '', '', '');
--Caso 4: ID existente
EXEC sp_registrar_cliente(1, 'Nueva Empresa', '20606060606', '999999999','info@nueva.com', 'Calle Nueva 789');
/
--Pregunta 4
CREATE OR REPLACE PROCEDURE sp_cliente_mas_pedidos
(P_ANHO NUMBER)
IS
V_EXISTE NUMBER;
V_CANTIDAD_PEDIDOS NUMBER;
V_ID_CLIENTE_MAS_PEDIDOS NUMBER;
BEGIN
    --VERIFICACION DEL AÑO ACTUAL
    IF TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) < P_ANHO THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: el año no puede ser futuro');
        RETURN;
    END IF;

    --VALIDAR QUE EXISTAN PEDIDOS EN ESE AÑO
    SELECT 1
    INTO V_EXISTE
    FROM orden_pedido
    WHERE TO_NUMBER(TO_CHAR(FECHA_REGISTRO,'YYYY')) = P_ANHO
    AND ROWNUM = 1;

    --BUSCAR CLIENTE CON MAS PEDIDOS
    SELECT  ID_CLIENTE_F,CANTIDAD_PEDIDOS_F
    INTO V_ID_CLIENTE_MAS_PEDIDOS,V_CANTIDAD_PEDIDOS
    FROM (
        SELECT OP.id_cliente AS ID_CLIENTE_F, COUNT (*) AS CANTIDAD_PEDIDOS_F
        FROM ORDEN_PEDIDO OP
        WHERE TO_NUMBER(TO_CHAR(FECHA_REGISTRO,'YYYY')) = P_ANHO
        GROUP BY op.id_cliente
        ORDER BY COUNT(*) DESC
        )
    WHERE ROWNUM = 1;

    -- IMPRINE RESULTADO ENCONTRADO
    dbms_output.put_line('CLIENTE CON MAS PEDIDOS EN '||P_ANHO);
    DBMS_OUTPUT.PUT_LINE('ID CLIENTE: '||V_ID_CLIENTE_MAS_PEDIDOS);
    dbms_output.put_line('CANTIDAD DE PEDIDOS: '||V_CANTIDAD_PEDIDOS);
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('NO SE ENCONTRARON PEDIDOS EN EL AÑO '|| P_ANHO);
END;
/
--Caso 1: Año con pedidos
EXEC sp_cliente_mas_pedidos(2024);
--Caso 2: Año sin pedidos
EXEC sp_cliente_mas_pedidos(2000);
--Caso 3: Año futuro
EXEC sp_cliente_mas_pedidos(2025);
/
--Pregunta 5

CREATE OR REPLACE PROCEDURE sp_total_buses_pedidos
(P_ID_SEDE CHAR, P_ME_ANHO VARCHAR2,P_ID_TIPO_BUS CHAR) 
IS
V_EXISTE NUMBER := 1;
V_NOMBRE_SEDE CHAR(150);
V_NOMBRE_TP CHAR(120);
V_CANTIDAD NUMBER;
V_MES NUMBER;
V_ANHO NUMBER;
BEGIN
    --VERIFICAR EXISTENCIA SEDE
    SELECT NOMBRE_SEDE
    INTO V_NOMBRE_SEDE
    FROM sede
    WHERE  id_sede = p_id_sede;

    --VERIFICA TIPO DE AUTO
    V_EXISTE := 2;
    SELECT NOMBRE 
    INTO V_NOMBRE_TP
    FROM tipo_bus
    WHERE p_id_tipo_bus = id_tipo_bus;
    IF V_EXISTE = 0 THEN
        dbms_output.put_line('ERROR el tipo de bus no existe no existe');
        RETURN;
    END IF;
    
    -- SACAR EL MES Y EL ANHO
    V_MES := TO_NUMBER(SUBSTR(TRIM(P_ME_ANHO),1,2));
    V_ANHO := TO_NUMBER(SUBSTR(TRIM(P_ME_ANHO),4,4));
    
    -- CALCULA EL TOTAL DE BUSES PRODUCIDOS
    SELECT NVL(SUM (DOP.cantidad),0)
    INTO V_CANTIDAD
    FROM detalle_ord_pedido DOP
    JOIN orden_pedido  OP ON op.id_orden_pedido = dop.id_orden_pedido 
    WHERE OP.id_sede = P_ID_SEDE
        AND dop.id_tipo_bus = p_id_tipo_bus
        AND V_MES = TO_NUMBER(TO_CHAR(OP.FECHA_REGISTRO, 'MM'))
        AND V_ANHO = TO_NUMBER(TO_CHAR(OP.FECHA_REGISTRO, 'YYYY'));
        
    dbms_output.put_line('REPORTE DE BUSES PEIDOS');
    dbms_output.put_line('--------------------------------');
    dbms_output.put_line('SEDE: '||v_nombre_sede);
    dbms_output.put_line('PERIODO: '||p_me_anho);
    dbms_output.put_line('TIPO DE BUS: '||v_nombre_tp);
    dbms_output.put_line('TOTAL PEDIDO: '||v_cantidad||' UNIDADES');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF V_EXISTE = 1 THEN
            dbms_output.put_line('ERROR: la sede no existe');
        else 
            dbms_output.put_line('ERROR: el tipo de bus no existe');
        END IF;
END;
/
--Caso 1: Datos válidos existentes
EXEC sp_total_buses_pedidos(5, '03/2024', 1);
--Caso 2: Sede que no existe
EXEC sp_total_buses_pedidos(999, '03/2024', 1);
--Caso 3: Tipo de bus que no existe
EXEC sp_total_buses_pedidos(1, '03/2024', 999);
--Caso 4: Periodo sin datos
EXEC sp_total_buses_pedidos(1, '01/2023', 2);
/
--PREGUNTA 6
CREATE OR REPLACE PROCEDURE sp_resumen_cliente
(P_ID_CLIENTE CHAR) 
IS
V_NOMBRE_CLIENTE CHAR(80);
V_ULTIMA_FECHA DATE;
V_CANTIDAD NUMBER;
BEGIN
    --VERIFICA EXISTENCIA DEL CLIENTE
    SELECT RAZON_SOCIAL
    INTO V_NOMBRE_CLIENTE
    FROM cliente
    WHERE ID_CLIENTE = P_ID_CLIENTE;
    --HACER REPORTE DEL CLIENTE
    
    SELECT NVL(SUM(dop.cantidad),0),MAX(op.fecha_registro)
    INTO V_CANTIDAD,V_ULTIMA_FECHA
    FROM ORDEN_PEDIDO OP
    LEFT JOIN detalle_ord_pedido DOP ON dop.id_orden_pedido = op.id_orden_pedido
    WHERE op.id_cliente = P_ID_CLIENTE;
    
    --IMPRESION
    dbms_output.put_line('REPORTE COMERCIAL DE CLIENTE');
    dbms_output.put_line('--------------------------------');
    dbms_output.put_line('CLIENTE: '||V_NOMBRE_CLIENTE);
    dbms_output.put_line('CLIENTE: '||V_CANTIDAD);
    IF V_CANTIDAD = 0 THEN
        dbms_output.put_line('ULTIMO PEDIDO: SIN PEDIDOS REGISTRADOS: ');
    ELSE 
        dbms_output.put_line('ULTIMO PEDIDO: '|| V_ULTIMA_FECHA);
    END IF; 
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('ERROR: Cliente con ID: '||P_ID_CLIENTE||' no existe');
END;

/  
--Caso 1: Cliente con varios pedidos
EXEC sp_resumen_cliente(4);

--Caso 2: Cliente sin pedidos
EXEC sp_resumen_cliente(8);

--Caso 3: Cliente que no existe
EXEC sp_resumen_cliente(999);















