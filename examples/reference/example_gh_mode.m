% for executing, copy to main folder or use addpath

% load HHGmax
hhgmax = hhgmax_load();

% set wave number (assuming lambda=1um)
k = 2*pi/1e-3; % mm^-1

% configure 3 different modes
 % Gaussian beam
 config1 = struct();
 config1.beam_waist = 0.010; % mm
 config1.mode = 'TEM00';

 % a predefined mode
 config2 = struct();
 config2.beam_waist = 0.010; % mm
 config2.mode = '1d-quasi-imaging';

 % a custom mode
 config3 = struct();
 config3.beam_waist = 0.010; % mm
 config3.mode_n = [0 2 0];
 config3.mode_m = [0 0 3];
 config3.mode_coefficients = [sqrt(3/10) -1i*sqrt(5/10) sqrt(2/10)];

% setup grid
xv = -0.02:0.001:0.02; yv = -0.02:0.001:0.02;
[x,y] = meshgrid(xv, yv);

% plot each mode at three different z positions:
%  at focus, one Rayleigh range behind focus, far from focus
z_R = k*config1.beam_waist^2/2;

subplot_nr = 1;
for config={config1, config2, config3}; config=config{1};
  % compute field at z=0, z=z_R, z=100*z_R
  field_0 = hhgmax.gh_mode(x,y,0, k, config);
  field_z_R = hhgmax.gh_mode(x,y,z_R, k, config);
  field_far = hhgmax.gh_mode(100*x,100*y,100*z_R, k, config);

  % plot fields
  subplot(3,3,subplot_nr); subplot_nr = subplot_nr+1;
  imagesc(xv,yv,abs(field_0).^2);
  title('z=0');
  axis off;

  subplot(3,3,subplot_nr); subplot_nr = subplot_nr+1;
  imagesc(xv,yv,abs(field_z_R).^2);
  title('z=z_R');
  axis off;

  subplot(3,3,subplot_nr); subplot_nr = subplot_nr+1;
  imagesc(100*xv,100*yv,abs(field_far).^2);
  title('far field');
  axis off;
end
