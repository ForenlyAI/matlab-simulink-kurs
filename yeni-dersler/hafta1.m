% Simulink kursu — yeni dersler 1.2, 1.3, 1.4. Fizik: düşen bardak (masa yüksekliği benzetim kaydından), kütle-yay-sönüm (ÖRNEK).
format short g; md = fullfile(lab_kok, 'modeller'); if ~exist(md, 'dir'), mkdir(md); end; cd(md); bdclose all;
evalin('base', sprintf('cd(''%s'')', md));
assignin('base', 'g', 9.81); assignin('base', 'h0', 0.76);

%% 1.2 Düşen bardak: iki integratörle hareket
dusen_bardak_model('dusen_bardak'); model_ciz('dusen_bardak', '1.2', 'dusen-bardak-model');
komut('1.2', 'dusen-bardak', {'g = 9.81;  h0 = 0.76;', 'o = sim("dusen_bardak");', 't_dus = o.tout(end)', 'v_carpma = o.v.Data(end)', ...
    'formul_t = sqrt(2 * h0 / g)', 'formul_v = -sqrt(2 * g * h0)', 'fark_ms = 1000 * abs(t_dus - formul_t)'});
o = sim('dusen_bardak'); tf = sqrt(2*0.76/9.81);
olc('d1_2_t_dus', o.tout(end)); olc('d1_2_v_carpma', o.v.Data(end)); olc('d1_2_formul_t', tf); olc('d1_2_formul_v', -sqrt(2*9.81*0.76));
fig = yeni_sekil;
subplot(1, 2, 1); plot(o.z.Time, o.z.Data, 'Color', [0.11 0.31 0.85]); hold on; plot(tf, 0, 'o', 'MarkerSize', 12, 'Color', [0.76 0.25 0.05], 'LineWidth', 2);
grid on; xlabel('zaman [s]'); ylabel('yükseklik z [m]'); title('Yükseklik'); legend('Simulink', sprintf('formül: %.4f s', tf), 'Location', 'southwest');
subplot(1, 2, 2); plot(o.v.Time, o.v.Data, 'Color', [0.06 0.46 0.43]); grid on; xlabel('zaman [s]'); ylabel('hız v [m/s]'); title('Hız');
sgtitle(sprintf('Masadan düşen bardak: %.4f s sonra yerde, %.2f m/s', o.tout(end), abs(o.v.Data(end)))); sekil(fig, '1.2', 'dusme-grafik');

%% 1.3 Çözücü ve adım boyu: aynı model, beş çözücü ayarı
ayar = {'ode45', 'auto'; 'ode1', '0.05'; 'ode1', '0.01'; 'ode1', '0.001'; 'ode4', '0.01'};
in = repmat(Simulink.SimulationInput('dusen_bardak'), 1, 5);
for i = 1:5
    if strcmp(ayar{i, 1}, 'ode45'), in(i) = in(i).setModelParameter('SolverType', 'Variable-step', 'Solver', 'ode45');
    else, in(i) = in(i).setModelParameter('SolverType', 'Fixed-step', 'Solver', ayar{i, 1}, 'FixedStep', ayar{i, 2}); end
end
outs = sim(in, 'ShowProgress', 'off');
cozucu = string(ayar(:, 1)); adim = string(ayar(:, 2)); t_dus = zeros(5, 1); hata_ms = zeros(5, 1); adim_sayisi = zeros(5, 1);
for i = 1:5, t_dus(i) = outs(i).tout(end); hata_ms(i) = round(1000 * abs(t_dus(i) - tf), 3); adim_sayisi(i) = numel(outs(i).tout); end
T13 = table(cozucu, adim, round(t_dus, 5), hata_ms, adim_sayisi, 'VariableNames', {'cozucu', 'adim_s', 't_dus_s', 'hata_ms', 'adim_sayisi'});
assignin('base', 'T13', T13); assignin('base', 'in', in);
komut('1.3', 'cozucu-tablosu', {'in(2)', 'T13'});
olc('d1_3_t_dus', round(t_dus, 5)); olc('d1_3_hata_ms', hata_ms); olc('d1_3_adim_sayisi', adim_sayisi);
fig = yeni_sekil; renk = lines(5);
for i = 1:5, stairs(outs(i).z.Time, outs(i).z.Data, 'Color', renk(i, :), 'LineWidth', 1.6); hold on; end
xline(tf, '--k', 'formül', 'FontSize', 13); yline(0, 'k'); xlim([0.30 0.46]); ylim([-0.12 0.35]); grid on; xlabel('zaman [s]'); ylabel('z [m]');
legend(compose('%s · adım %s → %.4f s', cozucu, adim, t_dus), 'Location', 'northeast', 'FontSize', 12); title('Yere değme anı: çözücüye ve adıma göre'); sekil(fig, '1.3', 'cozucu-karsilastirma');

