addpath('../../../');
addpath('../../../examples/tutorial/pulses');

dipole_spectrum

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperSize',[18,12])
set(gcf,'PaperPosition',[0,0,18,12])
print('pulses.png','-dpng')
