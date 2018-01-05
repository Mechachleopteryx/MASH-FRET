function [maxSNR, saturation_intensity] = Saturation(bitnr)
% by Danny Kowerko
% bitnr = 14;

jj=1;
x1 = 2^(bitnr-1):(2^(bitnr+2)-2^(bitnr-1))/1000:2^(bitnr+2);
x1 = [x1 [2 4 8 16 32 64 128 256 512 1024 2048 4096 8092 8092*2 8092*4 8092*8 8092*16]];
for ii = x1
    tmp=round(random('Normal',ii,sqrt(ii),1,10000))';
    tmp(tmp>2^bitnr-1,:)=2^bitnr-1;
    y1(jj) = std(tmp);
    jj = jj + 1;
end
% loglog(x1,y1,'o');
[ maxSNR, maxSNR_idx] = (max(y1));
saturation_intensity = x1(maxSNR_idx);
% disp('saturation')
% disp(maxSNR); 
% disp('saturation intensity')
% disp(saturation_intensity); 