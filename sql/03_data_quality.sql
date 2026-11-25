USE [BankingSalesAnalytics];
GO

-- Read-only analysis of synthetic banking data.

-- Table counts
SELECT 'Sucursales' AS Tabla, COUNT(*) AS Total FROM dbo.Sucursales UNION ALL SELECT 'Clientes' AS Tabla, COUNT(*) AS Total FROM dbo.Clientes UNION ALL SELECT 'Productos' AS Tabla, COUNT(*) AS Total FROM dbo.Productos UNION ALL SELECT 'Cuentas' AS Tabla, COUNT(*) AS Total FROM dbo.Cuentas UNION ALL SELECT 'Transacciones' AS Tabla, COUNT(*) AS Total FROM dbo.Transacciones;
GO

-- Required transaction fields
SELECT COUNT(*) AS TotalRegistros, COUNT(*)-COUNT(CuentaID) AS CuentasNulas, COUNT(*)-COUNT(FechaTransaccion) AS FechasNulas, COUNT(*)-COUNT(TipoTransaccion) AS TiposNulos, COUNT(*)-COUNT(Monto) AS MontosNulos, COUNT(*)-COUNT(EstadoTransaccion) AS EstadosNulos FROM dbo.Transacciones;
GO

-- Potential duplicate transactions
SELECT
    CuentaID,
    FechaTransaccion,
    TipoTransaccion,
    Monto,
    EstadoTransaccion,
    COUNT(*) AS TotalDuplicados
FROM Transacciones
GROUP BY
    CuentaID,
    FechaTransaccion,
    TipoTransaccion,
    Monto,
    EstadoTransaccion
HAVING COUNT(*) > 1
ORDER BY TotalDuplicados DESC;
GO

-- Orphan references
SELECT 'Clientes.SucursalID' AS Relacion, COUNT(*) AS Huerfanos FROM dbo.Clientes a LEFT JOIN dbo.Sucursales b ON a.SucursalID=b.SucursalID WHERE a.SucursalID IS NOT NULL AND b.SucursalID IS NULL UNION ALL SELECT 'Cuentas.ClienteID' AS Relacion, COUNT(*) AS Huerfanos FROM dbo.Cuentas a LEFT JOIN dbo.Clientes b ON a.ClienteID=b.ClienteID WHERE a.ClienteID IS NOT NULL AND b.ClienteID IS NULL UNION ALL SELECT 'Cuentas.ProductoID' AS Relacion, COUNT(*) AS Huerfanos FROM dbo.Cuentas a LEFT JOIN dbo.Productos b ON a.ProductoID=b.ProductoID WHERE a.ProductoID IS NOT NULL AND b.ProductoID IS NULL UNION ALL SELECT 'Transacciones.CuentaID' AS Relacion, COUNT(*) AS Huerfanos FROM dbo.Transacciones a LEFT JOIN dbo.Cuentas b ON a.CuentaID=b.CuentaID WHERE a.CuentaID IS NOT NULL AND b.CuentaID IS NULL;
GO

-- Negative snapshot balances
SELECT * FROM dbo.Cuentas WHERE Saldo < 0;
GO

-- Transfer records missing identifiers
SELECT * FROM dbo.Transacciones WHERE TipoTransaccion IN ('Transferencia enviada','Transferencia recibida') AND TransferenciaID IS NULL;
GO

-- Transfer pairing exceptions
SELECT TransferenciaID FROM dbo.Transacciones WHERE TransferenciaID IS NOT NULL GROUP BY TransferenciaID HAVING NOT ((COUNT(*)=2 AND SUM(CASE WHEN TipoTransaccion='Transferencia enviada' AND EstadoTransaccion='Aprobada' THEN 1 ELSE 0 END)=1 AND SUM(CASE WHEN TipoTransaccion='Transferencia recibida' AND EstadoTransaccion='Aprobada' THEN 1 ELSE 0 END)=1 AND MIN(Monto)=MAX(Monto)) OR (COUNT(*)=1 AND SUM(CASE WHEN TipoTransaccion='Transferencia enviada' AND EstadoTransaccion='Rechazada' THEN 1 ELSE 0 END)=1));
GO

-- Customer reconciliation
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
) select count(ClienteID) as Total_Clientes
,sum(Total_cuentas) as Total_Cuentas
,sum(Total_operaciones) as Total_Operaciones
,SUM(CASE WHEN primera_operacion is not null then 1 else 0 end ) as Clientes_con_operaciones
,SUM(CASE WHEN primera_operacion is null then 1 else 0 end ) as Clientes_sin_operaciones
,SUM(Monto_total) as Monto_Total
from ActividadClientes;
GO
