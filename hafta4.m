% Hafta 4 — Kontrol ve Bitirme. G1 dirsek eklemi: tork sınırı (efor 25 N·m), yerçekimi, PID, kayıt takibi.
md = fullfile(lab_kok,'modeller'); cd(md); bdclose all; V = fullfile(lab_kok,'veri');
K = readmatrix(fullfile(V,'cay_servisi_kaydi.csv')); S = load(fullfile(lab_kok,'cikti','ode45_sonuc.mat'));
m = [0.6 0.0854 0.484 0.226 0.4]; r = [0.065 0.117 0.161 0.26 0.30];
B = struct('J',S.J,'kp',40,'kd',2,'ki',0,'hedef',deg2rad(60),'yuk',0.2,'mgr',9.81*sum(m.*r),'efor',25,'aci0',0);
for f = fieldnames(B)', assignin('base', f{1}, B.(f{1})); end
assignin('base','ref',[K(:,1) K(:,4)]); evalin('base', sprintf('cd(''%s'')', md));
%% 4.1 Gerçekçi eklem: tork sınırı ve yerçekimi — PD kalıcı hata bırakır
dirsek_pd_model('dirsek_gercekci', true); model_ciz('dirsek_gercekci','4.1','gercekci-model');
o1 = sim('dirsek_gercekci'); [a1, t1, e1] = adim_bilgi(o1.aci.Time, o1.aci.Data, deg2rad(60));
olc('d4_1_kalici_derece', round(rad2deg(deg2rad(60) - o1.aci.Data(end)),2)); olc('d4_1_tork_max', round(max(abs(o1.tork.Data)),2)); olc('d4_1_mgr', round(9.81*sum(m.*r),3));
fig = yeni_sekil; plot(o1.aci.Time, rad2deg(o1.aci.Data)); hold on; yline(60,'--','hedef 60°','FontSize',14); grid on; xlabel('zaman [s]'); ylabel('dirsek [°]');
title(sprintf('PD + yerçekimi: kalıcı hata %.1f°', rad2deg(deg2rad(60) - o1.aci.Data(end)))); sekil(fig,'4.1','pd-kalici-hata');
komut('4.1','yercekimi', {'mgr = 9.81 * sum(m .* r)', 'yuk = 0.2;', 'yercekimi_60 = (mgr + 9.81*yuk*0.3) * cos(deg2rad(60))', 'beklenen_hata = rad2deg(yercekimi_60 / kp)'});
close_system('dirsek_gercekci',0);
%% 4.2 PID ile kalıcı hatayı sıfırlamak
eklem_model('dirsek_pid', 'pid'); model_ciz('dirsek_pid','4.2','pid-model');
assignin('base','kp',200); assignin('base','ki',400); assignin('base','kd',8);
set_param('dirsek_pid/Denetleyici','LimitOutput','on','UpperSaturationLimit','efor','LowerSaturationLimit','-efor','AntiWindupMode','clamping'); % integral sarma koruması: çıkış ±efor'da sınırlı, sınırdayken integral birikmez
o2 = sim('dirsek_pid'); [a2, t2, e2] = adim_bilgi(o2.aci.Time, o2.aci.Data, deg2rad(60));
olc('d4_2_asim', round(a2,1)); olc('d4_2_yerlesme', round(t2,2)); olc('d4_2_kalici_yuzde', round(e2,3)); olc('d4_2_tork_max', round(max(abs(o2.tork.Data)),2));
fig = yeni_sekil; plot(o1.aci.Time, rad2deg(o1.aci.Data), '--'); hold on; plot(o2.aci.Time, rad2deg(o2.aci.Data)); yline(60,':'); grid on;
legend('PD (kp=40, kd=2)','PID (kp=200, ki=400, kd=8)','Location','southeast'); xlabel('zaman [s]'); ylabel('dirsek [°]'); title('İntegral terimi yerçekimini yeniyor'); sekil(fig,'4.2','pd-pid');
komut('4.2','olcut', {'kp = 200; ki = 400; kd = 8;', 'o = sim("dirsek_pid");', '[asim, yerlesme, kalici] = adim_bilgi(o.aci.Time, o.aci.Data, hedef)', 'max(abs(o.tork.Data))'});
%% 4.3 Üç ayar: ölçerek karşılaştırmak
ay = {'Isaac PD', 40, 0, 2; 'PID sert', 150, 300, 6; 'PID ayarlı', 200, 400, 8}; tab = cell(3,5); fig = yeni_sekil; hold on;
eklem_model('dirsek_pid', 'pid');
for i = 1:3
    if i == 3, set_param('dirsek_pid/Denetleyici','LimitOutput','on','UpperSaturationLimit','efor','LowerSaturationLimit','-efor','AntiWindupMode','clamping'); end
    assignin('base','kp',ay{i,2}); assignin('base','ki',ay{i,3}); assignin('base','kd',ay{i,4});
    o = sim('dirsek_pid'); [a, ts, e] = adim_bilgi(o.aci.Time, o.aci.Data, deg2rad(60)); plot(o.aci.Time, rad2deg(o.aci.Data));
    if isinf(ts), ts = -1; end; tab(i,:) = {ay{i,1}, round(a,1), round(ts,2), round(e,2), round(max(abs(o.tork.Data)),1)};
