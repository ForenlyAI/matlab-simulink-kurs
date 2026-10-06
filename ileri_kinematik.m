function [x, z] = ileri_kinematik(L1, L2, omuz, dirsek)
% G1 kolu, yandan: omuz 0 -> üst kol aşağı, dirsek 0 -> ön kol ileri; artı açı aşağı döndürür (radyan)
x = -L1*sin(omuz) + L2*cos(omuz + dirsek);
z = -L1*cos(omuz) - L2*sin(omuz + dirsek);
end
