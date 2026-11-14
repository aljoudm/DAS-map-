function T = export_sheet_values(m, outDir)
% EXPORT_SHEET_VALUES  Write results_febus/sheet_values.csv (UTF-8 with BOM, Excel-compatible) and print the same table.
% Columns: Symbol | Description | Explanation | Value | Unit | Source | Owner | Status   (Status: Final | Assumed | TBD)
% Only the team Sheet's symbols are exported. N_DAS_int, P_DAS_total, C_DAS_total are printed by map_params('report') and
% in the README but are NOT Sheet symbols (C_total is the sum of all component costs, so it stays TBD here).
if ~exist(outDir, 'dir'), mkdir(outDir); end
own2 = 'Student 2';  ownZ = 'DAS-map zones (WIP)';  me = 'DAS-map (this repo)';
R = {
 'L_boundary','Boundary length','Length of the Haram + Arafat boundary fibre route (haversine sum over the OSM polygon union; provisional Arafat part)', m.L_boundary,'m','[COMPUTED-MAP] data/boundary_perimeter.csv (OSM rel. 19590020 + 19262645)',me,'Assumed'
 'R_DAS','DAS range per channel','FEBUS A1-NEO range per channel, 20 km option (0.2 dB/km)', m.R_DAS,'m','[DATASHEET] FEBUS A1-NEO rev. 20260618',me,'Final'
 'P_DAS','DAS interrogator power','Power per FEBUS A1-NEO interrogator', m.P_DAS,'W','[DATASHEET] FEBUS A1-NEO rev. 20260618',me,'Final'
 'C_DAS_int','Interrogator cost','Price of one interrogator (not in datasheet)', m.C_DAS_int,'currency TBD per unit','[TBD: vendor quote]','Vendor / team','TBD'
 'C_fiber','Fibre cost','Fibre cable cost per km of route (formula uses L in km)', m.C_fiber,'currency TBD per km','[TBD: Saudi source]','Team','TBD'
 'Pd_DAS','DAS detection probability','Probability of detecting an intrusion with DAS', m.Pd_DAS,'-','[TBD: DAS-Simulation]','DAS-Simulation','TBD'
 'Pc_DAS','DAS classification probability','Probability of correct classification (DL classifier)', m.Pc_DAS,'-','[TBD: Simulation A (DL classifier)]','Simulation A (DL classifier)','TBD'
 'C_CCTV','CCTV cost','Cost per CCTV unit', m.C_CCTV,'currency TBD','[TBD: Student 2]',own2,'TBD'
 'Cov_CCTV','CCTV coverage','Coverage of one CCTV unit (this repo draws an ILLUSTRATIVE 1.4 km / 100 deg wedge, not a Sheet value)', m.Cov_CCTV,'TBD','[TBD: Student 2]',own2,'TBD'
 'P_CCTV','CCTV power','Power per CCTV unit', m.P_CCTV,'W','[TBD: Student 2]',own2,'TBD'
 'Pd_CCTV','CCTV detection probability','Detection probability of CCTV', m.Pd_CCTV,'-','[TBD: Student 2]',own2,'TBD'
 'Pc_CCTV','CCTV classification probability','Classification probability of CCTV', m.Pc_CCTV,'-','[TBD: Student 2]',own2,'TBD'
 'C_drone','Drone cost','Cost per drone', m.C_drone,'currency TBD','[TBD: Student 2]',own2,'TBD'
 'Cov_drone','Drone coverage','Coverage of one drone', m.Cov_drone,'TBD','[TBD: Student 2]',own2,'TBD'
 'P_drone','Drone power','Power per drone', m.P_drone,'W','[TBD: Student 2]',own2,'TBD'
 'T_drone','Drone flight time','Endurance of one drone', m.T_drone,'min','[TBD: Student 2]',own2,'TBD'
 'Pd_drone','Drone detection probability','Detection probability of a drone', m.Pd_drone,'-','[TBD: Student 2]',own2,'TBD'
 'C_PS','Point-sensor cost','Cost per point sensor', m.C_PS,'currency TBD','[TBD: Student 2]',own2,'TBD'
 'Cov_PS','Point-sensor coverage','Coverage of one point sensor', m.Cov_PS,'TBD','[TBD: Student 2]',own2,'TBD'
 'P_PS','Point-sensor power','Power per point sensor', m.P_PS,'W','[TBD: Student 2]',own2,'TBD'
 'Pd_PS','Point-sensor detection probability','Detection probability of a point sensor', m.Pd_PS,'-','[TBD: Student 2]',own2,'TBD'
 'w_k','Zone weight','Zone weight (zones are work in progress, not in this repo)', m.w_k,'-','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'cell_size','Cell size','Zone cell size (work in progress)', m.cell_size,'m','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'R_hot','Hot-zone radius','Hot-zone criterion radius (work in progress)', m.R_hot,'m','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'R_cold','Cold-zone radius','Cold-zone criterion radius (work in progress)', m.R_cold,'m','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'lambda_hot','Hot-zone intrusion rate','Intrusion rate lambda in Hot cells (work in progress)', m.lambda_hot,'TBD','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'lambda_neutral','Neutral-zone intrusion rate','Intrusion rate lambda in Neutral cells (work in progress)', m.lambda_neutral,'TBD','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'lambda_cold','Cold-zone intrusion rate','Intrusion rate lambda in Cold cells (work in progress)', m.lambda_cold,'TBD','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'P_shelter','Shelter AC power','Air-conditioning power per interrogator shelter (interrogators max 40 degC)', m.P_shelter,'W','[TBD: AC power per shelter]','Team','TBD'
 'P_total','Total power','P_DAS_total + N_DAS_int * P_shelter (known part without shelters: see console / README)', m.P_total,'W','[DERIVED] needs P_shelter','Team','TBD'
 'C_total','Total cost','Sum of all component costs (DAS part: see README; needs C_DAS_int, C_fiber and the other components)', m.C_total,'currency TBD','[TBD: team]','Team','TBD'
};
T = cell2table(R, 'VariableNames', {'Symbol','Description','Explanation','Value','Unit','Source','Owner','Status'});
for i = 1:size(R, 1)
    v = R{i, 4};  if isnan(v), vs = 'TBD'; else, vs = sprintf('%.10g', v); end
    R{i, 4} = vs;
end
f = fullfile(outDir, 'sheet_values.csv');
fid = fopen(f, 'w', 'n', 'UTF-8');  fwrite(fid, char(65279), 'char');   % BOM so Excel reads UTF-8
fprintf(fid, 'Symbol,Description,Explanation,Value,Unit,Source,Owner,Status\n');
for i = 1:size(R, 1)
    fprintf(fid, '%s\n', strjoin(cellfun(@csvq, R(i, :), 'UniformOutput', false), ','));
end
fclose(fid);
fprintf('\nSheet values -> %s\n', f);
fprintf('%-15s %-14s %-24s %-9s %s\n', 'Symbol', 'Value', 'Unit', 'Status', 'Owner');
for i = 1:size(R, 1), fprintf('%-15s %-14s %-24s %-9s %s\n', R{i,1}, R{i,4}, R{i,5}, R{i,8}, R{i,7}); end
end

function s = csvq(x)
s = strrep(char(x), '"', '""');
s = ['"' s '"'];
end