%% 1.4 Kütle-yay-sönüm: integratörlerle ve transfer fonksiyonuyla (ÖRNEK değerler)
assignin('base', 'm', 2); assignin('base', 'k', 200); assignin('base', 'c', 4); assignin('base', 'F', 10);
kys_model('kutle_yay'); model_ciz('kutle_yay', '1.4', 'kutle-yay-model');
komut('1.4', 'iki-yol', {'m = 2;  k = 200;  c = 4;  F = 10;', 'o = sim("kutle_yay");', 'xa = o.x_integrator.Data;  xb = o.x_transfer.Data;', ...
    'en_buyuk_fark = max(abs(xa - xb))', 'tepe = find(islocalmax(xa));', 'periyot = mean(diff(o.tout(tepe)))', ...
    'formul = 2*pi / sqrt(k/m - (c/(2*m))^2)', 'asim_yuzde = 100 * (max(xa) / (F/k) - 1)'});
o = sim('kutle_yay'); xa = o.x_integrator.Data; xb = o.x_transfer.Data; tp = find(islocalmax(xa));
per = mean(diff(o.tout(tp))); fp = 2*pi/sqrt(200/2 - (4/4)^2);
olc('d1_4_fark', max(abs(xa - xb))); olc('d1_4_periyot', per); olc('d1_4_formul', fp); olc('d1_4_asim', 100*(max(xa)/(10/200) - 1)); olc('d1_4_son', xa(end));
fig = yeni_sekil; plot(o.tout, 1000*xa, 'Color', [0.11 0.31 0.85]); hold on; plot(o.tout, 1000*xb, '--', 'Color', [0.92 0.55 0.10]);
plot(o.tout(tp), 1000*xa(tp), 'v', 'MarkerSize', 9, 'MarkerFaceColor', [0.76 0.25 0.05], 'Color', [0.76 0.25 0.05]); yline(50, ':k', 'F / k = 50 mm', 'FontSize', 13);
grid on; xlabel('zaman [s]'); ylabel('konum x [mm]'); legend('integratörlerle', 'transfer fonksiyonuyla', 'tepeler', 'Location', 'southeast');
title(sprintf('İki yol, aynı sonuç — periyot %.4f s (formül %.4f s)', per, fp)); sekil(fig, '1.4', 'iki-yol-grafik');
bdclose all; disp('HAFTA1 TAMAM');

function dusen_bardak_model(mdl)
if bdIsLoaded(mdl), close_system(mdl, 0); end; if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end; new_system(mdl);
add_block('simulink/Sources/Constant', [mdl '/Yerçekimi ivmesi'], 'Value', '-g', 'Position', [30 90 90 120]);
add_block('simulink/Continuous/Integrator', [mdl '/Hız'], 'InitialCondition', '0', 'Position', [150 90 180 120]);
add_block('simulink/Continuous/Integrator', [mdl '/Yükseklik'], 'InitialCondition', 'h0', 'Position', [240 90 270 120]);
add_block('simulink/Sinks/To Workspace', [mdl '/z'], 'VariableName', 'z', 'SaveFormat', 'Timeseries', 'Position', [340 90 390 120]);
add_block('simulink/Sinks/To Workspace', [mdl '/v'], 'VariableName', 'v', 'SaveFormat', 'Timeseries', 'Position', [240 20 290 50]);
add_block('simulink/Logic and Bit Operations/Compare To Constant', [mdl '/Yere değdi mi'], 'relop', '<=', 'const', '0', 'Position', [340 160 400 190]);
add_block('simulink/Sinks/Stop Simulation', [mdl '/Dur'], 'Position', [450 160 480 190]);
add_line(mdl, 'Yerçekimi ivmesi/1', 'Hız/1', 'autorouting', 'on'); add_line(mdl, 'Hız/1', 'Yükseklik/1', 'autorouting', 'on');
add_line(mdl, 'Yükseklik/1', 'z/1', 'autorouting', 'on'); add_line(mdl, 'Hız/1', 'v/1', 'autorouting', 'on');
add_line(mdl, 'Yükseklik/1', 'Yere değdi mi/1', 'autorouting', 'on'); add_line(mdl, 'Yere değdi mi/1', 'Dur/1', 'autorouting', 'on');
set_param(mdl, 'Solver', 'ode45', 'StopTime', '2', 'MaxStep', 'auto'); save_system(mdl);
end

