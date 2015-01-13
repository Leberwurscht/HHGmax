function [omega, keep] = hhgmax_get_omega_axis(t_cmc, config)

deltat = t_cmc(2)-t_cmc(1);
domega = 2*pi/deltat/length(t_cmc);
temp = (0:length(t_cmc)-1);
temp(temp>length(temp)/2) = temp(temp>length(temp)/2) - length(temp);
omega = temp * domega;


if exist('config','var') && isfield(config, 'omega_ranges')
  if isfield(config, 'raw') && config.raw
    error('omega_ranges option not possible in raw mode')
  end

  assert(size(config.omega_ranges,2)==2);
  keep = [];
  for r_i=1:size(config.omega_ranges,1)
    from = config.omega_ranges(r_i,1);
    to = config.omega_ranges(r_i,2);
    if to>max(omega)
      error(['Need finer t axis to be able to give data for omega range [' num2str([from to]) '].'])
    end
    keep = [keep find(omega>=from & omega<=to)];
  end
elseif exist('config','var') && isfield(config, 'raw') && config.raw
  keep = 1:length(omega);
else
  keep = find(omega>=0);
end

omega = omega(keep);
