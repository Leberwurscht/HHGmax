addpath('../../..');
addpath('../../../examples/reference');

example_farfield

colormap(brighten(hot,.5));

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperSize',[10,9])
set(gcf,'PaperPosition',[0,0,10,9])
print('farfield.png','-dpng')
