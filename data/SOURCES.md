# Data sources

| File | Source | Retrieved | Notes |
| --- | --- | --- | --- |
| `haram_relation_19590020.json`, `boundary_haram_osm.csv` | OpenStreetMap relation 19590020 "Al Haram Al Makki" (boundary=protected_area), via Overpass API. ODbL. | 2026-11-01 | Two outer ways chained into one closed ring (3478 vertices). The relation's own `source` tag reads (verbatim): "أعلام وحدود الحرم المكي الشريف - خضران الثبيتي & سعود الثبيتي (1433هـ / 2012م) - https://archive.org/details/20230127_20230127_1703/mode/2up". The book is not cited in the report because its year, publisher and author spelling could not be verified (archive.org shows only an upload record). Enclosed area computed = 558 km², consistent with ~556 km² (Attar & Dhieb). **Cite OSM contributors; verify the polygon against Bawazir et al. (2025) before final submission.** |

Pending: DEM (Copernicus GLO-30), OSM road network, Hajj-entry restriction official source, DAS trace from `aljoudm/DAS-Simulation`.

## Design assumptions (config.m)
- Reference device: EOSS DAS interrogator (datasheet ED_PD010, rev 1.0; table values for the 'DAS' variant: 70 km per channel, 1 built-in channel (2 optional), spatial resolution setting 2.5-30 m); chosen spatial resolution 20 m (assumption within that range). N_IU = ceil(145.5 km / (70 km x 1 channel)) = 3.
- `SLACK_FACTOR = 1.00` (no extra cable length added). Note: L = 139.0 km vs 2 x 70 km = 140 km, so any slack above ~0.7% raises N_IU from 2 to 3.
- Vibration energy along the fibre is a seeded placeholder until the phi-OTDR simulation is wired in.

## Added 2026-11-01 (3D scene)

| File | Source | Notes |
| --- | --- | --- |
| `mashaer_rel_19262645.json`, `boundary_perimeter.csv` | OpenStreetMap relation 19262645 "Al Mashaeir Al Muqadasa" (admin_level 10, 14 outer ways), via Overpass. ODbL. | **Method:** polygon union (`polyshape`) of the Haram ring and this Holy Sites polygon -> one continuous Haram + Arafat boundary. **PROVISIONAL:** an OSM administrative district, not an official Hajj restricted-zone line. Not digitised by hand. Alternatives checked and rejected: way 1377422823 "Arafat" (37-node religious landuse polygon, covers only the built-up core of the plain). Result: L = 145.5 km, area 590 km2, N_IU = 3. |
| `holy_sites.csv` | OSM nodes/ways/relations listed in the file's `osm_ref` column. | Label offsets (`dx,dy,dz`) are display values only. |
| `dem/dem_aoi.mat` (from `Copernicus_DSM_COG_10_N21_00_E039/E040_00_DEM.tif`) | Copernicus DEM GLO-30, AWS Open Data bucket `copernicus-dem-30m`. | 1 arc-second. Page: Copernicus DEM - Global and European Digital Elevation Model, DOI https://doi.org/10.5270/ESA-c5d3d65 (checked 2026-11-01). Wording the page gives for ADAPTED GLO-30 data (our crop/resampling counts as adapted): "produced using Copernicus WorldDEM-30 (c) DLR e.V. 2010-2014 and (c) Airbus Defence and Space GmbH 2014-2018 provided under COPERNICUS by the European Union and ESA; all rights reserved". Licence terms: the page refers to the "ESA User License"; not summarised here. Note: DSM (includes buildings). |
| `dem/tex_base.jpg` (~6 m/px), `dem/tex_mashaer.jpg` (~1.8 m/px) | Esri World Imagery, `server.arcgisonline.com/.../World_Imagery/MapServer/export` | Service copyright text: "Source: Esri, Vantor, Earthstar Geographics, and the GIS User Community". The Esri static-map terms page (doc.arcgis.com/en/arcgis-online/reference/static-maps.htm, checked 2026-11-01) lists academic publications as a permitted use with attribution and gives the caption "Map image is the intellectual property of Esri and is used herein under license. Copyright (c) 2025 Esri and its licensors. All rights reserved.", telling users to set the year to that of their publication (2026 here). The page does not name World Imagery, so **whether it covers this export is still to be confirmed with Esri or the university**. |

