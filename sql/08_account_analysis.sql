USE [BankingSalesAnalytics];
GO

-- Read-only analysis of synthetic banking data.

-- Active accounts without transactions
select Ctas.CuentaID
,Cli.ClienteID
,Cli.Nombre
,Cli.Apellido
,cli.Segmento
,Ctas.TipoCuenta
,Ctas.FechaApertura
,Ctas.Saldo
,count(trans.TransaccionID) as Total_Operaciones
from  Clientes as Cli
left join Cuentas as Ctas on Cli.ClienteID=Ctas.ClienteID
left join Transacciones as Trans on Ctas.CuentaID=Trans.CuentaID
where Ctas.Estado='Activa'
and Trans.TransaccionID is null
group by 
Ctas.CuentaID
,Cli.ClienteID
,Cli.Nombre
,Cli.Apellido
,cli.Segmento
,Ctas.TipoCuenta
,Ctas.FechaApertura
,Ctas.Saldo
order by Ctas.Saldo desc;
GO

-- Account distribution by type and status
SELECT TipoCuenta, Estado, COUNT(*) AS Total_cuentas, SUM(Saldo) AS Saldo_total FROM dbo.Cuentas GROUP BY TipoCuenta, Estado ORDER BY TipoCuenta, Estado;
GO
