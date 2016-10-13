function g=egm08_interp(lat,lon,ht,varargin)
%this function interpolates from a series of EGM08 full field 2.5' x 2.5' grid files
%
%USAGE
%g=emg08_interp(lat,lon,ht)
%g=egm08_interp(lat,lon,ht,grid)
%
%INPUT
%   lat ARRAY latitude in degrees +90:-90
%   lon ARRAY longitude in degrees 0:360
%   ht ARRAY ellipsoidal height in meters up to 12000m
%   grid string indicated which grid(s) to interpolate from
%           'upper' the grid above median ht of data
%           'lower' the grid below median ht of data (default)
%           'both' both the upper and lower grids
%           'closest' whichever grid is closest to median ht of data
%
%OUPUT
%   g ARRAY full field gravity in mgals agrees with full harmonic synthesis
%       generation to +- 1mgal when using the 'lower' grid option
%
%NOTE
%   this function uses grids generated at the following ellipsoidal
%   heights: 0m, 2000m, 4000m, 6000m, 8000m, 10000m, and 12000m. The bulk
%   of the error comes from the free air correction. If higher precision is
%   needed closer spaced grids should be used or a better up/downward
%   continuation should be used. If storage space is an issue grids can be
%   spaced farther appart in height at the cost of precision.
%
%Created by Sandra Preaux Feb 2012
%Modified to also read in and interpolate EGM08 Deflections of the Vertical

%% initialize
%make sure lon is 0:360 not -180:180
temp=find(lon<0);
if ~isempty(temp) %lon is -180:180
    lon(temp)=360+lon(temp);
end
%get/set grid option
if nargin<4
    grid_str='lower';
else 
    grid_str=varargin{1};
end

%grid specs
cell_size=2.5/60; %grid cell size in degrees;

glat=(90-(cell_size/2)):-(cell_size):(-90+(cell_size/2)); %latitude elements
glon=(cell_size/2):(cell_size):(360-(cell_size/2)); %longitude elements

%get path to grids & creat list of grid files
global geo_data_path
if isempty(geo_data_path)
geo_data_path=uigetdir('','Select the folder where geodata folders can be found.');
end

p=[geo_data_path,'\EGM08_2.5x2.5_grid\'];
%p=[geo_data_path,'\EGM08_2.5x2.5_DOV_grid\'];

grid_ht=[0,2000,4000,6000,8000,10000,12000];
egm08_fnames=cell(1,length(grid_ht));
for i=1:length(grid_ht)
    egm08_fnames{i}=['grid_',num2str(grid_ht(i))];
end

%% get values from grids
%find indecies to retrieve from each grid height
ind=cell(1,length(grid_ht));
ind{1}=find(ht<=grid_ht(2)); %note any ht < lowest grid ht are included here
for i=2:(length(grid_ht)-1)
    ind{i}=find(ht>grid_ht(i-1) & ht<=grid_ht(i+1));
end
ind{end}=find(ht>grid_ht(end-1)); %note any ht> highest grid ht are included here

%pre-allocate lower and upper grid values & height differences
lower_g=ones(size(lat));
upper_g=lower_g;
lower_ht=lower_g;
upper_ht=lower_g;

%get values for each grid
for i=1:length(ind)
    if ~isempty(ind{i})
        ckeep=find(glat>=(min(lat(ind{i}))-10) & glat<=(max(lat(ind{i}))+10));
        rkeep=find(glon>=(min(lon(ind{i}))-10) & glon<=(max(lon(ind{i}))+10));
        
        fid=fopen([p,egm08_fnames{i}],'r','b');
        %pre-allocate A
        A=zeros(length(rkeep),length(ckeep));
        
        %skip latitudes south of min(lat)-1
        for j=1:(ckeep(1)-1)
            temp=fread(fid,[length(glon),1],'real*8');
        end
        %read lats over area and extract long to keep
        for j=1:length(ckeep)
            temp=fread(fid,[length(glon),1],'real*8');
            A(:,j)=temp(rkeep,1);
            clear temp
        end
        fclose(fid);
        
        % flip matrix and pull values of g at lat lon
        A=flipud(A');
        R=[1/cell_size glat(ckeep(1)) glon(rkeep(1))];
        
        %interp using interp2 cubic
        upper_g(ind{i})=interp2(glon(rkeep),glat(ckeep([end:-1:1])),A,lon(ind{i}),lat(ind{i}),'cubic');
        upper_ht(ind{i})=grid_ht(i);
        if i==1 %lowest grid put in all points
            lower_g=upper_g;
            lower_ht(ind{i})=grid_ht(i);
        else %all others only fill in those that are empty in lower_g
            t_ind=ind{i};
            eind=find(lower_g(t_ind)==1);
            lower_g(t_ind(eind))=upper_g(t_ind(eind));
            lower_ht(t_ind(eind))=grid_ht(i);
            clear eind t_ind
        end
        clear A R ckeep rkeep fid j
    end
end

%% adjust for height separation from grid for each point
fac=calc_fac(ht,lat);
lower_fac=calc_fac(lower_ht,lat);
upper_fac=calc_fac(upper_ht,lon);

switch grid_str
    case 'upper' %can have errors up to 20 mgal
        g=upper_g+upper_fac-fac;
    case 'lower' %errors are within one mgal of full harmonic synthesis
        g=lower_g+lower_fac-fac;
    case 'both' %can have errors up to 10 mgal
        g=((lower_g+lower_fac-fac)+(upper_g+upper_fac-fac))./2;
    case 'closest'
        %this is not supported yet default to lower grid for now
        g=lower_g+lower_fac-fac; 
end