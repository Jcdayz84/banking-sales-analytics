USE [BankingSalesAnalytics];
GO

-- Read-only analysis of synthetic banking data.

-- Transaction statistics by type and status
SELECT TipoTransaccion
,EstadoTransaccion
,count(TransaccionID) as num_operaciones
,sum(Monto) as Monto_Total
,AVG(Monto) as Monto_Promedio
,Min(Monto) as Monto_Minimo
,MAx(Monto) as Monto_MAximo
from Transacciones
group by TipoTransaccion,EstadoTransaccion
order by TipoTransaccion,EstadoTransaccion;
GO
