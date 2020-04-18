function run_core()
% Generate the core (ferrite) material data.
%
%    Map the different materials with a unique id.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init
addpath(genpath('utils'))

% parse data
data = {};
data{end+1} = get_data('N49');
data{end+1} = get_data('N87');
data{end+1} = get_data('N95');
data{end+1} = get_data('N97');
data{end+1} = get_data('N87_meas');

% material type
type = 'core';

% save material
save('data/core_data.mat', '-v7.3', 'data', 'type')

end

function data = get_data(id)
% Generate the core (ferrite) material data.
%
%    Parameters:
%        id (int): material id
%
%    Returns:
%        data (struct): material id and data

% get values
switch id
    case 'N49'
        rho = 4750;
        kappa = 12.5;
        data_map = load('loss_map/N49_ac.mat');
        data_bias = load('loss_map/N87_ac_dc.mat');
    case 'N87'
        rho = 4850;
        kappa = 7.0;
        data_map = load('loss_map/N87_ac.mat');
        data_bias = load('loss_map/N87_ac_dc.mat');
    case 'N87_meas'
        rho = 4850;
        kappa = 7.0;
        data_map = load('loss_map/N87_ac_dc_wide.mat');
        data_bias = load('loss_map/N87_ac_dc_wide.mat');
    case 'N95'
        rho = 4900;
        kappa = 9.5;
        data_map = load('loss_map/N95_ac.mat');
        data_bias = load('loss_map/N87_ac_dc.mat');
    case 'N97'
        rho = 4850;
        kappa = 7.5;
        data_map = load('loss_map/N97_ac.mat');
        data_bias = load('loss_map/N87_ac_dc.mat');
    otherwise
        error('invalid id')
end

% assign param
material.param.rho = rho; % volumetric density
material.param.kappa = kappa; % cost per mass

% assign constant
material.param.fact_igse = 0.1; % factor for computing alpha and beta for IGSE (gradient in log scale)
material.param.B_sat_max = 320e-3; % saturation flux density
material.param.P_max = 1000e3; % maximum loss density
material.param.P_scale = 1.1; % scaling factor for losses
material.param.T_max = 130.0; % maximum temperature
material.param.c_offset = 0.3; % cost offset

% add values for losses interpolations
material.interp.f_vec = logspace(log10(25e3), log10(1e6), 20);  % frequency vector
material.interp.B_ac_peak_vec = logspace(log10(2.5e-3), log10(250e-3), 20); % AC flux density vector
material.interp.B_dc_vec = 0e-3:10e-3:320e-3; % DC flux density vector
material.interp.T_vec = 20:10:140;  % temperature vector

% use (or not) the a correction factor for the DC bias
param.use_bias = true; 

% extrapolation for the loss map
%    - P: limit on the extrapolated losses
%    - f: limit the frequency for extrapolation
%    - B_ac_peak: limit the AC flux density for extrapolation
%    - B_dc: limit the DC flux density for extrapolation
%    - T: limit the temperature for extrapolation
param.extrap_map.P = [];
param.extrap_map.f = [];
param.extrap_map.B_ac_peak = [];
param.extrap_map.B_dc = [];
param.extrap_map.T = [];

% extrapolation for the correction factor for the DC bias
%    - fact: limit limit the DC bias correction
%    - f: limit the frequency for extrapolation
%    - B_ac_peak: limit the AC flux density for extrapolation
%    - B_dc: limit the DC flux density for extrapolation
%    - T: limit the temperature for extrapolation..
param.extrap_bias.fact = [1.0 4.0];
param.extrap_bias.f = [10e3 270e3];
param.extrap_bias.B_ac_peak = [15e-3 320e-3];
param.extrap_bias.B_dc = [15e-3 320e-3];
param.extrap_bias.T = [25.0 100.0];

% interpolate losses
material.interp.P_mat = get_loss_map(data_map, data_bias, param, material.interp); % loss matrix
   
% assign
id = get_map_str_to_int(id);
data = struct('id', id, 'material', material);

end