% Simulink kursu — yeni dersler 2.3, 3.1, 4.1, 4.2, 4.3. G1 dirsek eklemi (basitleştirilmiş tek eklem), eklem kartı: tork sınırı ±25 N·m.
format short g; md = fullfile(lab_kok, 'modeller'); cd(md); bdclose all; evalin('base', sprintf('cd(''%s'')', md));
S = load(fullfile(lab_kok, 'cikti', 'ode45_sonuc.mat'));
m = [0.6 0.0854 0.484 0.226 0.4]; r = [0.065 0.117 0.161 0.26 0.30];
B = struct('J', S.J, 'kp', 40, 'kd', 2, 'ki', 0, 'hedef', deg2rad(60), 'yuk', 0, 'mgr', 9.81*sum(m.*r), 'efor', 25, 'aci0', 0);
for f = fieldnames(B)', assignin('base', f{1}, B.(f{1})); end
mgr = B.mgr; J = B.J;

%% 2.3 Sinyalleri kaydetmek ve iki koşuyu karşılaştırmak
dirsek_pd_model('sinyal_kaydi', false);
for b = {'Açı', 'Açısal hız'}
    ph = get_param(['sinyal_kaydi/' b{1}], 'PortHandles');
    set_param(ph.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', strrep(strrep(b{1}, 'Açısal hız', 'hiz_log'), 'Açı', 'aci_log'));
end
save_system('sinyal_kaydi'); model_ciz('sinyal_kaydi', '2.3', 'sinyal-kaydi-model');
komut('2.3', 'logsout', {'kd = 2;  o2 = sim("sinyal_kaydi");', 'o2.logsout', 'a2 = o2.logsout.get("aci_log").Values;', ...
    'kd = 4;  o4 = sim("sinyal_kaydi");', 'a4 = o4.logsout.get("aci_log").Values;', ...
    'fark = rad2deg(a2.Data - interp1(a4.Time, a4.Data, a2.Time));', '[en_buyuk, i] = max(abs(fark))', 'an = a2.Time(i)'});
kd2 = evalin('base', 'a2'); kd4 = evalin('base', 'a4'); fark = evalin('base', 'fark'); [eb, i] = max(abs(fark));
h2 = evalin('base', 'o2.logsout.get("hiz_log").Values'); h4 = evalin('base', 'o4.logsout.get("hiz_log").Values');
olc('d2_3_en_buyuk_fark', eb); olc('d2_3_an', kd2.Time(i)); olc('d2_3_tepe_kd2', rad2deg(max(kd2.Data))); olc('d2_3_tepe_kd4', rad2deg(max(kd4.Data)));
olc('d2_3_hiz_max_kd2', max(abs(h2.Data))); olc('d2_3_hiz_max_kd4', max(abs(h4.Data)));
fig = yeni_sekil;
subplot(2, 1, 1); plot(kd2.Time, rad2deg(kd2.Data), 'Color', [0.11 0.31 0.85]); hold on; plot(kd4.Time, rad2deg(kd4.Data), 'Color', [0.92 0.55 0.10]);
yline(60, ':k'); grid on; ylabel('açı [°]'); legend('kd = 2', 'kd = 4', 'Location', 'southeast'); title('Kaydedilen iki sinyal, iki koşu');
subplot(2, 1, 2); plot(kd2.Time, fark, 'Color', [0.76 0.25 0.05]); grid on; xlabel('zaman [s]'); ylabel('fark [°]');
title(sprintf('Fark: en büyük %.1f° (%.3f s)', eb, kd2.Time(i))); sekil(fig, '2.3', 'iki-kosu');

%% 3.1 Açık çevrim ve kapalı çevrim: dolu bardak modelde yokken
% İleri besleme torku boş el için hesaplanır; gerçekte elde 0,2 kg bardak var. gb = 0 açık çevrim, gb = 1 kapalı çevrim (PD).
assignin('base', 'aci0', deg2rad(60)); assignin('base', 'yuk', 0.2); assignin('base', 'tff', -mgr*cos(deg2rad(60))); assignin('base', 'gb', 0);
acik_kapali_model('acik_kapali'); model_ciz('acik_kapali', '3.1', 'acik-kapali-model');
komut('3.1', 'acik-kapali', {'tff = -mgr * cos(deg2rad(60))', 'yuk = 0.2;', 'gb = 0;  oA = sim("acik_kapali");', 'gb = 1;  oK = sim("acik_kapali");', ...
    'sapma_acik = max(abs(rad2deg(oA.aci.Data) - 60))', 'son_hata_kapali = rad2deg(oK.aci.Data(end)) - 60', ...
    'beklenen = rad2deg(9.81 * yuk * 0.3 * cos(deg2rad(60)) / kp)'});
oA = evalin('base', 'oA'); oK = evalin('base', 'oK');
olc('d3_1_tff', -mgr*cos(deg2rad(60))); olc('d3_1_sapma_acik', max(abs(rad2deg(oA.aci.Data) - 60))); olc('d3_1_son_hata_kapali', rad2deg(oK.aci.Data(end)) - 60);
olc('d3_1_beklenen', rad2deg(9.81*0.2*0.3*cos(deg2rad(60))/40));
fig = yeni_sekil; plot(oA.aci.Time, rad2deg(oA.aci.Data), 'Color', [0.76 0.25 0.05]); hold on; plot(oK.aci.Time, rad2deg(oK.aci.Data), 'Color', [0.11 0.31 0.85]);
yline(60, ':k', 'hedef 60°', 'FontSize', 13); grid on; xlabel('zaman [s]'); ylabel('dirsek açısı [°]');
legend('açık çevrim: yalnız ileri besleme', 'kapalı çevrim: + PD geri besleme', 'Location', 'northeast'); title('Modelde olmayan bardak: açık çevrim sürükleniyor'); sekil(fig, '3.1', 'acik-kapali-grafik');
assignin('base', 'gb', 1); bdclose all;

%% 4.1 Bozucu etki: bardak ele konunca (1. saniyede 0 → 0,2 kg)
assignin('base', 'aci0', deg2rad(60)); assignin('base', 'yuk_son', 0.2); assignin('base', 'N', 1000);
bozucu_model('bozucu'); model_ciz('bozucu', '4.1', 'bozucu-model');
ay = {'PD (benzetimdeki)', 40, 0, 2; 'PID ayarlı', 200, 400, 8}; sapma = zeros(2, 1); toparlanma = zeros(2, 1); son = zeros(2, 1); oo = cell(2, 1);
for i = 1:2
    assignin('base', 'kp', ay{i, 2}); assignin('base', 'ki', ay{i, 3}); assignin('base', 'kd', ay{i, 4});
    o = sim('bozucu'); oo{i} = o; tt = o.aci.Time; a = rad2deg(o.aci.Data); i1 = tt >= 1;
    sapma(i) = max(abs(a(i1) - 60)); son(i) = a(end) - 60;
    dis = find(i1 & abs(a - 60) > 0.5, 1, 'last'); if isempty(dis), toparlanma(i) = 0; elseif dis == numel(tt), toparlanma(i) = Inf; else, toparlanma(i) = tt(dis + 1) - 1; end
end
T41 = table(string(ay(:, 1)), round(sapma, 2), round(toparlanma, 3), round(son, 2), 'VariableNames', {'ayar', 'en_buyuk_sapma_derece', 'toparlanma_s', 'son_hata_derece'});
assignin('base', 'T41', T41); komut('4.1', 'bozucu-tablo', {'yuk_son', 'T41'});
olc('d4_1_sapma', round(sapma, 2)); olc('d4_1_toparlanma', round(toparlanma, 3)); olc('d4_1_son', round(son, 2));
fig = yeni_sekil; renk = [0.76 0.25 0.05; 0.11 0.31 0.85];
for i = 1:2, plot(oo{i}.aci.Time, rad2deg(oo{i}.aci.Data), 'Color', renk(i, :)); hold on; end
xline(1, '--k', 'bardak konuyor', 'FontSize', 13); yline(60, ':k'); ylim([56 64]); grid on; xlabel('zaman [s]'); ylabel('dirsek açısı [°]');
legend(ay(:, 1), 'Location', 'northeast'); title('Bozucu etki: PID toparlanıyor, PD sarkık kalıyor'); sekil(fig, '4.1', 'bozucu-grafik');

%% 4.2 Türev filtresi ve ölçüm gürültüsü (gürültü 0,3°, ÖRNEK)
assignin('base', 'kp', 200); assignin('base', 'ki', 400); assignin('base', 'kd', 8); assignin('base', 'sigma', deg2rad(0.3));
gurultu_model('turev_filtresi'); model_ciz('turev_filtresi', '4.2', 'turev-filtresi-model');
Nl = [1000 100 20]; in = repmat(Simulink.SimulationInput('turev_filtresi'), 1, 3);
for i = 1:3, in(i) = in(i).setVariable('N', Nl(i)); end
outs = sim(in, 'ShowProgress', 'off'); titreme = zeros(3, 1); hata = zeros(3, 1); sinirda = zeros(3, 1);
for i = 1:3
    tk = outs(i).tork.Data; tt = outs(i).tork.Time; a = rad2deg(outs(i).aci.Data); ta = outs(i).aci.Time;
    titreme(i) = std(tk(tt >= 1)); hata(i) = sqrt(mean((a(ta >= 1) - 60).^2)); sinirda(i) = 100 * mean(abs(tk(tt >= 1)) >= 24.99);
end
T42 = table(Nl', round(titreme, 2), round(hata, 3), round(sinirda, 1), 'VariableNames', {'N', 'tork_titremesi_Nm', 'aci_hatasi_derece', 'sinirda_yuzde'});
assignin('base', 'T42', T42); komut('4.2', 'filtre-tablo', {'sigma_derece = rad2deg(sigma)', 'T42'});
olc('d4_2_N', Nl); olc('d4_2_titreme', round(titreme, 2)); olc('d4_2_hata', round(hata, 3)); olc('d4_2_sinirda', round(sinirda, 1));
fig = yeni_sekil; renk = lines(3);
for i = [1 3], stairs(outs(i).tork.Time, outs(i).tork.Data, 'Color', renk(i, :), 'LineWidth', 1.1); hold on; end
xlim([1 1.5]); ylim([-27 27]); yline([25 -25], '--r'); grid on; xlabel('zaman [s]'); ylabel('dirsek torku [N·m]');
legend('N = 1000', 'N = 20', 'tork sınırı ±25 N·m', 'Location', 'southoutside', 'Orientation', 'horizontal'); title('Gürültülü ölçümde türev filtresi: tork titremesi'); sekil(fig, '4.2', 'filtre-tork');
bdclose all;

%% 4.3 Hızlı koşu: aynı taramayı Fast Restart ile
assignin('base', 'kp', 200); assignin('base', 'ki', 400); assignin('base', 'kd', 8); assignin('base', 'yuk', 0.2); assignin('base', 'aci0', 0);
eklem_model('hizli_kosu', 'pid'); set_param('hizli_kosu/Denetleyici', 'LimitOutput', 'on', 'UpperSaturationLimit', 'efor', 'LowerSaturationLimit', '-efor', 'AntiWindupMode', 'clamping');
save_system('hizli_kosu'); model_ciz('hizli_kosu', '4.3', 'hizli-kosu-model');
komut('4.3', 'fast-restart', {'kdl = linspace(2, 12, 20);  son1 = zeros(1, 20);  son2 = zeros(1, 20);', ...
    'tic; for i = 1:20, kd = kdl(i); o = sim("hizli_kosu"); son1(i) = o.aci.Data(end); end; normal_s = toc', ...
    'set_param("hizli_kosu", "FastRestart", "on");', ...
    'tic; for i = 1:20, kd = kdl(i); o = sim("hizli_kosu"); son2(i) = o.aci.Data(end); end; hizli_s = toc', ...
    'set_param("hizli_kosu", "FastRestart", "off");', 'kat = normal_s / hizli_s', 'ayni_mi = max(abs(son1 - son2))'});
olc('d4_3_normal_s', evalin('base', 'normal_s')); olc('d4_3_hizli_s', evalin('base', 'hizli_s')); olc('d4_3_kat', evalin('base', 'kat')); olc('d4_3_fark', evalin('base', 'ayni_mi'));
% süreleri bir kez daha ölç (tekrarlanabilirlik); grafik ikinci ölçümle
tn = zeros(1, 2); th = zeros(1, 2); kdl = linspace(2, 12, 20);
for r = 1:2
    set_param('hizli_kosu', 'FastRestart', 'off'); tic; for i = 1:20, assignin('base', 'kd', kdl(i)); sim('hizli_kosu'); end; tn(r) = toc;
    set_param('hizli_kosu', 'FastRestart', 'on'); tic; for i = 1:20, assignin('base', 'kd', kdl(i)); sim('hizli_kosu'); end; th(r) = toc;
end
set_param('hizli_kosu', 'FastRestart', 'off'); olc('d4_3_tekrar_normal', tn); olc('d4_3_tekrar_hizli', th);
fig = yeni_sekil; b = bar([evalin('base', 'normal_s') tn; evalin('base', 'hizli_s') th]); grid on; set(gca, 'XTickLabel', {'normal', 'Fast Restart'}); ylabel('20 koşu, toplam süre [s]');
legend('1. ölçüm', '2. ölçüm', '3. ölçüm', 'Location', 'northeast'); title('Aynı 20 koşu: Fast Restart derlemeyi bir kez yapıyor'); sekil(fig, '4.3', 'sure-grafik');
bdclose all; disp('HAFTA234 TAMAM');

function acik_kapali_model(mdl)
if bdIsLoaded(mdl), close_system(mdl, 0); end; if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end; new_system(mdl);
add_block('simulink/Sources/Constant', [mdl '/Hedef'], 'Value', 'hedef', 'Position', [20 90 60 120]);
add_block('simulink/Math Operations/Sum', [mdl '/Hata'], 'Inputs', '+-', 'IconShape', 'rectangular', 'Position', [100 90 120 120]);
add_block('simulink/Math Operations/Gain', [mdl '/kp'], 'Gain', 'kp', 'Position', [150 90 190 120]);
add_block('simulink/Math Operations/Sum', [mdl '/PD'], 'Inputs', '+-', 'IconShape', 'rectangular', 'Position', [220 90 240 120]);
add_block('simulink/Math Operations/Gain', [mdl '/Geri besleme anahtarı'], 'Gain', 'gb', 'Position', [270 90 320 120]);
add_block('simulink/Sources/Constant', [mdl '/İleri besleme'], 'Value', 'tff', 'Position', [270 20 320 50]);
add_block('simulink/Math Operations/Sum', [mdl '/Komut torku'], 'Inputs', '++', 'IconShape', 'rectangular', 'Position', [350 60 370 120]);
add_block('simulink/Discontinuities/Saturation', [mdl '/Tork sınırı'], 'UpperLimit', 'efor', 'LowerLimit', '-efor', 'Position', [400 75 440 105]);
add_block('simulink/Math Operations/Sum', [mdl '/Net tork'], 'Inputs', '++', 'IconShape', 'rectangular', 'Position', [470 75 490 105]);
add_block('simulink/Math Operations/Gain', [mdl '/Ters eylemsizlik'], 'Gain', '1/(J + yuk*0.3^2)', 'Position', [520 75 580 105]);
add_block('simulink/Continuous/Integrator', [mdl '/Açısal hız'], 'InitialCondition', '0', 'Position', [610 75 640 105]);
add_block('simulink/Continuous/Integrator', [mdl '/Açı'], 'InitialCondition', 'aci0', 'Position', [680 75 710 105]);
add_block('simulink/Math Operations/Gain', [mdl '/kd'], 'Gain', 'kd', 'Orientation', 'left', 'Position', [400 170 440 200]);
add_block('simulink/User-Defined Functions/Fcn', [mdl '/Yerçekimi torku'], 'Expr', '(mgr + 9.81*yuk*0.3)*cos(u(1))', 'Orientation', 'left', 'Position', [480 230 580 260]);
add_block('simulink/Sinks/To Workspace', [mdl '/aci'], 'VariableName', 'aci', 'SaveFormat', 'Timeseries', 'Position', [760 75 810 105]);
add_line(mdl, 'Hedef/1', 'Hata/1', 'autorouting', 'on'); add_line(mdl, 'Hata/1', 'kp/1', 'autorouting', 'on'); add_line(mdl, 'kp/1', 'PD/1', 'autorouting', 'on');
add_line(mdl, 'PD/1', 'Geri besleme anahtarı/1', 'autorouting', 'on'); add_line(mdl, 'Geri besleme anahtarı/1', 'Komut torku/2', 'autorouting', 'on');
add_line(mdl, 'İleri besleme/1', 'Komut torku/1', 'autorouting', 'on'); add_line(mdl, 'Komut torku/1', 'Tork sınırı/1', 'autorouting', 'on');
add_line(mdl, 'Tork sınırı/1', 'Net tork/1', 'autorouting', 'on'); add_line(mdl, 'Net tork/1', 'Ters eylemsizlik/1', 'autorouting', 'on');
add_line(mdl, 'Ters eylemsizlik/1', 'Açısal hız/1', 'autorouting', 'on'); add_line(mdl, 'Açısal hız/1', 'Açı/1', 'autorouting', 'on'); add_line(mdl, 'Açı/1', 'aci/1', 'autorouting', 'on');
add_line(mdl, 'Açısal hız/1', 'kd/1', 'autorouting', 'on'); add_line(mdl, 'kd/1', 'PD/2', 'autorouting', 'on'); add_line(mdl, 'Açı/1', 'Hata/2', 'autorouting', 'on');
add_line(mdl, 'Açı/1', 'Yerçekimi torku/1', 'autorouting', 'on'); add_line(mdl, 'Yerçekimi torku/1', 'Net tork/2', 'autorouting', 'on');
set_param(mdl, 'Solver', 'ode45', 'MaxStep', '0.002', 'StopTime', '3'); save_system(mdl);
end

function bozucu_model(mdl)
% PID + tork sınırı; yük 1. saniyede 0'dan yuk_son'a basamakla çıkar (yerçekimi ve eylemsizlik yüke göre)
if bdIsLoaded(mdl), close_system(mdl, 0); end; if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end; new_system(mdl);
add_block('simulink/Sources/Constant', [mdl '/Hedef'], 'Value', 'hedef', 'Position', [20 90 60 120]);
add_block('simulink/Math Operations/Sum', [mdl '/Hata'], 'Inputs', '+-', 'IconShape', 'rectangular', 'Position', [100 90 120 120]);
add_block('simulink/Continuous/PID Controller', [mdl '/Denetleyici'], 'P', 'kp', 'I', 'ki', 'D', 'kd', 'N', 'N', ...
    'LimitOutput', 'on', 'UpperSaturationLimit', 'efor', 'LowerSaturationLimit', '-efor', 'AntiWindupMode', 'clamping', 'Position', [150 85 220 125]);
add_block('simulink/Sources/Step', [mdl '/Bardak konuyor'], 'Time', '1', 'Before', '0', 'After', 'yuk_son', 'Position', [250 200 280 230]);
add_block('simulink/Signal Routing/Mux', [mdl '/Mux'], 'Inputs', '2', 'Position', [330 180 335 250]);
add_block('simulink/User-Defined Functions/Fcn', [mdl '/Yerçekimi torku'], 'Expr', '(mgr + 9.81*u(2)*0.3)*cos(u(1))', 'Position', [370 200 470 230]);
add_block('simulink/Math Operations/Sum', [mdl '/Net tork'], 'Inputs', '++', 'IconShape', 'rectangular', 'Position', [500 90 520 120]);
add_block('simulink/Signal Routing/Mux', [mdl '/Mux2'], 'Inputs', '2', 'Position', [550 80 555 150]);
add_block('simulink/User-Defined Functions/Fcn', [mdl '/Açısal ivme'], 'Expr', 'u(1)/(J + u(2)*0.3^2)', 'Position', [580 100 660 130]);
add_block('simulink/Continuous/Integrator', [mdl '/Açısal hız'], 'InitialCondition', '0', 'Position', [690 100 720 130]);
add_block('simulink/Continuous/Integrator', [mdl '/Açı'], 'InitialCondition', 'aci0', 'Position', [750 100 780 130]);
add_block('simulink/Sinks/To Workspace', [mdl '/aci'], 'VariableName', 'aci', 'SaveFormat', 'Timeseries', 'Position', [830 100 880 130]);
add_block('simulink/Sinks/To Workspace', [mdl '/tork'], 'VariableName', 'tork', 'SaveFormat', 'Timeseries', 'Position', [250 20 300 50]);
add_line(mdl, 'Hedef/1', 'Hata/1', 'autorouting', 'on'); add_line(mdl, 'Hata/1', 'Denetleyici/1', 'autorouting', 'on'); add_line(mdl, 'Denetleyici/1', 'Net tork/1', 'autorouting', 'on');
add_line(mdl, 'Denetleyici/1', 'tork/1', 'autorouting', 'on');
add_line(mdl, 'Açı/1', 'Mux/1', 'autorouting', 'on'); add_line(mdl, 'Bardak konuyor/1', 'Mux/2', 'autorouting', 'on'); add_line(mdl, 'Mux/1', 'Yerçekimi torku/1', 'autorouting', 'on');
add_line(mdl, 'Yerçekimi torku/1', 'Net tork/2', 'autorouting', 'on'); add_line(mdl, 'Net tork/1', 'Mux2/1', 'autorouting', 'on'); add_line(mdl, 'Bardak konuyor/1', 'Mux2/2', 'autorouting', 'on');
add_line(mdl, 'Mux2/1', 'Açısal ivme/1', 'autorouting', 'on'); add_line(mdl, 'Açısal ivme/1', 'Açısal hız/1', 'autorouting', 'on'); add_line(mdl, 'Açısal hız/1', 'Açı/1', 'autorouting', 'on');
add_line(mdl, 'Açı/1', 'aci/1', 'autorouting', 'on'); add_line(mdl, 'Açı/1', 'Hata/2', 'autorouting', 'on');
set_param(mdl, 'Solver', 'ode45', 'MaxStep', '0.002', 'StopTime', '3'); save_system(mdl);
end

function gurultu_model(mdl)
% PID (türev filtresi N) + tork sınırı + dolu bardak; ölçülen açıya gürültü eklenir (ÖRNEK σ). Başlangıç hedefte.
if bdIsLoaded(mdl), close_system(mdl, 0); end; if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end; new_system(mdl);
add_block('simulink/Sources/Constant', [mdl '/Hedef'], 'Value', 'hedef', 'Position', [20 90 60 120]);
add_block('simulink/Math Operations/Sum', [mdl '/Hata'], 'Inputs', '+-', 'IconShape', 'rectangular', 'Position', [100 90 120 120]);
add_block('simulink/Continuous/PID Controller', [mdl '/Denetleyici'], 'P', 'kp', 'I', 'ki', 'D', 'kd', 'N', 'N', ...
    'LimitOutput', 'on', 'UpperSaturationLimit', 'efor', 'LowerSaturationLimit', '-efor', 'AntiWindupMode', 'clamping', 'Position', [150 85 220 125]);
add_block('simulink/Math Operations/Sum', [mdl '/Net tork'], 'Inputs', '++', 'IconShape', 'rectangular', 'Position', [280 90 300 120]);
add_block('simulink/Math Operations/Gain', [mdl '/Ters eylemsizlik'], 'Gain', '1/(J + yuk*0.3^2)', 'Position', [330 90 390 120]);
add_block('simulink/Continuous/Integrator', [mdl '/Açısal hız'], 'InitialCondition', '0', 'Position', [420 90 450 120]);
add_block('simulink/Continuous/Integrator', [mdl '/Açı'], 'InitialCondition', 'aci0', 'Position', [490 90 520 120]);
add_block('simulink/User-Defined Functions/Fcn', [mdl '/Yerçekimi torku'], 'Expr', '(mgr + 9.81*yuk*0.3)*cos(u(1))', 'Orientation', 'left', 'Position', [300 160 400 190]);
add_block('simulink/Sources/Random Number', [mdl '/Ölçüm gürültüsü'], 'Mean', '0', 'Variance', 'sigma^2', 'Seed', '1', 'SampleTime', '0.002', 'Position', [480 230 530 260]);
add_block('simulink/Math Operations/Sum', [mdl '/Ölçülen açı'], 'Inputs', '++', 'IconShape', 'rectangular', 'Position', [580 200 600 230]);
add_block('simulink/Sinks/To Workspace', [mdl '/aci'], 'VariableName', 'aci', 'SaveFormat', 'Timeseries', 'Position', [580 90 630 120]);
add_block('simulink/Sinks/To Workspace', [mdl '/tork'], 'VariableName', 'tork', 'SaveFormat', 'Timeseries', 'Position', [230 20 280 50]);
add_line(mdl, 'Hedef/1', 'Hata/1', 'autorouting', 'on'); add_line(mdl, 'Hata/1', 'Denetleyici/1', 'autorouting', 'on'); add_line(mdl, 'Denetleyici/1', 'Net tork/1', 'autorouting', 'on');
add_line(mdl, 'Denetleyici/1', 'tork/1', 'autorouting', 'on'); add_line(mdl, 'Net tork/1', 'Ters eylemsizlik/1', 'autorouting', 'on');
add_line(mdl, 'Ters eylemsizlik/1', 'Açısal hız/1', 'autorouting', 'on'); add_line(mdl, 'Açısal hız/1', 'Açı/1', 'autorouting', 'on'); add_line(mdl, 'Açı/1', 'aci/1', 'autorouting', 'on');
add_line(mdl, 'Açı/1', 'Yerçekimi torku/1', 'autorouting', 'on'); add_line(mdl, 'Yerçekimi torku/1', 'Net tork/2', 'autorouting', 'on');
add_line(mdl, 'Açı/1', 'Ölçülen açı/1', 'autorouting', 'on'); add_line(mdl, 'Ölçüm gürültüsü/1', 'Ölçülen açı/2', 'autorouting', 'on'); add_line(mdl, 'Ölçülen açı/1', 'Hata/2', 'autorouting', 'on');
set_param(mdl, 'Solver', 'ode45', 'MaxStep', '0.002', 'StopTime', '3'); save_system(mdl);
end
