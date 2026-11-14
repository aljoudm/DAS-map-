function fibre = compute_fibre(cfg)
% COMPUTE_FIBRE  Densify the boundary, compute length L, N_IU and IU placement.
if isfile(cfg.perimeterCsv)
    ring = readmatrix(cfg.perimeterCsv);  fibre.source = 'OSM Haram + Holy Sites union';
elseif isfile(cfg.boundaryCsv)
    ring = readmatrix(cfg.boundaryCsv);  fibre.source = 'OSM Haram only';
else
    warning('BOUNDARY:PLACEHOLDER', 'Using PLACEHOLDER boundary - not real data.');
    ring = readmatrix(cfg.placeholderCsv);  fibre.source = 'PLACEHOLDER';
end
if norm(ring(1,:) - ring(end,:)) > 1e-9, ring(end+1,:) = ring(1,:); end

R = 6371008.8;                                   % mean Earth radius [m]
seg = hav(ring(1:end-1,:), ring(2:end,:), R);    % segment lengths [m]
s0  = [0; cumsum(seg)];                          % cumulative distance along raw ring
Lgeo = s0(end);

% Densify at fixed arc-length step (linear in lat/lon; step << 1 km so error is negligible)
n  = max(ceil(Lgeo / cfg.DENSIFY_STEP_M), 2);
s  = linspace(0, Lgeo, n + 1)';
[s0u, iu] = unique(s0);
lat = interp1(s0u, ring(iu,1), s);
lon = interp1(s0u, ring(iu,2), s);

L_m  = Lgeo * cfg.SLACK_FACTOR;
fibre.lat = lat;  fibre.lon = lon;  fibre.s_m = s * cfg.SLACK_FACTOR;
fibre.L_geo_km    = Lgeo / 1e3;
fibre.L_km        = L_m / 1e3;
fibre.N_IU        = cfg.m.N_DAS_int;                  % = ceil(L / (N_ch x R_DAS)), computed in map_params.m
if abs(L_m - cfg.m.L_fibre) > 1, warning('L_boundary (map_params) differs from compute_fibre by %.1f m.', L_m - cfg.m.L_fibre); end
fibre.N_sensing   = round(L_m / cfg.SPATIAL_RES_M);   % sensing points = L / spatial resolution
fibre.N_samples   = round(L_m / cfg.CH_SPACING_M);    % channel samples = L / channel spacing

% Placement: the ring is split into N_IU equal arcs (one per interrogator); the site sits at the middle of its arc and
% serves N_ch segments (each arc/N_ch long): two run away from the site along the boundary in each direction.
% The two OUTER segments of a site start one segment-length away along the boundary, so a feeder fibre is needed:
% feeder = straight-line distance site -> the segment's near end (best case; real routing is >= this).
% Required fibre per channel = feeder + segment length; compared with R_DAS below.
N = fibre.N_IU;  nch = cfg.N_CH;  fibre.nSeg = N * nch;
at = @(u) 1 + mod(round(u * n), n);                       % index on the closed ring for arc fraction u (0..1)
site = zeros(N, 1);  sa = zeros(fibre.nSeg, 1);  sb = sa;  sSite = sa;  nearIdx = sa;  farIdx = sa;  dirn = sa;  feeder = sa;
for g = 1:N
    u0 = (g - 1) / N;  uS = u0 + 0.5 / N;  site(g) = at(uS);
    for j = 1:nch
        q = (g - 1) * nch + j;
        ua = u0 + (j - 1) / (N * nch);  ub = u0 + j / (N * nch);          % segment spans arc fractions [ua, ub]
        if (ua + ub) / 2 < uS, nearIdx(q) = at(ub); farIdx(q) = at(ua); dirn(q) = -1;   % left of the site: near end is ub
        else,                  nearIdx(q) = at(ua); farIdx(q) = at(ub); dirn(q) = +1; end
        sa(q) = ua * fibre.L_km;  sb(q) = ub * fibre.L_km;  sSite(q) = g;
        feeder(q) = hav([lat(site(g)) lon(site(g))], [lat(nearIdx(q)) lon(nearIdx(q))], R) / 1e3;   % [km]
    end
end
fibre.iuIdx = site;   fibre.iuLat = lat(site);  fibre.iuLon = lon(site);
fibre.iuSpanKm = fibre.L_km / N;                          % boundary length served by one interrogator
fibre.segSite = sSite;  fibre.segNearIdx = nearIdx;  fibre.segFarIdx = farIdx;  fibre.segDir = dirn;
fibre.segLenKm = (sb - sa);  fibre.segFeederKm = feeder;
fibre.segNeedKm = fibre.segLenKm + feeder;                % fibre per channel incl. the straight-line feeder
fibre.segOverRange = fibre.segNeedKm > cfg.R_CH_KM + 1e-9;
if any(fibre.segOverRange)
    warning('PLACEMENT:RANGE', ['%d of %d segments need more than R_DAS = %g km once the feeder from the site is counted ' ...
        '(max %.1f km). The N_DAS_int formula assumes each channel serves R_DAS of boundary starting AT the site.'], ...
        nnz(fibre.segOverRange), fibre.nSeg, cfg.R_CH_KM, max(fibre.segNeedKm));
end

% Enclosed area (planar, equal-area-ish check against ~556 km^2 from Attar & Dhieb)
y = deg2rad(lat - mean(lat)) * R;  x = deg2rad(lon - mean(lon)) * R * cosd(mean(lat));
fibre.area_km2 = abs(polyarea(x, y)) / 1e6;
end

function d = hav(a, b, R)
dlat = deg2rad(b(:,1) - a(:,1));  dlon = deg2rad(b(:,2) - a(:,2));
h = sin(dlat/2).^2 + cosd(a(:,1)) .* cosd(b(:,1)) .* sin(dlon/2).^2;
d = 2 * R * asin(min(1, sqrt(h)));
end
