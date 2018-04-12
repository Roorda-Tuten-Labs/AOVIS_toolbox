

params = light_capture.gen_default_params();
% check that params is a struct.
assert(isstruct(params),['Params returned ' class(params) ' instead of struct'])
    
params = light_capture.compute_field_size(params);
assert(isfield(params, 'field_size'),'params did not return with field_size field')
assert(isfloat(params.field_size), ['params.field_size returned as '...
    class(params.field_size) ' instead of double']);

params = light_capture.gen_stimulus(params);


params = light_capture.GeneratePSF(params);
params = light_capture.gen_retina_image(params);
model_data = light_capture.model(params);