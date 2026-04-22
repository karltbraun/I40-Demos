# UNS Analysis — `Enterprise/#`

**Capture duration:** 5 minutes  
**Messages received:** 6,969  
**Unique topics:** 418  

---

## Namespace Structure

The UNS follows a clean ISA-95 hierarchy:

```
Enterprise
├── Austin
│   ├── Press       (Line1, Line2)
│   ├── Assembly    (Line1, Line2)
│   └── Heat Treat  (Line1, Line2)
└── Dallas
    ├── Press       (Line1, Line2)
    ├── Assembly    (Line1, Line2)
    └── Heat Treat  (Line1, Line2)
```

2 sites × 3 areas × 2 lines = 12 production lines total. Each Press and Assembly line publishes 7 distinct topic categories: `Edge`, `MES/KPIs`, `MES/Quality`, `MES/Maintenance`, `ERP`, `S88`, `55001`, `BigQuery`, `Dashboard`. Heat Treat is notably sparser (see issues below).

---

## Data Layers Per Line

| Layer | Topics | Description |
|---|---|---|
| **Edge** | Infeed, Outfeed, Waste, State, 10x Process sensors | Real-time machine data |
| **MES/KPIs** | OEE, Availability, Quality, Performance, TEEP, MTTR, MTBF | Production metrics |
| **MES/Quality** | InspectionResult, Rejection, Accepted qty | QMS data |
| **MES/Maintenance** | MachineID, Status, Last/NextMaintenanceDate | CMMS data |
| **ERP** | Order lifecycle, quantities, item, location | ERP integration |
| **S88** | JSON batch control blob | ISA-88 batch data |
| **55001** | Asset lifecycle, risk, compliance | ISO 55001 asset mgmt |
| **BigQuery** | Full consolidated JSON snapshot | Analytics/historian |
| **Dashboard** | Simplified KPI snapshot | Visualization layer |
| **OperationsSchedule** | Shift schedule JSON | Site-level scheduling |

---

## OEE Performance — All Lines Are Struggling

| Line | Availability | Performance | Quality | OEE |
|---|---|---|---|---|
| Austin/Assembly/Line1 | 0.02 | 0.20 | 0.22 | **0.00** |
| Austin/Assembly/Line2 | 0.85 | 0.11 | 0.37 | **0.03** |
| Austin/Press/Line1 | 0.28 | 0.11 | 0.79 | **0.02** |
| Austin/Press/Line2 | 0.18 | 0.95 | 0.49 | **0.08** |
| Dallas/Assembly/Line1 | 0.51 | 0.24 | 0.44 | **0.05** |
| Dallas/Assembly/Line2 | 0.12 | 0.97 | 0.84 | **0.10** |
| Dallas/Press/Line1 | 0.03 | 0.56 | 0.69 | **0.01** |
| Dallas/Press/Line2 | 0.33 | 0.27 | 0.73 | **0.07** |

World-class OEE is ~85%. Every line is below 10%. The primary drag varies by line — some are availability-limited, others performance-limited — giving the AI good diagnostic angles to demonstrate.

---

## Notable Alerts & Anomalies

### Maintenance
- `Dallas/Assembly/Line1` — NextMaintenanceDate is **2026-04-17** (3 days away)
- `Dallas/Press/Line2` (BigQuery) — MaintenanceStatus = **"Overdue"**

### Safety
- `Austin/Press/Line1` (S88) — SafetyStatus = **"Risk"**
- Multiple lines — HMI OperatorInterfaceStatus = **"Fault"**
- Multiple lines — S88 CapperStatus = **"Faulty"**

### Quality Failures
- `Austin/Press/Line1` — InspectionResult = "Fail", RejectionReason = "Non-conformance"
- `Dallas/Assembly/Line2` — InspectionResult = "Fail", RejectionReason = "Damage", RejectionQuantity = 14

---

## Data Quality Issues

1. **OEE contradiction** — MES/KPIs OEE values (0–10%) conflict dramatically with the same lines' `BigQuery`/`Dashboard` OEE values (50–90%). The two data sources are inconsistent; which is authoritative needs to be clarified in the simulation.

2. **Outfeed > Infeed anomaly** — e.g., Austin/Assembly/Line1: Infeed=16.76, Outfeed=57.96, Waste=41.2. Mass balance doesn't hold. Units may be different across topics.

3. **Heat Treat is incomplete** — Only `Dashboard` and `S88` topics appear for Heat Treat. No `Edge`, `MES`, or `ERP` topics are visible. Either the simulator isn't publishing them or they're on a different topic path.

4. **BU value is truncated** — Both `Austin/BU` and `Dallas/BU` publish `"Chain"` — almost certainly should be `"Supply Chain"` or similar.

5. **GM naming inconsistency** — Austin GM = `"Charlie"` (first name only), Dallas GM = `"Dana White"` (full name).

6. **S88 content mismatch** — S88 blobs reference `SodaRecipe`, `BottlerStatus`, `CapperStatus`, and `BatchMixingTank` — beverage bottling terminology — but the areas are named "Press" and "Assembly," which suggest discrete/metalworking manufacturing. The domain model is mixed.

7. **OperationsSchedule `Shifts` field** — Assembly publishes `"Shifts": 1` but the payload still contains Shift2 and Shift3 time blocks. The field value doesn't match the structure.

---

## Summary

The UNS is well-structured and rich — a solid demo platform with meaningful ISA-95 hierarchy, multi-source integration (Edge, MES, ERP, S88, ISO 55001), and enough anomalies to make AI-driven analysis interesting. The main things to resolve before using it for live demos are the OEE data source conflict, the incomplete Heat Treat area, and the S88 domain terminology mismatch.
