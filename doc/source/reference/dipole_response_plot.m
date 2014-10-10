addpath('../../..');
addpath('../../../examples/reference');

example_dipole_response

set(gcf,'PaperUnits','centimeters')
%set(gcf,'PaperOrientation','');
set(gcf,'PaperSize',[14,14])
set(gcf,'PaperPosition',[0,0,14,14])
print('dipole_response.png','-dpng')
