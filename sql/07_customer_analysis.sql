USE [BankingSalesAnalytics];
GO

-- Read-only analysis of synthetic banking data.

-- Customer activity
select 
Cli.ClienteID
,Cli.Nombre
,Cli.Apellido
,Cli.Segmento
,Count(distinct Ctas.CuentaID) as Total_cuentas
,Count(Trans.TransaccionID) as Total_operaciones
,coalesce(Sum(Trans.Monto),0) as Monto_total
,CAST(ISNULL(AVG(Trans.Monto),0) AS DECIMAL(18,2)) AS Monto_Promedio
,min(Trans.FechaTransaccion) as Primera_operacion
,max(Trans.FechaTransaccion) as Ultima_operacion
from Clientes as Cli
left join Cuentas as Ctas on Cli.ClienteID=Ctas.ClienteID
left join Transacciones as Trans on Ctas.CuentaID=Trans.CuentaID
group by Cli.ClienteID
,Cli.Nombre
,Cli.Apellido
,Cli.Segmento
order by Total_operaciones desc,ClienteID;
GO

-- Top five customers by segment
with ActividadClientes as (
select 
Cli.ClienteID
,Cli.Nombre
,Cli.Apellido
,Cli.Segmento
,Count(distinct Ctas.CuentaID) as Total_cuentas
,Count(Trans.TransaccionID) as Total_operaciones
,coalesce(Sum(Trans.Monto),0) as Monto_total
,CAST(ISNULL(AVG(Trans.Monto),0) AS DECIMAL(18,2)) AS Monto_Promedio
,min(Trans.FechaTransaccion) as Primera_operacion
,max(Trans.FechaTransaccion) as Ultima_operacion
from Clientes as Cli
left join Cuentas as Ctas on Cli.ClienteID=Ctas.ClienteID
left join Transacciones as Trans on Ctas.CuentaID=Trans.CuentaID
group by Cli.ClienteID
,Cli.Nombre
,Cli.Apellido
,Cli.Segmento
)
,ranking as ( select 
ClienteID	
,Nombre	
,Apellido	
,Segmento	
,Total_cuentas	
,Total_operaciones	
,Monto_total	
,Monto_Promedio
, ROW_NUMBER () over (partition by segmento order by monto_total desc,clienteid asc) as Ranking_segmento
from ActividadClientes where Total_operaciones>0

) select * from ranking
where Ranking_segmento between 1 and 5
order by Segmento,Ranking_segmento;
GO
