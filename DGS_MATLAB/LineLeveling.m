
mycoef=lscov(M,-ec);   
L=mycoef;
ecd=ec+(M*L);
MeanError=mean(abs(ecd));
mysigma=std(ecd);

fprintf('\n');
fprintf('Mean Error corrected %f \n',MeanError);
fprintf('\n');

fprintf('Line corrected errors %f \n',ecd);
fprintf('\n'); 