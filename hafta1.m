% Hafta 1 — MATLAB Temelleri. Veri: Forenly G1 kıraathane benzetimi (veri/), Unitree G1 eklem kartı.
format short g; V = fullfile(lab_kok,'veri'); evalin('base', sprintf('cd(''%s'')', V));
%% 1.1 İlk komutlar: G1 dirsek sınırlarını dereceye çevirmek
komut('1.1','ilk-komutlar', {'alt = -1.0472', 'ust = 2.0944', 'alt_derece = rad2deg(alt)', 'ust_derece = rad2deg(ust)', 'aralik = ust_derece - alt_derece'});
komut('1.1','degiskenler', {'efor = 25;', 'kp = 40;', 'kd = 2;', 'whos'});
olc('d1_1_alt_derece', round(rad2deg(-1.0472),1)); olc('d1_1_ust_derece', round(rad2deg(2.0944),1));
%% 1.2 Vektör ve matris: sağ kolun dört ekleminin sınır tablosu
komut('1.2','sinir-matrisi', {'S = [-3.0892 2.6704; -2.2515 1.5882; -2.618 2.618; -1.0472 2.0944]', 'size(S)', 'aralik = S(:,2) - S(:,1)', 'rad2deg(aralik)''', '[en_genis, i] = max(aralik)'});
S = [-3.0892 2.6704; -2.2515 1.5882; -2.618 2.618; -1.0472 2.0944]; a = rad2deg(S(:,2)-S(:,1)); olc('d1_2_aralik_derece', round(a',1));
T = h5read(fullfile(V,'cay_servisi_kd_v017_81_0013.hdf5'), '/data/demo_0/obs/right_wrist_pose_pelvis_frame', [1 1 2000], [4 4 1]);
T = double(T)'; assignin('base','T',T);
komut('1.2','donusum-matrisi', {'T', 'R = T(1:3,1:3);', 'p = T(1:3,4)''', 'round(R'' * R, 6)', 'det(R)'});
olc('d1_2_bilek_konum', round(T(1:3,4)',3));
%% 1.3 Grafik: çay servisinde omuz ve dirsek açısı
K = readmatrix(fullfile(V,'cay_servisi_kaydi.csv'));
fig = yeni_sekil; plot(K(:,1), rad2deg(K(:,2))); hold on; plot(K(:,1), rad2deg(K(:,4))); grid on;
xlabel('zaman [s]'); ylabel('açı [°]'); legend('sağ omuz (roll)','sağ dirsek','Location','southwest'); title('G1 çay servisi — benzetim kaydı, sağ kol');
sekil(fig,'1.3','omuz-dirsek');
fig = yeni_sekil; subplot(2,1,1); plot(K(:,1), rad2deg(K(:,4))); grid on; ylabel('dirsek [°]'); title('dirsek açısı ve bardak yüksekliği');
subplot(2,1,2); plot(K(:,1), K(:,9), 'Color',[0.85 0.33 0.1]); grid on; ylabel('bardak z [m]'); xlabel('zaman [s]');
sekil(fig,'1.3','dirsek-bardak');
assignin('base','K',K); komut('1.3','grafik-komut', {'K = readmatrix("cay_servisi_kaydi.csv");', 'size(K)', 't = K(:,1); dirsek = rad2deg(K(:,4));', '[en_buyuk, i] = max(dirsek)', 't(i)'});
[mx, im] = max(rad2deg(K(:,4))); olc('d1_3_dirsek_max', round(mx,1)); olc('d1_3_dirsek_max_t', K(im,1)); olc('d1_3_satir', size(K,1));
%% 1.4 Fonksiyon: kolun uç noktası (G1 ölçüleri ve açı yönleri URDF'ten: dirsek 0 → ön kol ileri, artı açı aşağı)
fid = fopen(fullfile(lab_kok,'ileri_kinematik.m'),'w');
fprintf(fid,'function [x, z] = ileri_kinematik(L1, L2, omuz, dirsek)\n%% G1 kolu, yandan: omuz 0 -> üst kol aşağı, dirsek 0 -> ön kol ileri; artı açı aşağı döndürür (radyan)\nx = -L1*sin(omuz) + L2*cos(omuz + dirsek);\nz = -L1*cos(omuz) - L2*sin(omuz + dirsek);\nend\n'); fclose(fid); rehash;
komut('1.4','fonksiyon', {'type ileri_kinematik', 'L1 = 0.20; L2 = 0.18;', '[x, z] = ileri_kinematik(L1, L2, 0, 0)', '[x, z] = ileri_kinematik(L1, L2, 0, deg2rad(56.5))', '[x, z] = ileri_kinematik(L1, L2, 0, deg2rad(-60))'});
[x1,y1] = ileri_kinematik(0.20,0.18,0,0); [x2,y2] = ileri_kinematik(0.20,0.18,0,deg2rad(56.5)); [x3,y3] = ileri_kinematik(0.20,0.18,0,deg2rad(-60));
olc('d1_4_uc_0', round([x1 y1],3)); olc('d1_4_uc_565', round([x2 y2],3)); olc('d1_4_uc_eksi60', round([x3 y3],3));
fig = yeni_sekil; hold on;
for qq = deg2rad([-60 0 56.5])
    [xe, ye] = ileri_kinematik(0.20, 0, 0, 0); [xu, yu] = ileri_kinematik(0.20, 0.18, 0, qq);
    plot([0 xe xu], [0 ye yu], '-o', 'MarkerSize', 9, 'MarkerFaceColor', 'w');
end
axis equal; grid on; xlabel('ileri x [m]'); ylabel('yukarı z [m]'); legend('dirsek -60° (kayıttaki en küçük)','dirsek 0°','dirsek 56.5° (kayıttaki en büyük)','Location','southoutside','Orientation','horizontal');
title('G1 sağ kol (yandan): 0.20 m + 0.18 m'); sekil(fig,'1.4','kol-cizimi');
disp('HAFTA1 TAMAM');
