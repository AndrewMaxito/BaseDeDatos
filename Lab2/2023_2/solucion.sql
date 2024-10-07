--pregunat 1
SELECT c.descripcion as Categoria ,DECODE(c.estado, 'I', 'Inactivo', c.estado) as estado, COUNT(p.idprenda)
    from bs_categoria c, bs_prenda p where (c.estado = 'I' and p.idcategoria = c.idcategoria)
    group by c.descripcion, DECODE(c.estado, 'I', 'Inactivo', c.estado)
    ORDER BY COUNT(*) DESC, c.descripcion ASC;


--prgunta 2

SELECT c.descripcion as Categoria ,p.descripcion as Prenda, p.color as color
from bs_categoria c, bs_prenda p 
where c.estado = 'I' 
and p.idcategoria = c.idcategoria 
and c.idcategoria = (
    select idcategoria 
    from (
        SELECT c.idcategoria 
        from bs_categoria c, bs_prenda p 
        where (c.estado = 'I' and p.idcategoria = c.idcategoria)
        group by c.idcategoria
        ORDER BY COUNT(*) DESC)--Esto de aca ordena los luyego para luego limitarlo
    WHERE ROWNUM =1)--aca limita
;

--pregunta 3

select c.descripcion as CATEGORIA, p.idprenda, p.descripcion as prenda,p.color
from bs_categoria c, bs_prenda p
where c.idcategoria = p.idcategoria
    and c.idcategoria in ( -- se usa in ya devolvera un rango de valores 
    SELECT  c.idcategoria
    from bs_categoria c,bs_prenda p
    where c.idcategoria = p.idcategoria
    group by c.idcategoria --agrupa la categorias 
    having count(*)>10
    )
    ORDER BY c.descripcion,p.idprenda
;

--pregunta 4

SELECT 
    CASE 
        WHEN ROWNUM = 1 THEN 'Primera tienda'
        WHEN ROWNUM = 2 THEN 'Segunda tienda'
        WHEN ROWNUM = 3 THEN 'Tercera tienda'
        ELSE 'Posterior'
    END as ORDEN,
        NVL(TO_CHAR(t.fechaapertura), 'por aperturar') AS PORAPERTURAR
FROM bs_tienda t
ORDER BY t.idtienda;

--Pregunta 5

select t.talla,count (*)
from bs_prenda p,bs_matriz_talla t
where p.idprenda = t.idprenda
group by t.talla
order by t.talla;

--Pregunta 6

select c.descripcion as Categoria, count (mt.idprenda)
from bs_prenda p,bs_categoria c,bs_matriz_talla mt
where mt.idprenda=p.idprenda 
    and p.idcategoria = c.idcategoria
    and mt.precio_venta > 50 
    AND mt.talla NOT IN ('XS', 'S', 'XXL', 'XXXL')
group by c.descripcion;


--extra
select c.descripcion as Categoria, mt.talla,mt.precio_venta,count(mt.idprenda)
from bs_prenda p,bs_categoria c,bs_matriz_talla mt
where p.idcategoria = c.idcategoria
    and mt.idprenda=p.idprenda 
    and mt.precio_venta > 50 
    AND mt.talla NOT IN ('XS', 'S', 'XXL', 'XXXL')
group by c.descripcion, mt.talla,mt.precio_venta
order by  c.descripcion;


--pregunta 7
select c.descripcion as Categoria, p.descripcion,avg (mt.precio_venta)
from bs_prenda p,bs_categoria c,bs_matriz_talla mt
where p.idcategoria = c.idcategoria
      and mt.idprenda=p.idprenda 
group by c.descripcion,p.descripcion
order by c.descripcion;

--extra
select c.idcategoria,c.descripcion,mt.idprenda,p.descripcion,avg(mt.precio_venta) 
from  bs_prenda p,bs_categoria c,bs_matriz_talla mt
where mt.idprenda=p.idprenda and p.idcategoria = c.idcategoria
group by mt.idprenda,c.idcategoria,c.descripcion,p.descripcion
order by mt.idprenda;

--pregunta 8 chargpt
SELECT c.descripcion AS Categoria, 
       p.descripcion AS Prenda, 
       p.color AS Color, 
       mt.talla AS Talla, 
       mt.precio_venta AS PrecioVenta
FROM bs_categoria c
JOIN bs_prenda p ON c.idcategoria = p.idcategoria
JOIN bs_matriz_talla mt ON p.idprenda = mt.idprenda
WHERE mt.precio_venta < (
    SELECT AVG(mt2.precio_venta)
    FROM bs_matriz_talla mt2
)
ORDER BY  mt.talla,mt.precio_venta desc,c.descripcion, p.descripcion;