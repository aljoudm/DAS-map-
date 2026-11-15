# DAS perimeter-security digital twin (Makkah, Hajj)

MATLAB code that builds the high-level figure for the capstone *AI-Based Distributed Optical Fiber Sensing (DOFS) Network for
Autonomous Perimeter Security and Real-Time Intruder Detection and Tracking: Hajj Season Use Case* (Princess Nourah bint
Abdulrahman University, Electrical Engineering, Telecommunications).

The figure is a 3D digital twin of the proposed system: a DAS fibre along the boundary of the Haram and Arafat, interrogator
units, CCTV, UAVs, patrols, a C2 centre, computed weak-coverage zones, one intrusion event (walking, "detected -> human -> ALARM")
and one non-human event (vehicle on a road, "detected -> vehicle on road -> logged"), a Mashaer inset, a status panel and the
DAS trace from the team's phi-OTDR simulation. One scene is rendered in two themes: **light** (printed report) and **dark**
(presentations).

> Status: `main_static` (approved, pushed as the first checkpoint) and `main_interactive` (new, pending approval).

## Run

```matlab
cd figure_digital_twin
main_static          % writes out/digital_twin_light.png and out/digital_twin_dark.png (8 x 5 in, 400 dpi)
```

The first run downloads the data listed below (several minutes, about 1 GB); later runs reuse it. Console output reports the
computed fibre length, number of interrogators and sensing points. Theme and all design parameters are in `config.m`
(`cfg.THEME`, `cfg.renderThemes`).

## FEBUS A1-NEO settings

The interrogator is the **FEBUS A1-NEO** (datasheet rev. 20260618). All device, cost, power and design values live in
**`map_params.m`** (struct `m`); every other script reads from it (`config.m` just copies them). Outputs go to `results_febus/`
(the earlier EOSS-device figures stay in `out/`).
**To update a value, edit only the overrides block in `map_params.m`** (NaN = not received yet; a number replaces the default).

| Symbol (Sheet) | Value | Unit | Tag |
| --- | --- | --- | --- |
| R_DAS | 20 000 | m | [DATASHEET] 20 km option, 0.2 dB/km (70/100 km exist; 100 km needs LR option) |
| N_ch_DAS | 4 | - | [DATASHEET] synchronous channels |
| N_ch_active | 2 | - | [DERIVED: two directions along the boundary] |
| N_ch_spare | 2 | - | [DERIVED] = N_ch_DAS - N_ch_active |
| P_DAS | 170 | W | [DATASHEET] |
| dz_res | 10 | m | [SIM SETTING] same as DAS-Simulation |
| dz_samp | 2 | m | [SIM SETTING] channel spacing |
| L_leadin | 0 | m | [ASSUMED: shelter on boundary; edit when site known]; counted in every channel's fibre length and in the assert |
| P_shelter | TBD | W | [TBD: AC power per shelter] |
| T_op_max | 40 | degC | [DATASHEET] |
| C_DAS_int | TBD | currency / unit | [TBD: vendor quote] |
| C_fiber | TBD | currency / km | [TBD: Saudi source]; the repo had no previous cost value |
| L_boundary | 145 473.5 | m | [COMPUTED-MAP] haversine length of `data/boundary_perimeter.csv` (Haram + Arafat union, provisional) |

```
N_DAS_int   = ceil( L_boundary / (N_ch_active * R_DAS) )           = ceil(145.47 / 40) = 4
P_DAS_total = N_DAS_int * P_DAS                                      = 680 W
C_DAS_total = N_DAS_int * C_DAS_int + (L_boundary/1e3) * C_fiber     (C_fiber per km)
P_total     = P_DAS_total + N_DAS_int * P_shelter                    (P_shelter TBD -> reported as incomplete)
channel fibre = L_leadin + sensing length  <=  R_DAS   (assert; margin per channel is printed)
```
Missing terms never produce a silent NaN: `map_params('report')` prints `<symbol> = TBD (<owner>)` and the total twice
(known terms only / missing terms). Zone symbols (`R_hot`, `lambda_*`, ...), CCTV / drone / point-sensor and `Pd_*`/`Pc_*` values are not in this repo; they are TBD overrides.

**Shelter note:** max operating temperature is 40 degC, so the interrogators must be housed in air-conditioned shelters; only the cable is in the field.

