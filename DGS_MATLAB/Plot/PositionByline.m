% PositionsByline.m

mycolor={'black','green','blue','cyan','red','magenta','yellow','black','green','blue','cyan','red','magenta','yellow''blue','cyan','red','magenta','yellow'};
 figure
for l=1:id-1
 plot(lgpslong{:,l}, lgpslat{:,l},mycolor{:,l}),title('Lat Long Position');
hold on

end
hold off

 figure
for l=1:id-1
  plot(lgpslong{:,l}, lgps_height{:,l},mycolor{:,l}),title('Elevation');
hold on
end
hold off




longk=mean(111197*lgpslong{:,1}.*cos(pi*lgpslat{:,1}/180));
latk=mean(111197*lgpslat{:,1});

figure
axis equal off
for l=1:id-1
    
   
   %  axis equal on
    plot((111197*lgpslong{:,l}.*cos(pi*lgpslat{:,l}/180)-longk)/1000,(111197*lgpslat{:,l}-latk)/1000,mycolor{:,l}),title('Position Km');

    hold on
end
hold off

  