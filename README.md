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