**Why coverage = 2 x R_DAS, not 4 x R_DAS:** a site on a linear/closed boundary can only serve two directions (channel 1 one way, channel 2 the other).
Channels 3-4 could only reach further boundary through lead-in fibre, which counts against the 20 km range, so they add no coverage. They are
marked as **spare (redundancy / possible double coverage in Hot zones)** on the map legend and carry no sensing segment (`m.N_ch_spare`).
The first version assumed 4 segments per site (N = 2); that needed up to 30.4 km of fibre per channel, so it was rejected.

**Placement:** `compute_fibre.m` splits the ring into N equal arcs, puts each site on the boundary at the middle of its arc (lead-in 0)
and gives it two sensing channels of half an arc each. An `assert` fails if any channel's lead-in + sensing fibre exceeds R_DAS; if it
would, sites are added until it passes and the extra count is reported (`m.N_DAS_int_extra`). Result: 4 sites, 8 channels of 18.18 km each.
`results_febus/placement_plan.png` shows it. Lead-in from a shelter to the boundary is not modelled (sites are on the boundary).

**Trace panel:** the map's trace panel is now the analytic backscatter of ONE channel (length = actual channel fibre length, 18.18 km), from
`backscatter_power.m` and the parameters in `map_params.m` (P0 = 0.1 W [ASSUMED: Thevenaz 2025], R_bs = -82 dB [ASSUMED: Corning SMF-28 Ultra PI-1424],
n_g = 1.4682 [ASSUMED: Corning], alpha = 0.2 dB/km [DATASHEET], tau = 2 n_g dz_res / c = 97.9 ns). Check: 61.8 nW at z = 0, 9.8 nW at 20 km.
The event hot spots, the dashed "simulated section" and the walking/vehicle labels on the 3D map still come from the OLD 10 km simulation (re-import pending).

`main_static` also writes `results_febus/sheet_values.csv` (Sheet columns Symbol ... Status), figures (png 300 dpi + pdf) and `placement_plan`.

## Zones

`main_zones` classifies the boundary into Hot / Neutral / Cold cells and produces these Sheet values: `cell_size`, `R_hot`, `R_cold`, per-cell lambda and
the number of cells per zone. Every decision is a parameter in `map_params.m` with a tag, so it can be changed in one line. Outputs are in `results_zones/`
(`cells.csv`, `zone_cells_map`, `risk_histogram`, `sensitivity.csv`) and the zone rows of `results_febus/sheet_values.csv`.

**Method**
1. **Grid:** square cells of side `cell_size` on a local metric projection; only cells crossed by the boundary are kept (intrusions are detected and stopped at the boundary). The boundary length per cell is accumulated on a 5 m densified line. **Small edge cells are merged:** a cell whose boundary length is < `min_cell_frac` (25%) of `cell_size` is merged into the neighbour along the boundary line that continues it (the previous or next cell on the boundary with the longer boundary share, repeated until none is left); the merged cell's length is the sum and its risk is the P90 over the DEM points of both squares (merged cells are outlined in the map).
2. **Intrinsic risk** (terrain + roads only, **no CCTV visibility term**: camera placement is an optimisation output, so using it would be circular): `risk = w_slope*slope_norm + w_road*road_dist_norm` on the 30 m DEM grid, smoothed like the figure's risk. The weights are the figure's (0.40 / 0.25) renormalised to sum 1 (0.615 / 0.385). The figure's own risk (with CCTV) is unchanged.
3. **Cell risk** = 90th percentile of the grid risk values inside the cell (the intruder picks the easiest point; P90 is robust to single outliers).
4. **Thresholds:** k-means (k = 3, fixed seed, 50 replicates) on cell risk; `R_cold` = midpoint of the low and middle centres, `R_hot` = midpoint of the middle and high centres. Cold < R_cold <= Neutral < R_hot <= Hot. The thresholds come from the data distribution, not from imposed shares.
5. **Per-cell lambda:** the Sheet lambda is per ZONE per day; it is spread over the cells of the zone in proportion to cell risk, `lambda_cell = lambda_zone * (risk_cell * len_cell) / sum(risk * len over the zone's cells)` (risk AND boundary length in the cell), so the total does not change with `cell_size`; the per-zone sums of min / mid / max equal the zone lambda (checked in the code, error otherwise). `cells.csv` gives min / mid / max (the Monte Carlo will draw the zone lambda uniformly from its range).

