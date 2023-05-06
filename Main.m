clear all
clc
% 
imgfile = ['Image\']; 

imgdir = dir([imgfile,'\*.bmp']); 

fid=fopen('fileName.txt','wt');
performance = zeros(length(imgdir)*6,100); 
data_n=length(imgdir);
location_map = zeros(length(imgdir),100);

for i_img = 1:1
    
img = 6*(i_img-1)+1;

% read the image
I = double(imread([imgfile,'\',imgdir(i_img).name]));
[m,n]=size(I);

I1=I;

[nvf] = NVFmatric(I,2); % calculate the NVF

nIndex = 1;

for Capacity = 50000:5000:50000 % set the EC
     
[bits,J,EM] =  mine_hvs(I1,Capacity,nvf); % embed -> return the performance
   
   MSE=mean(mean((I-J).^2));
   PSNR=10*log10((255^2)/MSE);
   SSIM=ssim(I,J);
   WPSNR=wpsnr(I,J);
   JNDD=jndd(I,J);

if bits < Capacity
    break
end

performance(img,nIndex) = bits;
performance(img+1,nIndex) = PSNR;
performance(img+2,nIndex) = SSIM;
performance(img+3,nIndex) = WPSNR;
performance(img+4,nIndex) = JNDD;
% 10*log10(255^2*512^2/MSE)


nIndex = nIndex + 1;

%     t=1;EM=zeros(m,n);
%     for i = 1:m
%         for j = 1:n
%             if I(i,j) ~= J(i,j)
%                 EM(i,j) = abs(I(i,j)-J(i,j));
%                 x(t)=j;y(t)=i;t=t+1;
%             end
%         end
%     end
%     I=im2uint8(I/255);
%     figure(3);x
%     imshow(I);hold on;
%     plot(x,y,'.','Color',[0.11765 0.56471 1],'Markersize',0.1);

% Iw=im2uint8(J/255);      
% imwrite(Iw,name);
fprintf('The %d test image,embedding %d bits\n',i_img,bits);

end
% save mine_ucid2.mat performance;
end

disp('Íê³É£¡')
