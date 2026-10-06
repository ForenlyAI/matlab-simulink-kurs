% Yeni derslerin laboratuvarını koşar (Ders 1.2, 1.3, 1.4, 2.3, 3.1, 4.1, 4.2, 4.3); günlük cikti/kosum.log, bitince cikti/BITTI.txt
k = fileparts(mfilename('fullpath')); addpath(k); cd(k);
if exist(fullfile(k,'cikti','BITTI.txt'),'file'), delete(fullfile(k,'cikti','BITTI.txt')); end
diary(fullfile(k,'cikti','kosum.log')); diary on; fprintf('%s\n%s\n', version, datestr(now));
for h = {'hafta1.m', 'hafta234.m'}
    try, run(fullfile(k, h{1}));
    catch e, fprintf(2, '%s HATA: %s\n', h{1}, getReport(e, 'extended', 'hyperlinks', 'off')); end
    k = fileparts(which('lab_kok')); cd(k); bdclose all; close all force;
end
diary off; f = fopen(fullfile(k,'cikti','BITTI.txt'),'w'); fprintf(f,'bitti %s\n', datestr(now)); fclose(f);
