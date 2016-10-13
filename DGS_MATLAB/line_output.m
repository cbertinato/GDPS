noflines = 3; 

for id=1:noflines
    fname = sprintf('NY_091516_Line%d.csv', id);
    fid2 = fopen(fname,'a');
    fprintf(fid2,'GPSsow,GPSweek,Lat,Lon,hEll,FreeAir,LatCorr,Eotvos,GPSCorr \r\n');
    
    gpssow = weeksec{id};
    gpsweek = week{id};
    lat = lgpslat{id};
    lon = lgpslong{id};
    hell = lgps_height{id};
    fa = GravityFreeAir{id};
    latcorr = lfLatcorr{id};
    eotvos = lfEotvos{id};
    gpscorr = lfGPS_Corrections{id};

    tosave=[gpssow'; gpsweek'; lat'; lon'; hell'; fa'; latcorr'; eotvos'; gpscorr'];

    fprintf(fid2,'%7.1f,%4d,%15.9f,%15.9f,%15.9f,%9.3f,%9.3f,%9.3f,%9.3f\r\n', tosave);
    fclose(fid2);
end