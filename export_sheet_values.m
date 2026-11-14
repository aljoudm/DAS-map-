function T = export_sheet_values(m, outDir)
% EXPORT_SHEET_VALUES  Write results_febus/sheet_values.csv (UTF-8 with BOM, Excel-compatible) and print the same table.
% Columns: Symbol | Description | Explanation | Value | Unit | Source | Owner | Status   (Status: Final | Assumed | Provisional | Preliminary | TBD | Proposed - not yet in Sheet)
% The team Sheet's symbols are exported, plus 5 map results marked 'Proposed - not yet in Sheet' (N_DAS_int, N_ch_active,
% P_DAS_total, L_leadin, L_channel). C_DAS_total is printed by map_params('report') only (C_total is the sum of all components, TBD here).
if ~exist(outDir, 'dir'), mkdir(outDir); end
prop = ['Proposed ' char(8211) ' not yet in Sheet'];   % en dash built from its code point (keeps this file ASCII)
own2 = 'Student 2';  ownZ = 'DAS-map zones (WIP)';  me = 'DAS-map (this repo)';
R = {
 'L_boundary','Boundary length','Length of the Haram + Arafat boundary fibre route (haversine sum over the OSM polygon union); computed, but the Arafat part of the boundary is provisional', round(m.L_boundary, 1),'m','[COMPUTED-MAP] data/boundary_perimeter.csv (OSM rel. 19590020 + 19262645)',me,'Provisional'
 'R_DAS','DAS range per channel','FEBUS A1-NEO range per channel, 20 km option (0.2 dB/km)', m.R_DAS,'m','[DATASHEET] FEBUS A1-NEO rev. 20260618',me,'Final'
 'P_DAS','DAS interrogator power','Power per FEBUS A1-NEO interrogator', m.P_DAS,'W','[DATASHEET] FEBUS A1-NEO rev. 20260618',me,'Final'
 'C_DAS_int','Interrogator cost','Price of one interrogator (not in datasheet)', m.C_DAS_int,'SAR/unit','[TBD: vendor quote]','Vendor / team','TBD'
 'C_fiber','Fibre cost','Fibre cable cost per km of route (formula uses L in km)', m.C_fiber,'SAR/km','[TBD: Saudi source]','Team','TBD'
 'Pd_DAS','DAS detection probability','Detection probability of DAS, computed from simulated events vs detection threshold; threshold to be set from the FAR target (Student 1)', m.Pd_DAS,'-','[TBD: computed from simulation]','Simulation B (Monte Carlo using DAS-Simulation)','TBD'
 'Pc_DAS','DAS classification probability','Probability of correct classification (DL classifier)', m.Pc_DAS,'-','[TBD: Simulation A (DL classifier)]','Simulation A (DL classifier)','TBD'
 'C_CCTV','CCTV cost','Cost per CCTV unit', m.C_CCTV,'SAR','[TBD: Student 2]',own2,'TBD'
 'Cov_CCTV','CCTV coverage','Coverage of one CCTV unit (this repo draws an ILLUSTRATIVE 1.4 km / 100 deg wedge, not a Sheet value)', m.Cov_CCTV,'TBD','[TBD: Student 2]',own2,'TBD'
 'P_CCTV','CCTV power','Power per CCTV unit', m.P_CCTV,'W','[TBD: Student 2]',own2,'TBD'
 'Pd_CCTV','CCTV detection probability','Detection probability of CCTV', m.Pd_CCTV,'-','[TBD: Student 2]',own2,'TBD'
 'Pc_CCTV','CCTV classification probability','Classification probability of CCTV', m.Pc_CCTV,'-','[TBD: Student 2]',own2,'TBD'
 'C_drone','Drone cost','Cost per drone', m.C_drone,'SAR','[TBD: Student 2]',own2,'TBD'
 'Cov_drone','Drone coverage','Coverage of one drone', m.Cov_drone,'TBD','[TBD: Student 2]',own2,'TBD'
 'P_drone','Drone power','Power per drone', m.P_drone,'W','[TBD: Student 2]',own2,'TBD'
 'T_drone','Drone flight time','Endurance of one drone', m.T_drone,'min','[TBD: Student 2]',own2,'TBD'
 'Pd_drone','Drone detection probability','Detection probability of a drone', m.Pd_drone,'-','[TBD: Student 2]',own2,'TBD'
 'C_PS','Point-sensor cost','Cost per point sensor', m.C_PS,'SAR','[TBD: Student 2]',own2,'TBD'
 'Cov_PS','Point-sensor coverage','Coverage of one point sensor', m.Cov_PS,'TBD','[TBD: Student 2]',own2,'TBD'
 'P_PS','Point-sensor power','Power per point sensor', m.P_PS,'W','[TBD: Student 2]',own2,'TBD'
 'Pd_PS','Point-sensor detection probability','Detection probability of a point sensor', m.Pd_PS,'-','[TBD: Student 2]',own2,'TBD'
 'w_k','Decision Matrix weights','Weight of each criterion in the technology comparison (sum = 100%). Accuracy and coverage are weighted highest (national security and religious priority); cost is minimised only after accuracy is ensured', 'Acc 35 / Cov 25 / Env 15 / Cost 10 / Pwr 10 / Priv 5','%','Team decision, justified by requirements (AD0, AC0, P0)',own2,'Preliminary'
 'cell_size','Cell size','Zone cell size (work in progress)', m.cell_size,'m','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'R_hot','Hot-zone threshold','Threshold that classifies a cell as Hot / Cold (criterion still being defined in zones work)', m.R_hot,'TBD (depends on criterion)','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'R_cold','Cold-zone threshold','Threshold that classifies a cell as Hot / Cold (criterion still being defined in zones work)', m.R_cold,'TBD (depends on criterion)','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'lambda_hot','Hot-zone intrusion rate','Intrusion rate per cell used to generate random intrusion events (Monte Carlo)', m.lambda_hot,'events per cell per time unit (TBD)','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'lambda_neutral','Neutral-zone intrusion rate','Intrusion rate per cell used to generate random intrusion events (Monte Carlo)', m.lambda_neutral,'events per cell per time unit (TBD)','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'lambda_cold','Cold-zone intrusion rate','Intrusion rate per cell used to generate random intrusion events (Monte Carlo)', m.lambda_cold,'events per cell per time unit (TBD)','[TBD: DAS-map zones (WIP)]',ownZ,'TBD'
 'P_shelter','Shelter AC power','Air-conditioning power per interrogator shelter (interrogators max 40 degC)', m.P_shelter,'W','[TBD: AC power per shelter]','Team','TBD'
 'P_total','Total power','P_DAS_total + N_DAS_int * P_shelter (known part without shelters: see console / README)', m.P_total,'W','[DERIVED] needs P_shelter','Team','TBD'
 'N_DAS_int','Number of interrogators','PROPOSED new symbol: ceil(L_boundary / (N_ch_active * R_DAS)) + extra sites needed by the placement assert (extra = 0)', m.N_DAS_int,'-','[DERIVED]',me,prop
 'N_ch_active','Active channels per interrogator','PROPOSED new symbol: channels that carry a sensing segment (one per direction along the boundary); the other 2 of 4 are spare', m.N_ch_active,'-','[DERIVED: two directions along boundary]',me,prop
 'P_DAS_total','Total interrogator power','PROPOSED new symbol: N_DAS_int * P_DAS (without shelter air-conditioning)', m.P_DAS_total,'W','[DERIVED]',me,prop
 'L_leadin','Lead-in fibre','PROPOSED new symbol: fibre from the air-conditioned shelter to the boundary, counted in every channel length (assumed 0: shelter on the boundary)', m.L_leadin,'m','[ASSUMED: shelter on boundary]',me,prop
 'L_channel','Sensing length per channel','PROPOSED new symbol: sensing fibre per channel = L_boundary / (N_DAS_int * N_ch_active) (about 18.18 km, below R_DAS = 20 km)', round(m.L_fibre / (m.N_DAS_int * m.N_ch_active), 1),'m','[DERIVED]',me,prop
 'C_total','Total cost','Sum of all component costs (DAS part: see README; needs C_DAS_int, C_fiber and the other components)', m.C_total,'SAR','[TBD: team]','Team','TBD'
};
T = cell2table(R, 'VariableNames', {'Symbol','Description','Explanation','Value','Unit','Source','Owner','Status'});
for i = 1:size(R, 1)
    v = R{i, 4};  if ischar(v), vs = v; elseif isnan(v), vs = 'TBD'; else, vs = sprintf('%.10g', v); end
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
fprintf('%-15s %-30s %-36s %-28s %s\n', 'Symbol', 'Value', 'Unit', 'Status', 'Owner');
for i = 1:size(R, 1), fprintf('%-15s %-30s %-36s %-28s %s\n', R{i,1}, R{i,4}, R{i,5}, R{i,8}, R{i,7}); end
end

function s = csvq(x)
s = strrep(char(x), '"', '""');
s = ['"' s '"'];
end
