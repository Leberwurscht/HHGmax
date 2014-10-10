addpath('../../..');
addpath('../../../examples/reference');

example_harmonic_propagation

colormap(hot);

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperSize',[10,9])
set(gcf,'PaperPosition',[0,0,10,9])
print('harmonic_propagation.png','-dpng')
