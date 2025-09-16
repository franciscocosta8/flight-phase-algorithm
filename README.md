# Francisco Alves Costa TUM Semester Thesis

## Flight-Phase Algorithm (ADS-B, MATLAB)

MATLAB pipeline to (i) label instantaneous and overall flight phases from ADS-B data, (ii) detect go-arounds (if/when/where), and (iii) analyse whether neighbouring traffic respected **EU** separation minima before and after a go-around.

## Key Outputs
- `dailySummaries` — instantaneous + overall phases per aircraft/day.
- `ComputeDistances_dailySummaries` — pairwise 3-D separations on common time grids.
- `GoAroundsData` — per-event details (timing/location, interacting flights, aircraft types, wake-turbulence classes, separations, compliance flags).

## Requirements
- MATLAB **R2022b** or later.
- Typical toolboxes: *Aerospace Toolbox* and/or *Mapping Toolbox* (for geodetic/ECEF/ENU conversions).

## Data Preparation (contact author to get data samples)
Place monthly ADS-B `.mat` files in `data/` with these exact names:
- **May 2024** → `may24.mat`
- **June 2024** → `jun24.mat`

Expected content: a `results` struct array (e.g., `1×N`) containing metadata (`callsign`, `airline`, …) and a `flightData` struct with time-aligned data. Flights with missing/placeholder `callsign`/`airline` are skipped.

## Quick Start (MATLAB)

**Run in MATLAB in this order (June and May’s data files should be named `jun24` and `may24` respectively):**
1. `flight_phase_identification.m` → produces **dailySummaries** (instant + overall phases). ~**4–5 min** (1 month).
2. `compare_runs.m` → produces **ComputeDistances_dailySummaries**. ~**30 s**.
3. `GoAroundsStructCreator.m` → produces **GoAroundsData** (go-around details). ~**1 s**.



