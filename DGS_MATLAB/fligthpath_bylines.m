% flightpath.m
% plot the map of the fligth paht


mycolor={'blue','green','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow','black'};
for l=1:id-1
    
minlat=min(lgpslat{:,l});
maxlat=max(lgpslat{:,l});
minlon=min(lgpslong{:,l});
maxlon=max(lgpslong{:,l});
end



i=1
switch i
    case(1),
 m_proj('lambert','long',[minlon maxlon],'lat',[minlat maxlat]);
 m_coast('patch',[1 .85 .7]);
 m_elev('contourf',[500:500:6000]);
 m_grid('box','fancy','tickdir','in');
 colormap(flipud(copper));
% m_plot(gps_long(200:end-200),gps_lat(200:end-200));
 
  for l=1:id-1
 
 m_plot(lgpslong{:,l},lgpslat{:,l},mycolor{:,id});
 
  end
 
  xlabel('Fligth path','visible','on');
  
   case(2),
    lon=gps_long(200:end);
    lat=gps_lat(200:end);
   % axes('position',[.35 .6 .37 .37]);
    m_proj('albers equal-area','lat',[minlat maxlat],'long',[minlon maxlon],'rect','on');
    m_coast('patch',[0 1 0]);
    m_grid('linestyle','none','linewidth',2,'tickdir','out','xaxisloc','top','yaxisloc','right');
    m_text(-69,41,'Standard coastline','color','r','fontweight','bold');
    m_plot(lon,lat);
end