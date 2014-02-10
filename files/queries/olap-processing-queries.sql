OLAP

DIMENSION AND FACTS SOURCE TRANSACTION PROCESSING QUERIES


PLAZA DIMENSION
---------------
set generator dimensiones to 1000;

insert into plaza_dimension(id,pais,estado,ciudad,localidad)
select gen_id(dimensiones,1) id,'MEXICO' pais, cp.estado, cp.ciudad, cp.municipio localidad FROM
(
select distinct ESTADO,CIUDAD,MUNICIPIO
from CPs
order by estado,ciudad,municipio
) cp


ARTICULO DIMENSION
------------------
INSERT INTO ARTICULO_DIMENSION
(id, producto, linea, marca, temporada, rating, fecha_alta, fecha_ultima ,st)
SELECT id, cast(trim(arcveart) as varchar(32)), 
arlinea linea, armarca marca, artempo temporada,
cast(iif(lento=1,'LENTO','BASICO') as varchar(8)) rating,

cast((select cast(min(fafecha) as date) from factura f join facturadet on f.id=factura_id and articulo_id=a.id) as date) fecha_alta,
cast((select cast(max(fafecha) as date) from factura f join facturadet on f.id=factura_id and articulo_id=a.id) as date) fecha_ultima,
ARST ST

from ARTICULO a
where ( a.tipoarticulo_id in(0,3)  or (a.tipoarticulo_id not in(0,3) and linea_id not in(2097, 2102, 2089) )) and 
((arcveart like ('Z%') and arst='A') or arcveart not like ('Z%'))
and (select cast(min(fafecha) as date) from factura f2 join facturadet on f2.id=factura_id and articulo_id=a.id) is not null
order by id


CLIENTES DIMENSION
------------------
insert into CLIENTE_DIMENSION
SELECT id, iif( clcvecli not similar to '([A-Za-z0-9]{1,})',substring(clnom from 8 for 4),cast(trim(clcvecli) as varchar(8))),iif(trim(cltda)='','',trim(cltda)),
coalesce(z.zodescrip,''),clclasific,
cast('' as varchar(8)) rating,
iif(clst='A','A','B') st
from clientes c
left join zonas z on z.zocve=clzona
--where clcvecli not similar to '([A-Za-z0-9]{1,})'
order by c.clcvecli,c.cltda





VENTAS FACTS
------------
SELECT 
t.id tiempo_id,
a.id articulo_id, 
c.id cliente_id,
p.id plaza_id,
sum(fd.fadcant) unidades,
sum(fd.fadimporteneto) importe,
avg(fd.fadpreciodesc) precio_prom,
0 costo_prom,
count(fd.articulo_id) transacciones,
0 t
from factura f
join facturadet fd ON f.id=fd.factura_id
join tiempo_dimension t ON t.ano=extract(year from f.fafecha) and t.mes=extract(month from f.fafecha)
join cliente_dimension c ON c.id=f.cliente_id
join articulo_dimension a ON a.id=fd.articulo_id
join clientes cl ON cl.id=c.id
join cps cp ON cl.clcp=cp.cve 
join plaza_dimension p ON p.pais=cl.clpais AND p.estado=cp.estado AND p.ciudad=cp.CIUDAD and p.localidad=cp.MUNICIPIO 
WHERE fafecha>='2014-01-01' AND f.fat=0
GROUP BY t.id,a.id,c.id,p.id

SELECT 
t.id tiempo_id,
a.id articulo_id, 
c.id cliente_id,
min((select id from PLAZA_DIMENSION  where pais=cl.clpais AND estado=cp.estado AND ciudad=cp.CIUDAD and localidad=cp.MUNICIPIO rows 1 )) plaza_id,
sum(fd.fadcant) unidades,
sum(fd.fadimporteneto) importe,
avg(fd.fadpreciodesc) precio_prom,
0 costo_prom,
count(fd.articulo_id) transacciones,
0 t
from factura f
join facturadet fd ON f.id=fd.factura_id
join tiempo_dimension t ON t.ano=extract(year from f.fafecha) and t.mes=extract(month from f.fafecha)
join cliente_dimension c ON c.id=f.cliente_id
join articulo_dimension a ON a.id=fd.articulo_id
join clientes cl ON cl.id=c.id
join cps cp ON cl.clcp=cp.cve
WHERE fafecha>='2012-01-01' AND f.fat=0 AND (fd.fadcveart like 'POWEB%' or fd.fadcveart like 'ALIS%' or fd.fadcveart like 'YESS%' or fd.fadcveart like 'IRON%' or fd.fadcveart like '1034%' or a.linea='CAMI')
GROUP BY t.id,a.id,c.id
ORDER BY t.id,a.id,c.id
ROWS 4096


set generator DIMENSIONES to 1000;

INSERT INTO ventas_fact
SELECT 
gen_id(DIMENSIONES,1) id,
t.id tiempo_id,
a.id articulo_id, 
c.id cliente_id,
min((select id from PLAZA_DIMENSION  where pais=cl.clpais AND estado=cp.estado AND ciudad=cp.CIUDAD and localidad=cp.MUNICIPIO rows 1 )) plaza_id,
sum(fd.fadcant) unidades,
sum(fd.fadimporteneto) importe,
avg(fd.fadpreciodesc) precio_prom,
0 costo_prom,
count(fd.articulo_id) transacciones
from factura f
join facturadet fd ON f.id=fd.factura_id
join tiempo_dimension t ON t.ano=extract(year from f.fafecha) and t.mes=extract(month from f.fafecha) and t.t=0
join cliente_dimension c ON c.id=f.cliente_id
join articulo_dimension a ON a.id=fd.articulo_id
join clientes cl ON cl.id=c.id
join cps cp ON cl.clcp=cp.cve
WHERE  f.fat=0 and f.fast='A' 
GROUP BY t.id,a.id,c.id
ORDER BY t.id,a.id,c.id;

commit;


/* START MONGODB */
sudo  /opt/local/bin/mongod --verbose --nounixsocket --maxConns 16 --directoryperdb --dbpath /Users/neurobits/Develop/db.mongodb --logpath /Users/neurobits/Develop/db.mongodb/log/mongodb.log --logappend --pidfilepath /private/var/tmp/mongod.pid --journal --jsonp --rest --smallfiles



