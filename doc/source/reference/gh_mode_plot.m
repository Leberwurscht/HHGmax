addpath('../../..');
addpath('../../../examples/reference');

example_gh_mode

colormap(hot);

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperSize',[10,12])
set(gcf,'PaperPosition',[0,0,10,12])
print('gh_mode.png','-dpng')
