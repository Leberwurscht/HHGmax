addpath('../../../');
addpath('../../../examples/tutorial/single_atom');

dipole_spectrum

set(gcf,'PaperUnits','centimeters')
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperSize',[10,12])
set(gcf,'PaperPosition',[0,0,10,12])
print('single_atom.png','-dpng')