## Design assumptions in the 3D scene (not facts)
- Vertical exaggeration 2x; UAV altitude, cone size and IU pole height are display values, not to scale.
- Event positions come from a DEM ruggedness placeholder (smoothed slope), to be replaced by the step-3 risk score.
- Fibre energy is a seeded placeholder with an intruder peak above and an animal bump below the 0.60 threshold; to be replaced by the phi-OTDR simulation.
- Fibre is drawn smoothed over ~300 m and lifted above ridges for display; L and N_IU use the raw polygon.

## Added 2026-11-01 (risk, assets, panels)

| File | Source | Notes |
| --- | --- | --- |
| `roads_osm.json`, `roads_osm.mat` | OpenStreetMap ways with highway = motorway, trunk, primary, secondary, tertiary and their links, bounding box of the terrain AOI, via Overpass. ODbL. | Used for the road-distance term of the risk score, for road entry points and for patrol positions. |
| (computed) road entry points | Crossings of motorway/trunk/primary roads with the perimeter, merged within 1.5 km. | Stand in for the checkpoints / boundary markers at road entrances (Bawazir et al. 2025). **Real checkpoint sites are not sourced**; labelled illustrative. |

## Risk method (computed, `compute_risk.m`)
`risk = 0.40*slope_norm + 0.35*not_visible + 0.25*road_dist_norm`, evaluated on the 30 m DEM grid inside +/-2 km of the fibre, then smoothed (sigma ~ 180 m).
- slope_norm = slope / 40 deg (capped at 1), from Copernicus GLO-30 (DSM).
- not_visible = not seen by any CCTV: viewshed from the DEM, camera mast 8 m, target height 1.7 m, range 1.4 km, **omnidirectional** (the displayed wedges are not used as a visibility mask).
- road_dist_norm = distance to the nearest road / 3 km (capped at 1).
- Weights, 40 deg, 3 km, mast height, range and the 0.30 display threshold are **design assumptions** (config.m).
- The intruder is placed at the fibre point with the highest 1 km-averaged risk (at least a quarter of an IU span from any IU).

## Illustrative values on the figure (marked with a dagger)
16 CCTV, 3 UAVs, 5 patrols, C2 at the perimeter centroid, intruder classification "human, 94%", CCTV range/field of view, UAV altitude and cone. Fibre energy and the DAS trace are a seeded placeholder until the phi-OTDR simulation is connected.

## Facts used on the figure
Hajj 2026 pilgrims 1,707,301 (GASTAT, Hajj Statistics Report 1447H). Fibre length, N_IU, sensing points and area are computed (see above).

## Added 2026-11-01 (review 4): phi-OTDR trace, directional risk, removals

### DAS trace panel (replaces the illustrative signal)
- Source: github.com/aljoudm/DAS-Simulation, commit e6120c8c024069bbb232f04daab9ff28a0bf8769 (2026-10-18), script `main.m`, default `src/params.m`.
- Parameters actually used (read from `results/results.mat`, `P`): fibre 10 km, pulse width 100 ns (10.2 m resolution), PRF 1 kHz, 2000 pulses (2 s), detector SNR 30 dB at the fibre start, gauge length 20 m, seed 42. Events from `src/define_events.m`: sine 100 Hz at 2 km (calibration), walking at 4 km, digging at 6 km, vehicle at 8 km.
- `main.m` was re-run on this machine; the regenerated `act_profile` was identical to the committed one (max difference 0 nm). The imported file is `data/das_sim/das_sim_main_default.mat` (made by `data/import_das_sim.m`); nothing was altered or generated except the threshold line.
- Plotted quantity: `R.act`, activity (nm rms, components above ~5 Hz) along the 10 km section; peaks in nm: sine 20.6, walking 9.3, digging 11.5, vehicle 12.2; median background 1.96 nm.
- Threshold: the simulator's own rule in `das_app.m` (lines 545-547): `median(a) + 8*1.4826*MAD(a)` = 7.23 nm. All four events exceed it, so the simulator detects all of them. **The simulator has no animal event and no human / non-human classifier**; the figure therefore uses the vehicle (non-human) as the "logged, no alarm" example, and the classification itself is part of the proposed system, not simulated.
- On the map the fibre colour uses the same numbers: quiet level = simulated median background, walking and vehicle peaks = their simulated peaks, colour scale reference = 12.2 nm (largest field event). The hot-spot width (sigma 0.8 km) is a display widening; the simulated events are about 30 m wide. The 10 km simulated section is NOT the 145.5 km fibre.

