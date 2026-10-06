% Tüm laboratuvarı koşar; günlük cikti/kosum.log, bitince cikti/BITTI.txt
k = fileparts(mfilename('fullpath')); addpath(k); cd(k);
for d = {'cikti','modeller','ekran'}, if ~exist(fullfile(k,d{1}),'dir'), mkdir(fullfile(k,d{1})); end, end
if exist(fullfile(k,'cikti','BITTI.txt'),'file'), delete(fullfile(k,'cikti','BITTI.txt')); end
diary(fullfile(k,'cikti','kosum.log')); diary on;
fprintf('%s\n%s\n', version, datestr(now));
for h = 1:4
    try
        run(fullfile(k, sprintf('hafta%d.m', h)));
    catch e
        fprintf(2, 'HAFTA%d HATA: %s\n', h, getReport(e, 'extended', 'hyperlinks', 'off'));
    end
    k = fileparts(mfilename('fullpath')); cd(k); bdclose all; close all force;
end
diary off;
f = fopen(fullfile(k,'cikti','BITTI.txt'),'w'); fprintf(f,'bitti %s\n', datestr(now)); fclose(f);