**Parameters (`map_params.m`)**

| Parameter | Value | Tag |
| --- | --- | --- |
| cell_size | 1000 m | [CHOSEN: >= Cov_CCTV (100 m, ~10 cameras per cell), >> DAS resolution (10 m); drones (11 km radius) are a shared resource across many cells] |
| cell_size_sens | 500 / 1000 / 2000 m | [CHOSEN: sensitivity runs] |
| zone_w (slope, road) | 0.615 / 0.385 | [ASSUMED: design; to be replaced by Student 3 Risk Matrix] |
| cell_risk_pct | 90 | [CHOSEN] |
| min_cell_frac | 0.25 | [CHOSEN] cells with boundary < 25% of cell_size are merged |
| zone_k, replicates, seed | 3, 50, 20261101 | [CHOSEN] / [SIM SETTING] |
| lambda_hot / neutral / cold range | 11-20 / 8-10 / 0-0 events/day per zone | [SHEET: team assumption] |

Values taken from the team Sheet are tagged `[SHEET: Student 2]` (CCTV: Cov 100 m, C 1900.90 SAR, P 20 W, Pd 0.909, Pc 0.85; drone, all "proposal": Cov 11 km radius, T 47 min, C 148887 SAR, P 1500 W, Pd 0.885) or `[SHEET: project target, approved]` (AD0 = AC0 = 0.98).
`C_DAS_int` = 150000 EUR (vendor meeting, Student 2) x 4.24 SAR/EUR [ASSUMED: interbank rate 15 Oct 2026; update] = 636000 SAR.
**Not taken (left TBD):** `C_fiber` (flagged doubtful by the team), FAR (two conflicting Sheet entries), the Sheet `f_s = 100 kHz` (a pulse-repetition rate, a different quantity from our 51 MHz spatial sampling) and the point-sensor values.

**Results (cell_size = 1 km, after merging)**: 154 squares are crossed by the boundary, 15 of them have < 25% of the cell size as boundary and are merged, giving 139 cells.

| | Hot | Neutral | Cold | Total |
| --- | --- | --- | --- | --- |
| cells | 36 | 56 | 47 | 139 |
| boundary (km) | 39.4 | 59.0 | 47.1 | 145.5 |

`R_cold` = 0.263, `R_hot` = 0.464 (k-means centres 0.146 / 0.379 / 0.549). Per-cell lambda (mid): Hot mean 0.43, max 0.91 events/day; Neutral mean 0.16, max 0.34; Cold 0.

| cell_size | squares | merged | cells | Hot / Neutral / Cold | R_hot | R_cold |
| --- | --- | --- | --- | --- | --- | --- |
| 500 m | 325 | 36 | 289 | 81 / 113 / 95 | 0.440 | 0.235 |
| 1000 m | 154 | 15 | 139 | 36 / 56 / 47 | 0.464 | 0.263 |
| 2000 m | 74 | 5 | 69 | 26 / 21 / 22 | 0.460 | 0.282 |

Sheet status: values taken from the Sheet are marked "Preliminary" in `sheet_values.csv` (the Sheet gives no approved status for them); AD0 / AC0 are "Approved".

**Limitations**
- The zoning weights are assumed (design) until Student 3's Risk Matrix replaces them.
- The risk score is a proxy for intrusion frequency; there is no historical intrusion data.
- The Arafat part of the boundary is provisional (OSM administrative district), so cells and zone lengths there may change.
- `lambda_cold_range = [0 0]`: Cold cells never get simulated intrusions, so performance in Cold zones cannot be evaluated (`main_zones` prints a WARNING; the value is not changed).
- k-means with k = 3 always returns three zones, whatever the shape of the distribution (the histogram shows no clear gap at the R_cold threshold).

## Interactive version and video

```matlab
main_interactive                                   % interactive window (same scene and config as main_static)
main_interactive('theme','light')                  % start in the light theme
main_interactive('video','out/digital_twin_animation.mp4')   % 1920x1080 MP4, no window (about 15-25 min)
```

