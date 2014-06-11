addpath('../../../');
addpath('../../../examples/tutorial/gaussian_beams');

dipole_spectrum

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperSize',[20,20])
set(gcf,'PaperPosition',[0,0,20,20])
print('gaussian_beams.png','-dpng')
