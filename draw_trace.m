function h = draw_trace(fig, pos, scene)
% DRAW_TRACE  Analytic Rayleigh-backscatter trace of ONE FEBUS channel (length = actual channel fibre length), same model as
% DAS-Simulation: P_bs(z) = P0 * 10^((R_bs_dB + 10 log10(tau/1 ns))/10) * 10^(-2 alpha z/1e4). Parameters: map_params.m.
% Returns the plot axes (no event markers: the analytic trace carries no simulated events).
cfg = scene.cfg;  th = scene.th;  m = cfg.m;  fn = cfg.font;  ks = cfg.uiScale;  F = scene.fibre;
bg = panel_axes(fig, pos, th, ks);
hin = pos(4) * cfg.figSizeIn(2) / ks;                             % design inches
u = ks / cfg.figSizeIn(2);                                         % normalised height of one design inch
text(bg, 0.05, 1 - 0.12 / hin, 'BACKSCATTER, ONE CHANNEL (ANALYTIC)', 'Color', th.muted, 'FontName', fn.name, 'FontSize', fn.title.size, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle');
axBottom = pos(2) + 0.68 * u;   axTop = pos(2) + pos(4) - 0.30 * u;
ax = axes(fig, 'Position', [pos(1) + 0.15 * pos(3), axBottom, 0.80 * pos(3), axTop - axBottom], 'Color', 'none');
ax.Tag = 'panel';   hold(ax, 'on');
Lch = max(F.segNeedKm);                                            % channel fibre length [km] (lead-in + sensing)
zk = linspace(0, Lch, 400)';   a = backscatter_power(m, zk * 1e3) * 1e9;     % [nW]
patch(ax, [zk; flipud(zk)], [a; zeros(size(a))], th.trace, 'FaceAlpha', 0.16, 'EdgeColor', 'none');
plot(ax, zk, a, '-', 'Color', th.trace, 'LineWidth', 1.0 * ks);
h = struct('ax', ax);
xlim(ax, [0 Lch]);   ylim(ax, [0 ceil(max(a) / 10) * 10]);   xticks(ax, 0:5:floor(Lch));   yticks(ax, 0:20:100);
ax.FontName = fn.name;   ax.FontSize = fn.note.size;   ax.XColor = th.muted;   ax.YColor = th.muted;
ax.LineWidth = 0.5 * ks;   ax.TickDir = 'out';   ax.Box = 'off';   ax.YGrid = 'on';   ax.GridColor = th.grid;   ax.GridAlpha = 0.6;
xlabel(ax, 'Distance along channel (km)', 'Color', th.muted, 'FontSize', fn.note.size);
ylabel(ax, 'Power (nW)', 'Color', th.muted, 'FontSize', fn.note.size);
rows = {sprintf('channel length %.2f km, pulse %.1f ns (dz = %g m), loss %g dB/km', Lch, m.tau * 1e9, m.dz_res, m.alpha_dB_km);
        sprintf('P0 = %g W, R_bs = %g dB: assumed values (map_params.m)', m.P0, m.R_bs_dB);
        sprintf('P(0) = %.1f nW, P(%.1f km) = %.1f nW', a(1) , Lch, a(end))};
for k = 1:3
    yy = 0.33 - (k - 1) * 0.12;
    text(bg, 0.06, yy / hin, rows{k}, 'Color', th.text, 'FontName', fn.name, 'FontSize', fn.note.size, 'VerticalAlignment', 'middle', 'Interpreter', 'none');
end
end