function kys_model(mdl)
if bdIsLoaded(mdl), close_system(mdl, 0); end; if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end; new_system(mdl);
add_block('simulink/Sources/Step', [mdl '/Kuvvet'], 'Time', '0', 'After', 'F', 'Position', [20 110 50 140]);
% yol 1: integratörler — m·x'' = F − c·x' − k·x
add_block('simulink/Math Operations/Sum', [mdl '/Toplam kuvvet'], 'Inputs', '+--', 'IconShape', 'rectangular', 'Position', [110 40 130 90]);
add_block('simulink/Math Operations/Gain', [mdl '/1 bölü m'], 'Gain', '1/m', 'Position', [170 50 210 80]);
add_block('simulink/Continuous/Integrator', [mdl '/Hız'], 'Position', [250 50 280 80]);
add_block('simulink/Continuous/Integrator', [mdl '/Konum'], 'Position', [320 50 350 80]);
add_block('simulink/Math Operations/Gain', [mdl '/c'], 'Gain', 'c', 'Orientation', 'left', 'Position', [250 -20 290 10]);
add_block('simulink/Math Operations/Gain', [mdl '/k'], 'Gain', 'k', 'Orientation', 'left', 'Position', [320 -20 360 10]);
add_block('simulink/Sinks/To Workspace', [mdl '/x_integrator'], 'VariableName', 'x_integrator', 'SaveFormat', 'Timeseries', 'Position', [410 50 480 80]);
add_line(mdl, 'Kuvvet/1', 'Toplam kuvvet/1', 'autorouting', 'on'); add_line(mdl, 'Toplam kuvvet/1', '1 bölü m/1', 'autorouting', 'on');
add_line(mdl, '1 bölü m/1', 'Hız/1', 'autorouting', 'on'); add_line(mdl, 'Hız/1', 'Konum/1', 'autorouting', 'on'); add_line(mdl, 'Konum/1', 'x_integrator/1', 'autorouting', 'on');
add_line(mdl, 'Hız/1', 'c/1', 'autorouting', 'on'); add_line(mdl, 'c/1', 'Toplam kuvvet/2', 'autorouting', 'on');
add_line(mdl, 'Konum/1', 'k/1', 'autorouting', 'on'); add_line(mdl, 'k/1', 'Toplam kuvvet/3', 'autorouting', 'on');
% yol 2: transfer fonksiyonu — X(s)/F(s) = 1 / (m s² + c s + k)
add_block('simulink/Continuous/Transfer Fcn', [mdl '/Transfer fonksiyonu'], 'Numerator', '1', 'Denominator', '[m c k]', 'Position', [170 170 260 210]);
add_block('simulink/Sinks/To Workspace', [mdl '/x_transfer'], 'VariableName', 'x_transfer', 'SaveFormat', 'Timeseries', 'Position', [410 175 480 205]);
add_line(mdl, 'Kuvvet/1', 'Transfer fonksiyonu/1', 'autorouting', 'on'); add_line(mdl, 'Transfer fonksiyonu/1', 'x_transfer/1', 'autorouting', 'on');
set_param(mdl, 'Solver', 'ode45', 'StopTime', '3', 'MaxStep', '0.001', 'RelTol', '1e-8', 'AbsTol', '1e-10'); save_system(mdl);
end
