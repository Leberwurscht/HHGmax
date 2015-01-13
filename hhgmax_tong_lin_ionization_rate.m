function rate_SI = hhgmax_tong_lin_ionization_rate(E_SI, config)
% Calculates the static field ionization rate using the empirical formula
% proposed by Tong, Lin (2005), which is the ADK formula with a correction
% for higher field strengths.
%
% Parameters:
%   E_SI - the field strength of the static electric field in SI units, i.e.
%          V/m; can be an array
%   config - struct() of following fields:
%     config.atom - The element to get the ionization rate for; currently
%                   supported is 'Xe','Ar','Ne', or 'He'
%     config.m (optional) - the magnetic quantum number, default is 0
%     config.Z (optional) - the charge seen by the electron in e, default is 1
%     config.C, config.l config.ionization_potential (optional) -
%       instead of config.atom, you can specify the necessary parameters C_l,
%       l, and I_p, respectively
%     config.alpha (optional) - the constant alpha used in the Tong, Lin (2005)
%                               correction; if not provided, it is derived from
%                               config.atom argument or if not present, set to
%                               zero, i.e. the correction is not applied.
%
% Return values:
%   returns the ionization rate in SI units, i.e. 1/s, in an array with the
%   same size as the argument E_SI

%%% ----- parse arguments ----- %%%
m = 0;
if isfield(config, 'm')
  m = config.m;
end

Z = 1;
if isfield(config, 'Z')
  Z = config.Z;
end

% table II of Tong, Zhao, Lin (2002)
% alpha values as suggested in penultimate paragraph of p. 2596, Tong, Lin (2005)
if isfield(config,'atom')
  if strcmpi(config.atom, 'Xe')
    Ip_eV = 12.13;
    C = 2.57;
    l = 1;
    Z = 1;
    alpha = 9.0;
  elseif strcmpi(config.atom, 'Ar')
    Ip_eV = 15.762;
    C = 2.44;
    l = 1;
    Z = 1;
    alpha = 9.0;
  elseif strcmpi(config.atom, 'Ne')
    Ip_eV = 21.565;
    C = 2.10;
    l = 1;
    Z = 1;
    alpha = 9.0;
  elseif strcmpi(config.atom, 'He')
    Ip_eV = 24.5872;
    C = 3.13;
    l = 0;
    Z = 1;
    alpha = 6.0;
  elseif strcmpi(config.atom, 'Kr')
    Ip_eV = 14.0;
    C = 2.49;
    l = 1;
    Z = 1;
    alpha = 9.0;
  else
    error('Atom not implemented.');
  end
else
  C = config.C;
  l = config.l;
  Ip_eV = config.ionization_potential;
end

if isfield(config,'alpha')
  alpha = config.alpha;
elseif ~isfield(config,'atom')
  alpha = 0;
end

%%% ----- implement formula ----- %%%

% convert to atomic units
Ip = Ip_eV*1.602176565e-19 / 4.35974417e-18; % ionization potential
F = sqrt( sum(real(E_SI).^2, 1) ) / 5.14220652e11; % field strength |\vec E|

% implement (2) and (3) of Tong, Lin, 2005
kappa = sqrt(2*Ip);
rate = C^2 /2^abs(m) /factorial(abs(m))...
     * (2*l+1)*factorial(l+abs(m)) /2 /factorial(l-abs(m))...
     * 1 / kappa^( 2*Z/kappa - 1 )...
     * (2*kappa^3 ./ F) .^ ( 2*Z/kappa - abs(m) - 1 )...
    .* exp( -2/3 * kappa^3./F )...
    .* exp( -alpha * (Z^2/Ip) * (F/kappa^3) ); % correction

%figure(15)
%plot(E_SI,rate);
%title('ionization rate in a.u.')
%xlabel('E (SI)')

% convert back to SI units
rate_SI = rate * (1/2.418884326505e-17);

% fix division by zero error
rate_SI(E_SI==0) = 0;
