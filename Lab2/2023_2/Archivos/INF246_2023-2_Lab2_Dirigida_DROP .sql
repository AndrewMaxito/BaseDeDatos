BEGIN
EXECUTE IMMEDIATE 'drop table GP_CICLO CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_categoria CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_cliente CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_detalle_guia CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_detalle_orden CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_detalle_venta CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_empleado CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_guiapreventa CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_guiasastreria CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_inventario CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_matriz_talla CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_orden_fabricacion CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_persona CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_prenda CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_tienda CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE bs_venta CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

