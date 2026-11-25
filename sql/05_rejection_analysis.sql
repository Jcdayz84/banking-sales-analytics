USE [BankingSalesAnalytics];
GO

-- Read-only analysis of synthetic banking data.

-- Rejection rates by transaction type
with taza_rechazo as (
select TipoTransaccion
,count(TransaccionID) as Tot_operaciones
,SUM( CASE WHEN EstadoTransaccion='Aprobada' then 1 else 0 end ) as aprobadas 
,SUM( CASE WHEN EstadoTransaccion='Rechazada' then 1 else 0 end ) as rechazadas 
from Transacciones
group by TipoTransaccion) select *, (cast(rechazadas *100.0/nullif(Tot_operaciones,0) as decimal(10,2))) as Porcentaje_rechazadas
from taza_rechazo;
GO

-- Rejection reasons by type
with rechazados as (

select 
TipoTransaccion
,MotivoRechazo
,count(*) as TotalRechazos
,sum(monto) as MontoRechazado
from Transacciones
where EstadoTransaccion='Rechazada'
group by TipoTransaccion,MotivoRechazo
) select TipoTransaccion,MotivoRechazo,TotalRechazos,MontoRechazado, 
CAST(
        TotalRechazos * 100.0 /
        SUM(TotalRechazos) OVER (
            PARTITION BY TipoTransaccion
        )
        AS DECIMAL(10,2)
    ) AS PorcentajeRechazos
from rechazados
ORDER BY TipoTransaccion, PorcentajeRechazos DESC;
GO

-- Rejection rates by customer segment
with rechazadas as (
select Cli.Segmento
,count(trans.TransaccionID) as tot_operaciones
,sum(case when EstadoTransaccion='Rechazada' then 1 else 0 end) as tot_rechazadas
,sum(case when EstadoTransaccion='Rechazada' then Monto else 0 end) as Monto_tot_rechazado 
from Transacciones as trans
inner join Cuentas as Ctas on trans.CuentaID=Ctas.CuentaID
inner join clientes as Cli on Ctas.ClienteID=Cli.ClienteID
group by Cli.Segmento
) select *,CAST(tot_rechazadas * 100.0 / NULLIF(tot_operaciones, 0) AS DECIMAL(10,2)) AS  '%rechazo_seg' from rechazadas;
GO

-- Reason distribution within segment
with mot_rechazo as (
select cli.Segmento
,trans.MotivoRechazo
,count(trans.TransaccionID) as cantidad_rechazos
,sum(case when EstadoTransaccion='Rechazada' then trans.Monto else 0 end) as monto_tot_rechazado
from Transacciones as trans
inner join Cuentas as Ctas on trans.CuentaID=Ctas.CuentaID
inner join clientes as Cli on Ctas.ClienteID=Cli.ClienteID
where trans.EstadoTransaccion='Rechazada'
group by Cli.Segmento,trans.MotivoRechazo
) select * 
,CAST(
 cantidad_rechazos * 100.0 /
        SUM(cantidad_rechazos) OVER (
            PARTITION BY segmento
        )
        AS DECIMAL(10,2)
    ) AS '%_rechazo_seg'
from mot_rechazo;
GO
