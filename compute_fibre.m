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
fibre.N_IU        = ceil(fibre.L_km / (cfg.R_CH_KM * cfg.N_CH));
fibre.N_sensing   = round(L_m / cfg.SPATIAL_RES_M);

% IUs equally spaced along the ring; each feeds L/N_IU of fibre (<= R_ch)
k = (0:fibre.N_IU-1)' / fibre.N_IU;
idx = 1 + round(k * n);
fibre.iuIdx = idx;
fibre.iuLat = lat(idx);  fibre.iuLon = lon(idx);
fibre.iuSpanKm = fibre.L_km / fibre.N_IU;

% Enclosed area (planar, equal-area-ish check against ~556 km^2 from Attar & Dhieb)
y = deg2rad(lat - mean(lat)) * R;  x = deg2rad(lon - mean(lon)) * R * cosd(mean(lat));
fibre.area_km2 = abs(polyarea(x, y)) / 1e6;
end

function d = hav(a, b, R)
dlat = deg2rad(b(:,1) - a(:,1));  dlon = deg2rad(b(:,2) - a(:,2));
h = sin(dlat/2).^2 + cosd(a(:,1)) .* cosd(b(:,1)) .* sin(dlon/2).^2;
d = 2 * R * asin(min(1, sqrt(h)));
end
