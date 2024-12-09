create table SELECCION
( idseleccion number primary key,
  nombre varchar2(10) not null );

create table PARTIDO
( idpartido number primary key,
  numfecha number,
  idlocal number references SELECCION (idseleccion),
  goleslocal number,
  idvisit number references SELECCION (idseleccion),
  golesvisit number );

create table ESTADISTICA
( nombre varchar2(10), 
  jugados number,
  ganados number,
  empatados number, 
  perdidos number,
  golesfavor number,
  golescontra number,
  puntos number );