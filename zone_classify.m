function Z = zone_classify(m, ring, G, cs)
% ZONE_CLASSIFY  Square cells of side cs [m] crossed by the boundary; cell risk = P90 of the DEM-grid intrinsic risk inside the
% cell; k-means (k = 3) thresholds R_cold / R_hot; zone per cell; per-cell lambda (Sheet lambda is per ZONE per day, spread over
% the cells of the zone in proportion to cell risk). ring = [lat lon] closed boundary; G from intrinsic_risk_grid.
x = (ring(:,2) - G.lon0) * G.kx;   y = (ring(:,1) - G.lat0) * G.ky;
% --- densify the boundary and accumulate its length per cell (midpoint rule, error <= zone_step_m)
seg = hypot(diff(x), diff(y));   mx = []; my = []; ml = [];
for i = 1:numel(seg)
    n = max(ceil(seg(i) / m.zone_step_m), 1);   t = ((1:n)' - 0.5) / n;
    mx = [mx; x(i) + t * (x(i+1) - x(i))];  my = [my; y(i) + t * (y(i+1) - y(i))];  ml = [ml; repmat(seg(i) / n, n, 1)]; %#ok<AGROW>
end
x0 = floor(min([x; G.x(:)]) / cs) * cs;   y0 = floor(min([y; G.y(:)]) / cs) * cs;
NX = ceil((max([x; G.x(:)]) - x0) / cs) + 1;   NY = ceil((max([y; G.y(:)]) - y0) / cs) + 1;
cid = @(px, py) (floor((py - y0) / cs)) * NX + floor((px - x0) / cs) + 1;
bid = cid(mx, my);
Lc = accumarray(bid, ml, [NX * NY 1]);
kept = find(Lc > 0);   nk = numel(kept);                          % ONLY cells crossed by the boundary
cmap = zeros(NX * NY, 1);   cmap(kept) = 1:nk;
% --- cell risk: percentile of the pixel risk inside the cell
pidx = cmap(cid(G.x(:), G.y(:)));   ok = pidx > 0;
cellRisk = accumarray(pidx(ok), G.risk(ok), [nk 1], @(v) prctile(v, m.cell_risk_pct));
npx = accumarray(pidx(ok), 1, [nk 1]);
if any(npx == 0), error('zone_classify:nodem', '%d boundary cells have no DEM pixels.', nnz(npx == 0)); end
% --- k-means thresholds
rng(m.zone_seed);
[~, C] = kmeans(cellRisk, m.zone_k, 'Replicates', m.zone_kmeans_replicates, 'Start', 'plus');
C = sort(C(:));
Z.R_cold = mean(C(1:2));   Z.R_hot = mean(C(2:3));   Z.centres = C;
zone = ones(nk, 1);   zone(cellRisk >= Z.R_cold) = 2;   zone(cellRisk >= Z.R_hot) = 3;      % 1 Cold, 2 Neutral, 3 Hot
% --- per-cell lambda (events/day): zone lambda spread over the zone's cells in proportion to cell risk
rg = {m.lambda_cold_range, m.lambda_neutral_range, m.lambda_hot_range};
lam = zeros(nk, 3);                                                % columns: min, mid, max
for z = 1:3
    in = zone == z;   if ~any(in), continue; end
    lz = [rg{z}(1), mean(rg{z}), rg{z}(2)];
    share = cellRisk(in) / sum(cellRisk(in));
    lam(in, :) = share * lz;
end
cy = floor((kept - 1) / NX);   cx = (kept - 1) - cy * NX;           % cell column / row indices
Z.cs = cs;   Z.nCells = nk;   Z.x0 = x0;   Z.y0 = y0;
Z.cx_m = x0 + (cx + 0.5) * cs;   Z.cy_m = y0 + (cy + 0.5) * cs;      % cell centres [m]
Z.lat = G.lat0 + Z.cy_m / G.ky;   Z.lon = G.lon0 + Z.cx_m / G.kx;
Z.id = (1:nk)';   Z.Lc_m = Lc(kept);   Z.risk = cellRisk;   Z.zone = zone;   Z.lambda = lam;
Z.cameras = Z.Lc_m / m.Cov_CCTV;                                   % info only
Z.nZone = arrayfun(@(z) nnz(zone == z), 1:3);                       % [Cold Neutral Hot]
Z.kmZone = arrayfun(@(z) sum(Z.Lc_m(zone == z)) / 1e3, 1:3);
Z.L_total_km = sum(ml) / 1e3;
Z.lambdaZone = [rg{1}; rg{2}; rg{3}];                               % per zone [min max], events/day
end
