% Hafta 3 — Simulink Temelleri. G1 dirsek eklemi, kıraathane çay servisi kaydı.
md = fullfile(lab_kok,'modeller'); cd(md); bdclose all; V = fullfile(lab_kok,'veri');
K = readmatrix(fullfile(V,'cay_servisi_kaydi.csv')); S = load(fullfile(lab_kok,'cikti','ode45_sonuc.mat'));
m = [0.6 0.0854 0.484 0.226 0.4]; r = [0.065 0.117 0.161 0.26 0.30];
B = struct('J',S.J,'kp',40,'kd',2,'ki',0,'hedef',deg2rad(60),'yuk',0,'mgr',9.81*sum(m.*r),'efor',25,'aci0',0);
for f = fieldnames(B)', assignin('base', f{1}, B.(f{1})); end
assignin('base','ref',[K(:,1) K(:,4)]); evalin('base', sprintf('cd(''%s'')', md));
%% 3.1 İlk model: kayıttaki dirsek açısını dereceye çevirip izlemek
mdl = 'ilk_model'; if exist([mdl '.slx'],'file'), delete([mdl '.slx']); end; new_system(mdl);
add_block('simulink/Sources/From Workspace',[mdl '/Kayıt (dirsek, rad)'],'VariableName','ref','Position',[40 85 140 125]);
add_block('simulink/Math Operations/Gain',[mdl '/Dereceye çevir'],'Gain','180/pi','Position',[200 90 250 120]);
add_block('simulink/Sinks/Scope',[mdl '/Scope'],'Position',[320 40 360 80]);
add_block('simulink/Sinks/To Workspace',[mdl '/To Workspace'],'VariableName','y','SaveFormat','Timeseries','Position',[310 120 380 150]);
add_line(mdl,'Kayıt (dirsek, rad)/1','Dereceye çevir/1','autorouting','on'); add_line(mdl,'Dereceye çevir/1','Scope/1','autorouting','on'); add_line(mdl,'Dereceye çevir/1','To Workspace/1','autorouting','on');
set_param(mdl,'StopTime','113.3','MaxStep','0.02'); save_system(mdl); model_ciz(mdl,'3.1','ilk-model');
o = sim(mdl); olc('d3_1_max', round(max(o.y.Data),1)); olc('d3_1_min', round(min(o.y.Data),1));
fig = yeni_sekil; plot(o.y.Time, o.y.Data); grid on; xlabel('zaman [s]'); ylabel('dirsek [°]'); title('ilk\_model çıktısı: kayıttaki dirsek açısı (derece)'); sekil(fig,'3.1','ilk-model-cikti');
komut('3.1','sim-komut', {'ref = [K(:,1) K(:,4)];', 'o = sim("ilk_model");', 'max(o.y.Data)', 'o.y.Time(end)'}); close_system(mdl,0);
%% 3.2 Dirsek PD modeli bloklarla; ode45 (Ders 2.3) ile karşılaştırma
dirsek_pd_model('dirsek_pd', false); model_ciz('dirsek_pd','3.2','dirsek-pd-model');
o = sim('dirsek_pd'); xo = interp1(S.ts, S.xs(:,1), o.aci.Time); fark = max(abs(xo - o.aci.Data));
olc('d3_2_fark_derece', rad2deg(fark));
fig = yeni_sekil; plot(o.aci.Time, rad2deg(o.aci.Data)); hold on; plot(S.ts, rad2deg(S.xs(:,1)), '--'); grid on; legend('Simulink','ode45 (Ders 2.3)','Location','southeast');
xlabel('zaman [s]'); ylabel('dirsek [°]'); title(sprintf('Aynı eklem, iki yol — en büyük fark %.1e°', rad2deg(fark))); sekil(fig,'3.2','simulink-ode45'); close_system('dirsek_pd',0);
%% 3.3 Alt sistem ve yük: boş el, dolu çay bardağı, tepsi
dirsek_pd_model('dirsek_yuk', true); load_system('dirsek_yuk');
ic = {'Hata','kp','Tork','Tork sınırı','Net tork','Ters eylemsizlik','Açısal hız','Açı','kd','Yerçekimi torku','tork'};
bh = cellfun(@(b) get_param(['dirsek_yuk/' b],'Handle'), ic(1:10)); Simulink.BlockDiagram.createSubsystem(bh);
sb = find_system('dirsek_yuk','SearchDepth',1,'BlockType','SubSystem'); set_param(sb{1},'Name','Dirsek eklemi'); save_system('dirsek_yuk'); model_ciz('dirsek_yuk','3.3','alt-sistem');
yukler = [0 0.2 1.0]; fig = yeni_sekil; hold on; son = zeros(1,3);
for i = 1:3, assignin('base','yuk',yukler(i)); o = sim('dirsek_yuk'); plot(o.aci.Time, rad2deg(o.aci.Data)); son(i) = rad2deg(o.aci.Data(end)); end
yline(60,'--','hedef 60°','FontSize',14); grid on; legend('boş el','dolu çay bardağı 0.2 kg','tepsi 1 kg','Location','southeast'); xlabel('zaman [s]'); ylabel('dirsek [°]');
title('Üç yük, aynı kazançlar (kp = 40, kd = 2)'); sekil(fig,'3.3','yuk-karsilastirma');
olc('d3_3_son_derece', round(son,2)); assignin('base','yuk',0); close_system('dirsek_yuk',0);
%% 3.4 Tarama: kd = 1, 2, 4, 8
mdl = 'dirsek_pd'; dirsek_pd_model(mdl, false); kdler = [1 2 4 8];
in = repmat(Simulink.SimulationInput(mdl), 1, 4); for i = 1:4, in(i) = in(i).setVariable('kd', kdler(i)); end
outs = sim(in, 'ShowProgress','off'); fig = yeni_sekil; hold on; asim = zeros(1,4); yer = zeros(1,4);
for i = 1:4, x = outs(i).aci; plot(x.Time, rad2deg(x.Data)); [asim(i), yer(i)] = adim_bilgi(x.Time, x.Data, deg2rad(60)); end
yline(60,'--'); grid on; legend(arrayfun(@(v) sprintf('kd = %g', v), kdler, 'UniformOutput', false),'Location','southeast'); xlabel('zaman [s]'); ylabel('dirsek [°]');
title('Dört koşu: sönüm kazancı kd'); sekil(fig,'3.4','kd-taramasi');
olc('d3_4_asim', round(asim,1)); olc('d3_4_yerlesme', round(yer,2));
komut('3.4','tarama', {'kd_degerleri = [1 2 4 8];', 'in = repmat(Simulink.SimulationInput("dirsek_pd"), 1, 4);', 'for i = 1:4, in(i) = in(i).setVariable("kd", kd_degerleri(i)); end', 'outs = sim(in, "ShowProgress", "off");', 'numel(outs)'});
close_system(mdl,0); disp('HAFTA3 TAMAM');
