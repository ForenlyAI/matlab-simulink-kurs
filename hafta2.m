% Hafta 2 — Veri ve Hesap. Veri: Forenly G1 kıraathane benzetimi + W&B π0.5 eğitimi.
V = fullfile(lab_kok,'veri'); evalin('base', sprintf('cd(''%s'')', V)); format short g;
H = fullfile(V,'cay_servisi_kd_v017_81_0013.hdf5');
%% 2.1 HDF5 kaydını okumak
assignin('base','dosya','cay_servisi_kd_v017_81_0013.hdf5');
komut('2.1','hdf5', {'q = h5read(dosya, "/data/demo_0/states/articulation/robot/joint_position");', 'size(q)', 'dirsek = q(23, :);', 'sure = (size(q,2) - 1) * 0.02', 'basari = h5read(dosya, "/data/demo_0/success")'});
q = h5read(H,'/data/demo_0/states/articulation/robot/joint_position'); olc('d2_1_boyut', size(q)); olc('d2_1_sure', (size(q,2)-1)*0.02);
K = readmatrix(fullfile(V,'cay_servisi_kaydi.csv')); olc('d2_1_csv_fark', max(abs(double(q(23,:))' - K(:,4))));
fig = yeni_sekil; imagesc(K(:,1), 1:53, rad2deg(double(q))); colorbar; xlabel('zaman [s]'); ylabel('eklem no'); title('53 eklemin açısı [°] — çay servisi kaydı (HDF5)'); sekil(fig,'2.1','eklem-haritasi');
%% 2.2 Döngü ve koşul: bardak ne zaman kalktı?
z = K(:,9); t = K(:,1); assignin('base','z',z); assignin('base','t',t);
blok = sprintf('esik = z(1) + 0.03;\nkalkti = false;\nfor i = 1:numel(z)\n    if ~kalkti && z(i) > esik\n        kalkti = true;\n        baslangic = t(i)\n    end\nend');
d = fullfile(lab_kok,'ekran','2.2'); if ~exist(d,'dir'), mkdir(d); end; f = fopen(fullfile(d,'dongu.txt'),'w','n','UTF-8');
fprintf(f, '>> %s\n', strrep(blok, newline, [newline '   ']));
fprintf(f, '%s', evalin('base', sprintf('evalc(%s)', mat2str(blok))));
fprintf(f, '>> havada_sure = sum(z > esik) * 0.02\n%s', evalin('base','evalc(''havada_sure = sum(z > esik) * 0.02'')'));
fprintf(f, '>> en_hizli = max(abs(K(:,6)))\n'); assignin('base','K',K); fprintf(f, '%s', evalin('base','evalc(''en_hizli = max(abs(K(:,6)))'')')); fclose(f);
es = z(1) + 0.03; i0 = find(z > es, 1); olc('d2_2_kalkis', t(i0)); olc('d2_2_havada', sum(z > es)*0.02); olc('d2_2_dirsek_hiz_max', round(max(abs(K(:,6))),2));
fig = yeni_sekil; plot(t, z); hold on; yline(es,'--r','eşik: başlangıç + 3 cm','FontSize',14); xline(t(i0),':','kalkış','FontSize',14); grid on;
xlabel('zaman [s]'); ylabel('bardak yüksekliği z [m]'); title(sprintf('Bardak %.2f s''de kalktı, %.1f s havada kaldı', t(i0), sum(z>es)*0.02)); sekil(fig,'2.2','bardak-kalkis');
%% 2.3 ode45: dirsek eklemi PD denetimi (Isaac kazançları kp=40, kd=2)
m = [0.6 0.0854 0.484 0.226 0.4]; r = [0.065 0.117 0.161 0.26 0.30]; J = sum(m .* r.^2) + 0.03;
assignin('base','m',m); assignin('base','r',r); assignin('base','J',J);
komut('2.3','eylemsizlik', {'m = [0.6 0.0854 0.484 0.226 0.4];', 'r = [0.065 0.117 0.161 0.26 0.30];', 'J = sum(m .* r.^2) + 0.03', 'kp = 40; kd = 2; hedef = deg2rad(60);', 'f = @(t,x) [x(2); (kp*(hedef - x(1)) - kd*x(2)) / J];', '[t, x] = ode45(f, [0 2], [0; 0]);', 'rad2deg(x(end,1))'});
kp = 40; kd = 2; hedef = deg2rad(60); f2 = @(t,x) [x(2); (kp*(hedef - x(1)) - kd*x(2))/J];
[ts, xs] = ode45(f2, [0 2], [0; 0]); save(fullfile(lab_kok,'cikti','ode45_sonuc.mat'),'ts','xs','J');
[a, ty, e] = adim_bilgi(ts, xs(:,1), hedef); olc('d2_3_J', round(J,4)); olc('d2_3_wn', round(sqrt(kp/J),2)); olc('d2_3_zeta', round(kd/(2*sqrt(kp*J)),3)); olc('d2_3_asim', round(a,1)); olc('d2_3_yerlesme', round(ty,2));
fig = yeni_sekil; plot(ts, rad2deg(xs(:,1))); hold on; yline(60,'--','hedef 60°','FontSize',14); grid on; xlabel('zaman [s]'); ylabel('dirsek açısı [°]');
title(sprintf('ode45 — dirsek PD: aşım %%%.0f', a)); sekil(fig,'2.3','ode45-dirsek');
%% 2.4 Eğitim kaybına eğri uydurmak (W&B, π0.5, 2500 adım)
E = readmatrix(fullfile(V,'egitim_kaybi.csv')); assignin('base','E',E);
komut('2.4','polyfit', {'E = readmatrix("egitim_kaybi.csv");', 'size(E)', 'p = polyfit(log10(E(:,1)), log10(E(:,2)), 1)', 'tahmin_5000 = 10^polyval(p, log10(5000))'});
p = polyfit(log10(E(:,1)), log10(E(:,2)), 1); olc('d2_4_egim', round(p(1),3)); olc('d2_4_ilk', E(1,2)); olc('d2_4_son', E(end,2)); olc('d2_4_tahmin5000', round(10^polyval(p,log10(5000)),5));
fig = yeni_sekil; loglog(E(:,1), E(:,2), 'o', 'MarkerSize',6); hold on; loglog(E(:,1), 10.^polyval(p, log10(E(:,1)))); grid on;
xlabel('eğitim adımı'); ylabel('kayıp'); legend('W&B ölçümü', sprintf('doğru: eğim %.2f', p(1))); title('π0.5 çay servisi eğitimi — kayıp eğrisi (log–log)'); sekil(fig,'2.4','egitim-kaybi');
disp('HAFTA2 TAMAM');