end
yline(60,':'); grid on; legend(ay(:,1),'Location','southeast'); xlabel('zaman [s]'); ylabel('dirsek [°]'); title('Aynı eklem, üç ayar (yük 0.2 kg)'); sekil(fig,'4.3','uc-ayar');
T3 = cell2table(tab,'VariableNames',{'ayar','asim_yuzde','yerlesme_s','kalici_yuzde','tork_max_Nm'}); writetable(T3, fullfile(lab_kok,'cikti','ayar_karsilastirma.csv'));
assignin('base','T3',T3); komut('4.3','tablo', {'T3'}); olc('d4_3_tablo', tab); close_system('dirsek_pid',0);
%% 4.4 Bitirme: çay servisindeki dirsek hareketini izlemek
eklem_model('dirsek_izle', 'izle'); model_ciz('dirsek_izle','4.4','izleme-model'); set_param('dirsek_izle','StopTime','113.3');
assignin('base','aci0',K(1,4)); den = {'Isaac PD', 40, 0, 2; 'PID ayarlı', 200, 400, 8}; sonuc = struct; fig = yeni_sekil; hold on;
plot(K(:,1), rad2deg(K(:,4)), 'k', 'LineWidth', 1);
for i = 1:2
    if i == 2, set_param('dirsek_izle/Denetleyici','LimitOutput','on','UpperSaturationLimit','efor','LowerSaturationLimit','-efor','AntiWindupMode','clamping'); end
    assignin('base','kp',den{i,2}); assignin('base','ki',den{i,3}); assignin('base','kd',den{i,4});
    o = sim('dirsek_izle'); ri = interp1(K(:,1), K(:,4), o.aci.Time); h = rad2deg(ri - o.aci.Data);
    rms_ = sqrt(mean(h.^2)); tmax = max(abs(o.tork.Data)); gecti = rms_ < 1 && tmax <= 25;
    sonuc(i).ayar = den{i,1}; sonuc(i).rms_hata_derece = round(rms_,2); sonuc(i).en_buyuk_hata_derece = round(max(abs(h)),2); sonuc(i).tork_max_Nm = round(tmax,2); sonuc(i).gecti = gecti;
    plot(o.aci.Time, rad2deg(o.aci.Data));
end
grid on; xlabel('zaman [s]'); ylabel('dirsek [°]'); xlim([0 113.3]);
legend('kayıt (benzetim)', sprintf('Isaac PD: ortalama hata %.2f° — %s', sonuc(1).rms_hata_derece, ternary(sonuc(1).gecti)), sprintf('PID ayarlı: %.2f° — %s', sonuc(2).rms_hata_derece, ternary(sonuc(2).gecti)), 'Location','southoutside');
title('Bitirme: kayıttaki dirsek hareketini izlemek'); sekil(fig,'4.4','bitirme-izleme');
olc('d4_4_sonuc', sonuc); assignin('base','sonuc',struct2table(sonuc)); komut('4.4','bitirme-test', {'sonuc'});
close_system('dirsek_izle',0); disp('HAFTA4 TAMAM');
function s = ternary(g), if g, s = 'GEÇTİ'; else, s = 'KALDI'; end, end
