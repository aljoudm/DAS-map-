function draw_fibre(ax, scene, lw)
% DRAW_FIBRE  3D glowing fibre following the terrain, coloured by vibration energy,
% with light pulses travelling outward from each interrogator (one frame of the animation).
cfg = scene.cfg;  c = cfg.col;  F = scene.fibre;
x = [F.x; F.x(1)];  y = [F.y; F.y(1)];  z = [F.z; F.z(1)];  e = [F.energy; F.energy(1)];

plot3(ax, x, y, z, '-', 'Color', [c.cyan 0.14], 'LineWidth', 7 * lw);
plot3(ax, x, y, z, '-', 'Color', [c.cyan 0.30], 'LineWidth', 3.4 * lw);
colormap(ax, c.fibreCmap);   clim(ax, [0 1]);
patch(ax, 'XData', x, 'YData', y, 'ZData', z + 0.004, 'CData', e, 'FaceColor', 'none', ...
    'EdgeColor', 'interp', 'LineWidth', 1.9 * lw);

hot = e > scene.thresholdNorm;                        % widen the glow above the simulator's detection threshold
if any(hot)
    xh = x;  yh = y;  zh = z;  xh(~hot) = NaN;
    plot3(ax, xh, yh, zh, '-', 'Color', [c.red 0.32], 'LineWidth', 13 * lw);
    plot3(ax, xh, yh, zh + 0.006, '-', 'Color', [c.red 0.95], 'LineWidth', 3.6 * lw);
end

% simulated 10 km section (the stretch the phi-OTDR trace panel refers to): dashed corridor + end ticks, NOT a pulse
Ev = scene.events;   sg = mod(Ev.secS0 + Ev.secDir * linspace(0, Ev.secLen, 400), F.L_km);
xs = interp1(F.s_km, F.x, sg, 'linear', 'extrap');   ys = interp1(F.s_km, F.y, sg, 'linear', 'extrap');   zs = interp1(F.s_km, F.z, sg, 'linear', 'extrap');
dx = gradient(xs);   dy = gradient(ys);   nn = hypot(dx, dy);   nxs = -dy ./ nn;   nys = dx ./ nn;
offk = 0.6;
for sgn = [-1 1]
    plot3(ax, xs + sgn * offk * nxs, ys + sgn * offk * nys, zs + 0.06, '--', 'Color', [1 1 1 0.95], 'LineWidth', 1.9 * lw);
end
for q = [1 numel(xs)]
    plot3(ax, xs(q) + [-1 1] * 1.5 * offk * nxs(q), ys(q) + [-1 1] * 1.5 * offk * nys(q), zs(q) * [1 1] + 0.06, '-', 'Color', [1 1 1 0.95], 'LineWidth', 2.4 * lw);
end

L = F.L_km;  s = F.s_km(:);                              % light pulses: each IU launches into ONE channel (n_ch = 1),
for k = 1:numel(F.iuIdx)                                  % travelling along the fibre segment it serves (increasing distance)
    s0 = s(F.iuIdx(k));
    for d = cfg.pulsePhase * cfg.pulseSpacingKm : cfg.pulseSpacingKm : F.iuSpanKm - cfg.pulseLenKm
        drawPulse(ax, F, mod(s0 + d, L), 1, cfg, lw);
    end
end
end

function drawPulse(ax, F, sHead, dirn, cfg, lw)
c = cfg.col;  L = F.L_km;  s = F.s_km(:);
nSeg = 10;  len = cfg.pulseLenKm / nSeg;
for q = 1:nSeg
    a = mod(sHead - dirn * (q - 1) * len, L);  b = mod(sHead - dirn * q * len, L);
    idx = ringIdx(s, L, a, b);
    if numel(idx) < 2, continue; end
    f = 1 - (q - 1) / nSeg;
    plot3(ax, F.x(idx), F.y(idx), F.z(idx) + 0.012, '-', 'Color', [c.cyan 0.60 * f], 'LineWidth', (15 * f + 3) * lw);
    plot3(ax, F.x(idx), F.y(idx), F.z(idx) + 0.016, '-', 'Color', [1 1 1 1.0 * f], 'LineWidth', (6 * f + 1.2) * lw);
end
end

function idx = ringIdx(s, L, a, b)
lo = min(a, b);  hi = max(a, b);
if hi - lo <= L / 2, idx = find(s >= lo & s <= hi);
else, idx = [find(s >= hi); find(s <= lo)];
end
idx = idx(:);
end
