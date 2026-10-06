function eklem_model(mdl, secenek)
% G1 dirsek eklemi (basitleştirilmiş tek eklem): J*θ'' = τ − yerçekimi.
% secenek: 'pd' (Isaac PD), 'pid' (PID Controller bloğu), 'izle' (kayıttaki yörüngeyi izle)
if bdIsLoaded(mdl), close_system(mdl,0); end
if exist([mdl '.slx'],'file'), delete([mdl '.slx']); end
new_system(mdl);
if strcmp(secenek,'izle')
    add_block('simulink/Sources/From Workspace',[mdl '/Kayıt (dirsek)'],'VariableName','ref','Interpolate','on','Position',[20 88 100 122]);
    kaynak = 'Kayıt (dirsek)';
else
    add_block('simulink/Sources/Step',[mdl '/Hedef'],'Time','0','After','hedef','Position',[40 90 70 120]); kaynak = 'Hedef';
end
add_block('simulink/Math Operations/Sum',[mdl '/Hata'],'Inputs','+-','IconShape','rectangular','Position',[130 90 150 120]);
if strcmp(secenek,'pd')
    add_block('simulink/Continuous/PID Controller',[mdl '/Denetleyici'],'Controller','PD','P','kp','D','kd','N','1000','Position',[190 85 260 125]);
else
    add_block('simulink/Continuous/PID Controller',[mdl '/Denetleyici'],'P','kp','I','ki','D','kd','N','1000','Position',[190 85 260 125]);
end
add_block('simulink/Discontinuities/Saturation',[mdl '/Tork sınırı ±25 N·m'],'UpperLimit','efor','LowerLimit','-efor','Position',[300 90 340 120]);
add_block('simulink/Math Operations/Sum',[mdl '/Net tork'],'Inputs','++','IconShape','rectangular','Position',[390 90 410 120]);
add_block('simulink/Math Operations/Gain',[mdl '/Ters eylemsizlik'],'Gain','1/(J + yuk*0.3^2)','Position',[440 90 500 120]);
add_block('simulink/Continuous/Integrator',[mdl '/Açısal hız'],'InitialCondition','0','Position',[540 90 570 120]);
add_block('simulink/Continuous/Integrator',[mdl '/Açı'],'InitialCondition','aci0','Position',[610 90 640 120]);
add_block('simulink/User-Defined Functions/Fcn',[mdl '/Yerçekimi torku'],'Expr','(mgr + 9.81*yuk*0.3)*cos(u(1))','Orientation','left','Position',[420 180 520 210]);
add_block('simulink/Sinks/To Workspace',[mdl '/aci'],'VariableName','aci','SaveFormat','Timeseries','Position',[700 90 750 120]);
add_block('simulink/Sinks/To Workspace',[mdl '/tork'],'VariableName','tork','SaveFormat','Timeseries','Position',[300 160 350 190]);
add_line(mdl,[kaynak '/1'],'Hata/1','autorouting','on'); add_line(mdl,'Hata/1','Denetleyici/1','autorouting','on'); add_line(mdl,'Denetleyici/1','Tork sınırı ±25 N·m/1','autorouting','on');
add_line(mdl,'Tork sınırı ±25 N·m/1','Net tork/1','autorouting','on'); add_line(mdl,'Net tork/1','Ters eylemsizlik/1','autorouting','on'); add_line(mdl,'Ters eylemsizlik/1','Açısal hız/1','autorouting','on');
add_line(mdl,'Açısal hız/1','Açı/1','autorouting','on'); add_line(mdl,'Açı/1','aci/1','autorouting','on');
add_line(mdl,'Açı/1','Yerçekimi torku/1','autorouting','on'); add_line(mdl,'Yerçekimi torku/1','Net tork/2','autorouting','on');
add_line(mdl,'Açı/1','Hata/2','autorouting','on'); add_line(mdl,'Tork sınırı ±25 N·m/1','tork/1','autorouting','on');
set_param(mdl,'Solver','ode45','MaxStep','0.002','StopTime','2'); save_system(mdl);
end