### Directional CCTV (risk model and drawing now use the same model)
Each camera: position on the perimeter (proposed placement), heading = outward normal, field of view 100 deg, range 1.4 km, mast 8 m, target height 1.7 m. A cell counts as covered only if it is inside the wedge AND visible in the DEM viewshed. All of these are design assumptions (config.m). RESULT under these assumptions (printed by `main_static`, never shown on the figure or in the caption): in the +/-2 km corridor around the fibre about 97 % of cells are not covered by any camera, and about 22 % of cells have a risk score above 0.6. This is a consequence of the assumed numbers (16 cameras, 1.4 km range, 100 deg field of view, 2 km corridor, 8 m mast), not a finding about real coverage; with different assumptions it changes.

### Removed because they could not be fully verified
- BibTeX `thubaiti2012haram`: year, publisher and author-name spelling unverified (archive.org holds only an upload record whose "creator" is the uploader).
- The "94 %" classification confidence: an invented value.
- The earlier unmodified-data DEM attribution wording (replaced by the verified adapted-data wording above).
- The "animal" event and the random baseline texture on the fibre: not in the simulator output.

## Added 2026-11-01 (review 5)

### Pilgrim count (fact on the status panel)
GASTAT news item "GASTAT: Total number of pilgrims for Hajj 2026 reaches (1,707,301)", published 26 May 2026, General Authority for Statistics, https://stats.gov.sa/en/w/news/194 (fetched 2026-11-01; the page states that the total number of pilgrims during 2026 reached 1,707,301). BibTeX key `gastat2026hajjnews`.

### How the simulated trace maps to the map (all stated on the figure and in the caption)
- Simulated section: 10 km (`main.m`). Its distance axis is laid on the fibre so that the **walking** event (4 km) sits at the intruder (highest-risk fibre point) and the **vehicle** event (8 km) sits 4 km further along the fibre, i.e. the same spacing as in the simulation. The section is drawn as a dashed corridor on the fibre ("simulated section").
- The vehicle marker is snapped to the nearest major road vertex (OSM); the fibre point of the vehicle hot spot is within 146 m of that road, and the road is highlighted on the map.
- Not placed on the map: the simulated **digging** event and the **calibration sine** (neutral grey in the trace, explained under the plot).
- "Detected -> human -> ALARM" and "detected -> vehicle on road -> logged": detection = activity above the simulator's threshold (simulated); classification and alarm = proposed AI classifier of the system (**not simulated**, marked with a dagger).
- Hot-spot widths on the fibre are widened for visibility (simulated events are ~30 m wide).

### Reference interrogator datasheet (verified against the PDF on 2026-11-01)
File: https://asean.prysmian.com/sites/asean.prysmian.com/files/media/documents/Prysmian_DAS.pdf (4 pages; pages rendered and read).
- Printed title: "DAS - Distributed Acoustic Sensing Interrogator"; page 4: "ED_PD010 Datasheet DAS", Revision 1.0, Release Date 04/08/2026 (as printed; day/month order not stated).
- Publisher as printed: "This document is a publication of EOSS" - EOSS s.r.l., Via Chiese 6, 20216 Milano, Italy; the page footer gives prysmian.com. **The document is not branded Prysmian**; it is hosted on Prysmian's ASEAN site. Any corporate relationship between EOSS and Prysmian is not stated in it and is not claimed here.
- Page 3 specification table: distance range (per channel) 70 km for "DAS" (optical budget @1550 nm: 14 dB) and 100 km for "DAS-TL" (19 dB); optical channels (built-in): DAS 1 channel (2 optional), DAS-TL 1 channel; spatial resolution (setting) 2.5-30 m; sampling rate up to 2 kHz; acoustic bandwidth up to 1 kHz (both "specified on a project basis"). Perimeter security is listed as an application.
- Inconsistency inside the datasheet: the key-features box on page 2 says "2 built-in simultaneous measurement channels" and "up to 100 km", while the table says 1 channel (2 optional) for DAS. The table values for the DAS variant are used (70 km, 1 channel).
- The project brief called this device "Prysmian DAS" and listed author "Prysmian"; both were incorrect for the document as printed, so the BibTeX key/author were changed (`eoss_das_datasheet`, author EOSS s.r.l.).

## FEBUS A1-NEO update (branch febus-a1neo)
The reference device is now the FEBUS A1-NEO (datasheet rev. 20260618): 20 km per channel, 4 channels, 170 W, 10 m resolution, 2 m channel spacing (see `map_params.m`). The EOSS statements above (70 km, 1 channel, 20 m, N_IU = 3) describe the previous device and are kept for history. The imported phi-OTDR trace (`data/das_sim/`) is still the OLD simulation (10 km, 100 ns pulse); re-import from DAS-Simulation branch `febus-a1neo` is pending.
