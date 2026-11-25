USE [BankingSalesAnalytics];
GO

-- Read-only analysis of synthetic banking data.

-- Monthly totals
select 
year(FechaTransaccion) as Año
,month(FechaTransaccion) as Mes
,count(TransaccionID) as Total_operaciones
,sum(monto) as Monto_total
from Transacciones
group by year(FechaTransaccion),month(FechaTransaccion)
order by Año,Mes;
GO

-- Monthly totals by transaction type
select 
year(FechaTransaccion) as Año
,month(FechaTransaccion) as Mes
,TipoTransaccion
,count(TransaccionID) as Total_operaciones
,sum(monto) as Monto_total
,cast(AVG(monto) as decimal(18,2)) as Monto_Promedio
from Transacciones
group by month(FechaTransaccion),year(FechaTransaccion),TipoTransaccion
order by Año,mes,TipoTransaccion;
GO

-- Year-over-year comparison: January through October
with comparacion_anio as (
select 
month(FechaTransaccion) as Mes_
,sum(case when YEAR(fechatransaccion)=2025 then 1 else 0 end ) as 'Operaciones 2025' 
,sum(case when YEAR(fechatransaccion)=2026 then 1 else 0 end ) as 'Operaciones 2026' 
,sum(case when YEAR(fechatransaccion)=2025 then Monto else 0 end ) as 'monto 2025' 
,sum(case when YEAR(fechatransaccion)=2026 then Monto else 0 end ) as 'monto 2026' 
,count(TransaccionID) as Total_operaciones
,sum(monto) as Monto_total
from Transacciones
where month(FechaTransaccion) between 1 and 10
and year(FechaTransaccion) in (2025,2026)
group by month(FechaTransaccion)
) SELECT CASE Mes_  WHEN 1 THEN 'ENERO'
WHEN 2 THEN 'FEBRERO' 
WHEN 3 THEN 'MARZO' 
WHEN 4 THEN 'ABRIL' 
WHEN 5 THEN 'MAYO' 
WHEN 6 THEN 'JUNIO'
WHEN 7 THEN 'JULIO' 
WHEN 8 THEN 'AGOSTO'
WHEN 9 THEN 'SEPTIEMBRE' 
WHEN 10 THEN 'OCTUBRE' ELSE 'N/A' END AS MES

,[Operaciones 2025]
,[Operaciones 2026]
,[monto 2025]
,[monto 2026]
, CAST((([Operaciones 2026]-[Operaciones 2025])*100.0 /nullif([Operaciones 2025],0))  as DECIMAL(10,2)) as 'Variacion_Operaciones_%'
, CAST((([monto 2026]-[monto 2025])*100.0 /nullif([monto 2025],0))  as DECIMAL(10,2)) as 'Variacion_Monto_%'
from comparacion_anio
order by Mes_;
GO

-- Monthly transaction mix: all months
with participacion as (

select 
year(FechaTransaccion) as Año
,month(FechaTransaccion) as Mes
,TipoTransaccion
,count(TransaccionID) as Total_operaciones
,sum(monto) as Monto_total
,cast(AVG(monto) as decimal(18,2)) as Monto_Promedio
from Transacciones
group by month(FechaTransaccion),year(FechaTransaccion),TipoTransaccion
) select *, sum(Total_operaciones) over( partition by año,mes) as Total_mes
,cast (Total_operaciones*100.0/nullif(sum(Total_operaciones) over( partition by año,mes),0) as decimal(10,2)) as 'Participacion %'
from participacion

order by año,mes,TipoTransaccion;
GO
