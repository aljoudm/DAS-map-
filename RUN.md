# How to run this project (step by step)

Project folder: `C:\Users\aljou\Downloads\DAS Map`

## 1. What you need
- **MATLAB R2026a** (tested with Update 5 on Windows 11).
- These toolboxes (check with `ver` in the MATLAB Command Window):
  **Mapping Toolbox**, **Image Processing Toolbox**, **Statistics and Machine Learning Toolbox**.
- Internet only if a data file is missing (see section 5). With the folder as it is, everything runs offline.

## 2. Open MATLAB in the project folder
1. Start MATLAB.
2. In the Command Window type exactly (keep the quotes, the folder name has a space):
   ```matlab
   cd('C:\Users\aljou\Downloads\DAS Map')
   ```
   You should see the files `main_static.m` and `main_interactive.m` in the Current Folder panel.

## 3. The figure for the report (static, light and dark)
```matlab
main_static
```
- Takes about 2 to 4 minutes. The Command Window prints fibre length (145.5 km), interrogators (3) and sensing points.
- Results appear in the `out` folder: `digital_twin_light.png` (use this one in the report) and `digital_twin_dark.png` (slides).
- The LaTeX caption is `out\figure_snippet.tex`, the references are `out\references_additions.bib`.

## 4. The interactive version
```matlab
main_interactive
```
- Opens a window (about 1 minute to build). The animation starts by itself and loops.
- Top bar: **Map** (Satellite / Dark), **Theme** (Dark / Light), **Zoom to Mashaer** (you can also click the Mashaer frame on the map),
  **Reset view**, **Pause / Play**, **Restart**.
- Start in the light theme: `main_interactive('theme','light')`.
- Close the window with the normal X button.

## 5. If a data file is missing
Every file below is created automatically the first time you run a script, so first just run `main_static` again with internet on.

| Missing file (in `data\` or `data\dem\`) | What to do |
| --- | --- |
| `dem\dem_aoi.mat`, `dem\*.tif` (terrain) | Run `main_static` (internet): it downloads the Copernicus DEM and rebuilds it. |
| `dem\tex_base.jpg`, `dem\tex_mashaer.jpg`, `dem\tex_meta.mat` (satellite images) | Run `prepare_terrain(true)` (internet): downloads Esri World Imagery again (about 5-10 minutes). |
| `boundary_haram_osm.csv`, `boundary_perimeter.csv`, `roads_osm.mat` | Run `main_static` (internet): re-fetched from OpenStreetMap. |
| `das_sim\das_sim_main_default.mat` (DAS simulation trace) | Cannot be downloaded by the script. Clone https://github.com/aljoudm/DAS-Simulation (commit e6120c8), run its `main.m`, then in MATLAB: `import_das_sim('<path to that clone>', 'e6120c8c024069bbb232f04daab9ff28a0bf8769')`. |
| `holy_sites.csv` | Tracked in git: restore it with `git checkout data/holy_sites.csv`. |

If MATLAB says a function is "undefined" (for example `viewshed` or `knnsearch`), a toolbox from section 1 is missing.
If MATLAB cannot find a script, you are in the wrong folder: repeat the `cd(...)` command from section 2.

## 6. Where things are
- `README.md`: overview of the code. `data\SOURCES.md`: every data source, assumption and item removed because it could not be verified.
- `sources\`: downloaded copies of the cited sources (not in git, see `sources\INDEX.md`).
- `config.m`: all parameters (theme, camera, counts, colours) in one place.
