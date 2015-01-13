function ret = cache(xn,yn,zv,components,omegan,config,metadata)

if exist('config','var') && isfield(config,'directory')
  if ~exist('metadata','var')
    error('file backend needs a metadata argument');
  end
  ret = cache_file(xn,yn,zv,components,omegan,config,metadata);
else
  ret = cache_ram(xn,yn,zv,components,omegan);
end