Controls (top bar): **Map** satellite / dark, **Theme** dark / light, **Zoom to Mashaer** (or click the Mashaer frame or the terrain
inside it), **Reset view**, **Pause / Play**, **Restart**. The animation loops: light pulses travel along the fibre from each
interrogator, UAVs hover, an intruder walks to the perimeter, the fibre turns red at detection, the label builds up
"detected -> human -> ALARM", the response lines appear and the nearest UAV and patrol move in; then a vehicle drives along its road
and is detected, classified (vehicle on road) and logged. Detection is the simulated threshold crossing; classification and alarm are the
**proposed** AI step and are not simulated (marked with a dagger). The MP4 (not tracked in git, see `.gitignore`) plays on any computer.

Options: `'size'` [w h], `'fps'`, `'duration'`, `'texScale'` (texture resolution, default 0.5 for speed), `'meshStride'` (terrain decimation, default 2).
The interactive window needs the same toolboxes and data as `main_static` (below) plus a desktop MATLAB session (for the window); the MP4 mode
renders off-screen.

## Requirements

- MATLAB **R2026a** (tested with Update 5 on Windows 11). Earlier releases are untested.
- Toolboxes: **Mapping Toolbox** (`readgeoraster`, `geotiffwrite`, `georefpostings`, `viewshed`),
  **Image Processing Toolbox** (`imdilate`, `imerode`, `bwdist`, `imgaussfilt`),
  **Statistics and Machine Learning Toolbox** (`knnsearch`, `pdist2`).
- Internet access on the first run. Free access to the Overpass API (OpenStreetMap), the Copernicus DEM bucket on AWS and the
  Esri World Imagery export service is assumed; the Esri terms still need to be confirmed for the report (see `data/SOURCES.md`).

## Data (not in git)

| Data | Where it comes from | Created by | Local path |
| --- | --- | --- | --- |
| Copernicus DEM GLO-30 tiles N21 E039 / E040 (about 80 MB) | AWS open data `copernicus-dem-30m` | `prepare_terrain.m` | `data/dem/` |
| Satellite textures (about 20 MB and 40 MB) | Esri World Imagery export | `prepare_terrain.m` | `data/dem/` |
| Cropped DEM `dem_aoi.mat` | derived from the tiles | `prepare_terrain.m` | `data/dem/` |

Small data files **are** tracked: `data/boundary_*.csv`, `data/holy_sites.csv`, the OSM relation / road JSON files, `data/roads_osm.mat`
and `data/das_sim/das_sim_main_default.mat`. Sources, licences, attribution wording, assumptions and the list of items removed
because they could not be verified are in **`data/SOURCES.md`**; read it before reusing any data.

The DAS trace comes from the `main.m` default run of https://github.com/aljoudm/DAS-Simulation (commit e6120c8);
`data/import_das_sim.m` converts its `results/results.mat` into `data/das_sim/das_sim_main_default.mat` (already included).

Data files the interactive version reads (all created automatically on first run, same as `main_static`): `data/dem/dem_aoi.mat`, `data/dem/tex_base.jpg`, `data/dem/tex_mashaer.jpg`, `data/dem/tex_meta.mat`, `data/boundary_perimeter.csv`, `data/roads_osm.mat`, `data/holy_sites.csv`, `data/das_sim/das_sim_main_default.mat`.

## Layout

```
main_static.m          entry script: fetch/prepare data, build the scene once, render both themes (report figure)
main_interactive.m     entry script: interactive window + animation + MP4 export (same scene and config)
config.m               all parameters and the palette (single source of truth)
get_theme.m            light / dark colours for everything outside the imagery
build_scene.m          scene: fibre, assets, risk, events, UAVs, inset rectangle
compute_*.m            fibre length / N_IU, assets, weak-coverage risk
choose_inset_rect.m    searches the Mashaer rectangle that keeps clear of icons
render_figure.m        composes the static figure (map, inset, panels, legend)
draw_status/trace/legend.m, north_arrow.m, panel_axes.m   panels shared by the static and the interactive version
draw_*.m, halo_text.m  drawing layers
data/                  small data, fetch scripts, SOURCES.md
out/                   approved figures, LaTeX caption snippet, BibTeX
```

## Outputs

`out/digital_twin_light.png`, `out/digital_twin_dark.png`, `out/figure_snippet.tex` (figure + caption to paste into the report),
`out/references_additions.bib`.


##Aother:
Aljoud Almousa 
