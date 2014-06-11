addpath('../../../');
addpath('../../../examples/tutorial/resources');

efield

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperSize',[12,13])
set(gcf,'PaperPosition',[0,0,12,13])
print('resources.png','-dpng')
