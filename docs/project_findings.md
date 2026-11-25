# Project findings

## Scope and metric definitions

The analysis covers synthetic transaction records from January 1, 2025 to November 17, 2026. A transaction record is one row in `Transacciones`, not necessarily one unique banking operation. An approved transfer normally has an outgoing and an incoming record; a rejected outgoing transfer has one record. Total recorded amount is the sum of `Monto`, including rejected records and both transfer legs. Rejection rate is rejected records divided by all records in the relevant group. Amounts are in dataset monetary units.

## 1. Transaction activity

| Type | Status | Records | Recorded amount |
|---|---|---:|---:|
| Deposit | Approved | 11,997 | 92,810,911.00 |
| Withdrawal | Approved | 10,757 | 80,319,964.00 |
| Withdrawal | Rejected | 1,240 | 12,386,056.00 |
| Outgoing transfer | Approved | 2,669 | 20,173,630.00 |
| Outgoing transfer | Rejected | 334 | 3,457,544.00 |
| Incoming transfer | Approved | 2,671 | 20,180,630.00 |
| **Total** | | **29,668** | **229,328,735.00** |

Approved records account for 94.69% of the dataset. Rejected records account for 5.31%, with a recorded amount of 15,843,600.00. Rejected amounts are requested amounts, not actual funds moved or financial losses.

## 2. Rejection analysis

| Transaction type | Total records | Rejected | Rejection rate |
|---|---:|---:|---:|
| Deposit | 11,997 | 0 | 0.00% |
| Withdrawal | 11,997 | 1,240 | 10.34% |
| Outgoing transfer | 3,003 | 334 | 11.12% |
| Incoming transfer | 2,671 | 0 | 0.00% |

Outgoing transfers have the highest rejection rate, while withdrawals have the largest rejection count. All 1,574 rejected records have the reason `Fondos insuficientes` (insufficient funds), consistent with the synthetic simulation rules.

| Customer segment | Total records | Rejected | Rejection rate | Rejected amount |
|---|---:|---:|---:|---:|
| Regular | 9,859 | 559 | 5.67% | 5,684,503.00 |
| Premium | 9,901 | 515 | 5.20% | 5,138,276.00 |
| Preferente | 9,908 | 500 | 5.05% | 5,020,821.00 |

Regular has the highest record-based rejection rate. The dataset does not establish why this difference exists or whether it reflects real customer behavior.

## 3. Temporal analysis

Year-over-year comparisons use January through October in each year because November 2026 is incomplete.

| Month | Record count change | Recorded amount change |
|---|---:|---:|
| January | -6.08% | -5.12% |
| February | +2.94% | +0.86% |
| March | +8.77% | +2.91% |
| April | +1.63% | +3.13% |
| May | +3.40% | +4.27% |
| June | -1.20% | -2.59% |
| July | +4.26% | +6.32% |
| August | +0.44% | -0.28% |
| September | -7.65% | -7.99% |
| October | +0.91% | +3.79% |

March has the largest year-over-year increase in record count; July has the largest increase in recorded amount. September has the largest decline on both measures. The two metrics can move differently because transaction amounts vary.

In October 2026, deposits represented 41.20% of records compared with 37.52% for withdrawals. Withdrawal share fell by 3.75 percentage points from October 2025 (41.27%). Deposits and withdrawals represented approximately 80% of records in the January and October snapshots examined.

## 4. Customers and accounts

- 951 of 1,000 customers have transaction records (95.1%); 49 do not.
- Customer 892 (Regular) has the highest recorded transaction amount: 655,909.00 across 76 records.
- Customer 975 (Premium) has 78 records and a recorded amount of 610,549.00, illustrating that transaction frequency and amount are different measures.
- The top five customers by amount in each segment sum to 2,902,707.00 (Regular), 2,880,855.00 (Premium) and 2,834,472.00 (Preferente). These are top-five totals, not full-segment totals or profitability measures.
- The ranking uses `ROW_NUMBER()` partitioned by segment with `ClienteID` as a deterministic tie-breaker.

| Account type | Active | Inactive | Total |
|---|---:|---:|---:|
| Savings | 495 | 54 | 549 |
| Debit | 496 | 55 | 551 |
| Payroll | 494 | 55 | 549 |
| **Total** | **1,485** | **164** | **1,649** |

No active account lacks a transaction record in the dataset. This describes recorded activity over the available period; it does not establish recent activity or real-world customer engagement.

## 5. Data quality and reproducibility

The original database and the independent test database produced matching principal validation indicators on November 25, 2026.

| Check | Result |
|---|---|
| Critical nulls in transaction account, date, type, amount and status | 0 |
| Potential duplicate groups (account, date, type, amount and status) | 0 |
| Orphan references across four foreign-key relationships | 0 |
| Negative account snapshot balances | 0 |
| Transfer pairing exceptions among non-null transfer IDs under the implemented checks | 0 |
| Transfer records missing a transfer ID | 2 |
| Reconciled customers / accounts / transaction records | 1,000 / 1,649 / 29,668 |
| Reconciled recorded transaction amount | 229,328,735.00 |

### Known transfer exception

Two historical synthetic incoming transfer records have missing `TransferenciaID` values. They are retained rather than assigning unsupported identifiers.

| Transaction ID | Account ID | Date | Amount |
|---:|---:|---|---:|
| 8 | 6 | 2025-01-13 | 3,000.00 |
| 15 | 15 | 2025-01-25 | 4,000.00 |

They cannot be matched to outgoing transfer records using the transfer ID. The paired-transfer check excludes null IDs; this is why the missing-ID exception is reported separately.

The customer aggregation queries may produce SQL Server's informational warning about null values eliminated by aggregate operations, consistent with left joins that retain customers without transaction records. The queries completed successfully.

The reproducibility test verified the principal aggregate indicators and quality checks, not full row-level equality or every analysis query in the test database. The exported data file contains all 32,325 INSERT statements, including the three product records. Account balances are snapshots; no claim is made that they reconcile to a full transaction ledger.

## 6. Interpretation and limitations

This is a portfolio simulation, not an analysis of an actual financial institution. Results should not be used to infer real customer preferences, financial losses, profitability or causal relationships. The project demonstrates SQL analysis, validation, transparent exception handling and reproducible dataset setup. The next planned stage is BI visualization using the same data model.
