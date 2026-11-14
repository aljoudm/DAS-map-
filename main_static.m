% MAIN_STATIC  Static 3D digital-twin figure in BOTH themes (cfg.renderThemes) from ONE scene.
% Status goes to the console only. Outputs: out/digital_twin_light.png, out/digital_twin_dark.png.
here = fileparts(mfilename('fullpath'));
addpath(here, fullfile(here, 'data'));
cfg = config();
if ~exist(cfg.outDir, 'dir'), mkdir(cfg.outDir); end
fetch_boundary_osm();  build_perimeter();  prepare_terrain();  fetch_roads_osm();
if ~isfile(cfg.simFile), error('Run data/import_das_sim.m first (phi-OTDR simulator output, see SOURCES.md).'); end
scene = build_scene(cfg);   F = scene.fibre;

fprintf('Perimeter       : %s\n', F.source);
fprintf('Fibre length L  : %.1f km (SLACK_FACTOR=%.2f)   area %.0f km^2\n', F.L_km, cfg.SLACK_FACTOR, F.area_km2);
fprintf('N_IU            : %d (R_ch=%g km, n_ch=%d), %.1f km of boundary per IU; sensing points %d at %g m (channel samples %d at %g m)\n', ...
    F.N_IU, cfg.R_CH_KM, cfg.N_CH, F.iuSpanKm, F.N_sensing, cfg.SPATIAL_RES_M, F.N_samples, cfg.CH_SPACING_M);
fprintf('Segments        : %d, length %.2f-%.2f km, feeder %.2f-%.2f km, fibre per channel incl. feeder up to %.2f km (R_DAS %g km)\n', ...
    F.nSeg, min(F.segLenKm), max(F.segLenKm), min(F.segFeederKm), max(F.segFeederKm), max(F.segNeedKm), cfg.R_CH_KM);
map_params('report');
export_sheet_values(cfg.m, cfg.outDir);
plot_placement(cfg, scene.fibre);
for th = cfg.renderThemes
    [~, scene] = render_figure(scene, char(th));      % scene carries the cached inset calibration to the next theme
end
