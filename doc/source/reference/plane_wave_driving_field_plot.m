addpath('../../..');
addpath('../../../examples/reference');

set(0,'DefaultAxesColorOrder',[0 0 0; 0 0 1],...
      'DefaultAxesLineStyleOrder','-|--|:|-.')

example_plane_wave_driving_field

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperSize',[12,12])
set(gcf,'PaperPosition',[0,0,12,12])
print('plane_wave_driving_field.png','-dpng')
