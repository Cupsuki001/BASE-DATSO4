
create database Clientes;

use Clientes





create table temporal(
idUsuario int identity(1,1) primary key not null,
PNombre varchar(40) not null,
Papellido varchar(40) not null,
contra varchar(max) not null,
Direccion varchar(max) not null,
telefono  char(8) check (telefono like '[5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') not null,
estado bit default 0
)


-- Cremamos un Trigger sobre la tabla expedientes

create table Usuarios(
idUsuario int identity(1,1) primary key not null,
PNombre varchar(40) not null,
Papellido varchar(40) not null,
contra varchar(max) not null,
Direccion varchar(max) not null,
telefono  char(8) check (telefono like '[5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') not null,
estado bit default 1
)



go
create TRIGGER StatusChangeTrigger
ON Usuarios
 AFTER UPDATE AS 

 SET IDENTITY_INSERT temporal ON
 IF UPDATE(estado)
 BEGIN
	-- Actualizamos el campo stateChangedDate a la fecha/hora actual
	UPDATE Usuarios SET estado=0 WHERE idUsuario=(SELECT idUsuario FROM inserted);
 
    -- A modo de auditoría, añadimos un registro en la tabla expStatusHistory
	INSERT INTO temporal (idUsuario, PNombre,Papellido,contra,telefono,Direccion) (SELECT idUsuario, PNombre,Papellido,contra,telefono,Direccion FROM deleted WHERE idUsuario=deleted.idUsuario);
	
    -- La tabla deleted contiene información sobre los valores ANTIGUOS mientras que la tabla inserted contiene los NUEVOS valores.
    -- Ambas tablas son virtuales y tienen la misma estructura que la tabla a la que se asocia el Trigger. 
 END;

 go


 
go
create proc eliminarUsuario
@id int
as
    
	if exists (select idUsuario from Usuarios where idUsuario=@id)
  begin
       update Usuarios set estado=0 where idUsuario=@id
  end

go


go
create proc editUsuario
@id int,
@tel char(8),
@dir varchar(max)
as
  if exists (select idUsuario from Usuarios where idUsuario=@id)
  begin
       update Usuarios set telefono=@tel where idUsuario=@id
	   update Usuarios set Direccion=@dir where idUsuario=@id
  end
    
go


go
create proc InsertarUsuario
@Pnombre varchar(40),@Papellido varchar(40),@contra varchar(max),
@direccion varchar(max),@telefono char(8)
as
   insert into Usuarios (PNombre,Papellido,contra,Direccion,telefono) values (@Pnombre,@Papellido,@contra,@direccion,@telefono) 
go

go
create proc MostrarUsuarios
as
     select idUsuario as ID,PNombre as Nombre,Papellido as Apellido,contra as Contraseña ,Direccion as Direccion,telefono as Telefono from Usuarios where estado=1
     
go

create table Proveedor(
Id_Proveedor int identity(1,1) primary key not null,
NombreProv nvarchar(45) not null,
DirProv nvarchar(70) not null,
TelProv char(8) check(TelProv like '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
MailP nvarchar(50)
)

-- Procedimiento de insercion
create procedure Nproveedor
@NP nvarchar(45),
@DP nvarchar(70),
@TP char(8),
@MP nvarchar(50)
as
insert into Proveedor values(@NP,@DP,@TP,@MP,1)

Nproveedor 'DICEGSA','Carretera a Leon','22451545','dicegsa@gmail.com'

select * from Proveedor

-- Dar de baja al proveedor
-- agregar un nuevo campo a la tabla Proveedor
alter table Proveedor add EstadoP bit default 1



Nproveedor 'RAMOS','Carretera Norte','84749652','lramos@gmail.com'

create procedure DBP
@IDP int
as
declare @idprov as int
set @idprov=(select Id_Proveedor from Proveedor where Id_Proveedor=@IDP)
if(@IDP=@idprov)
begin
  update Proveedor set EstadoP=0 where Id_Proveedor=@IDP
end
else
begin
   print 'Proveedor no encontrado'
end

DBP 2

-- Modificacion de Proveedor
create procedure MProv
@IDP int,
@DP nvarchar(70),
@TP char(8),
@MP nvarchar(50)
as
declare @idprov as int
set @idprov=(select Id_Proveedor from Proveedor where Id_Proveedor=@IDP)
if(@IDP=@idprov)
begin
  update Proveedor set DirProv=@DP,TelProv=@TP,MailP=@MP where 
  Id_Proveedor=@IDP and EstadoP=1
end
else
begin
   print 'Proveedor no encontrado'
end

select * from Proveedor

MProv 1,'Masaya','22458574','distcgtgmail.com'

-- Procedimiento de busqueda
create procedure BProv
@IDP int
as
declare @ip as int
set @ip=(select Id_Proveedor from Proveedor where Id_Proveedor=@IDP)
if(@ip=@IDP)
begin
  select * from Proveedor where Id_Proveedor=@IDP and EstadoP=1
end
else
begin
  print 'Proveedor no encontrado'
end

BProv 1

-- Listar proveedores
create procedure ListarP
as
select * from Proveedor where EstadoP=1

ListarP

-- Crear tabla Productos
create table Productos(
CodProd char(5) primary key not null,
NombreProd nvarchar(45) not null,
DescProd nvarchar(60) not null,
precioP float not null,
existp int not null,
Id_Proveedor int foreign key references Proveedor(Id_Proveedor) not null
)

-- Crear los procedimientos de : Insercion, BAJA, Modificacion, Busqueda y Lista
-- de Productos

sp_addlogin 'Alex','AlexMadriz2023','Clientes'
sp_addsrvrolemember 'Alex','sysadmin'
sp_adduser 'Alex','AIMM'
sp_addrolemember 'db_datareader','AIMM'
sp_addrolemember 'db_datawriter','AIMM'

select * from Usuarios

select * from temporal