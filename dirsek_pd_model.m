function dirsek_pd_model(mdl, gercekci)
% Dirsek eklemi, PD (Isaac gibi: kp·hata − kd·açısal hız). gercekci=true: tork sınırı ±efor + yerçekimi torku eklenir.
if bdIsLoaded(mdl), close_system(mdl,0); end
if exist([mdl '.slx'],'file'), delete([mdl '.slx']); end
new_system(mdl);
add_block('simulink/Sources/Step',[mdl '/Hedef'],'Time','0','After','hedef','Position',[30 90 60 120]);
add_block('simulink/Math Operations/Sum',[mdl '/Hata'],'Inputs','+-','IconShape','rectangular','Position',[110 90 130 120]);
add_block('simulink/Math Operations/Gain',[mdl '/kp'],'Gain','kp','Position',[170 90 210 120]);
add_block('simulink/Math Operations/Sum',[mdl '/Tork'],'Inputs','+-','IconShape','rectangular','Position',[250 90 270 120]);
son = 'Tork';
if gercekci
    add_block('simulink/Discontinuities/Saturation',[mdl '/Tork sınırı'],'UpperLimit','efor','LowerLimit','-efor','Position',[300 90 340 120]);
    add_block('simulink/Math Operations/Sum',[mdl '/Net tork'],'Inputs','++','IconShape','rectangular','Position',[370 90 390 120]);
    add_line(mdl,'Tork/1','Tork sınırı/1','autorouting','on'); add_line(mdl,'Tork sınırı/1','Net tork/1','autorouting','on'); son = 'Net tork';
end
add_block('simulink/Math Operations/Gain',[mdl '/Ters eylemsizlik'],'Gain','1/(J + yuk*0.3^2)','Position',[430 90 490 120]);
add_block('simulink/Continuous/Integrator',[mdl '/Açısal hız'],'InitialCondition','0','Position',[530 90 560 120]);
add_block('simulink/Continuous/Integrator',[mdl '/Açı'],'InitialCondition','0','Position',[600 90 630 120]);
add_block('simulink/Math Operations/Gain',[mdl '/kd'],'Gain','kd','Orientation','left','Position',[400 170 440 200]);
add_block('simulink/Sinks/To Workspace',[mdl '/aci'],'VariableName','aci','SaveFormat','Timeseries','Position',[690 90 740 120]);
add_line(mdl,'Hedef/1','Hata/1','autorouting','on'); add_line(mdl,'Hata/1','kp/1','autorouting','on'); add_line(mdl,'kp/1','Tork/1','autorouting','on'); add_line(mdl,[son '/1'],'Ters eylemsizlik/1','autorouting','on');
add_line(mdl,'Ters eylemsizlik/1','Açısal hız/1','autorouting','on'); add_line(mdl,'Açısal hız/1','Açı/1','autorouting','on'); add_line(mdl,'Açı/1','aci/1','autorouting','on');
add_line(mdl,'Açısal hız/1','kd/1','autorouting','on'); add_line(mdl,'kd/1','Tork/2','autorouting','on'); add_line(mdl,'Açı/1','Hata/2','autorouting','on');
if gercekci
    add_block('simulink/User-Defined Functions/Fcn',[mdl '/Yerçekimi torku'],'Expr','(mgr + 9.81*yuk*0.3)*cos(u(1))','Orientation','left','Position',[400 240 500 270]);
    add_line(mdl,'Açı/1','Yerçekimi torku/1','autorouting','on'); add_line(mdl,'Yerçekimi torku/1','Net tork/2','autorouting','on');
    add_block('simulink/Sinks/To Workspace',[mdl '/tork kaydı'],'VariableName','tork','SaveFormat','Timeseries','Position',[300 160 350 190]);
    add_line(mdl,'Tork sınırı/1','tork kaydı/1','autorouting','on');
end
set_param(mdl,'Solver','ode45','MaxStep','0.002','StopTime','2'); save_system(mdl);
end
