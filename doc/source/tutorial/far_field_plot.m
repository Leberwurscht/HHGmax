addpath('../../../');
addpath('../../../examples/tutorial/farfield');

efield

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperSize',[12,13])
set(gcf,'PaperPosition',[0,0,12,13])
print('far_field.png','-dpng')
