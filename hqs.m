function [ score ] = hqs(I,I1)
%HQS 此处显示有关此函数的摘要
%   此处显示详细说明
[A,B] = size(I);
noise = zeros(size(I));
nvf = ones(size(I));
for i = 2:A-2
    for j = 2:B-2
         e1 = I(i-1,j-1); v1 = I(i-1,j);  e2 = I(i-1,j+1); u6 = I(i-1,j+2);
         v2 = I(i  ,j-1); p  = I(i  ,j);  v4 = I(i  ,j+1); u7 = I(i  ,j+2);
         u1 = I(i+1,j-1); v3 = I(i+1,j);  u4 = I(i+1,j+1); u8 = I(i+1,j+2);
         u2 = I(i+2,j-1); u3 = I(i+2,j);  u5 = I(i+2,j+1)         ; u9 = I(i+2,j+2);
         p1=(v1+v2+v3+v4)/4;p2=(v1+v2+p1)/3;p3=(v4+u7+u6)/3;
         vm=(v1+v2+v3+v4+u1+u4)/6;
         noise(i,j) = (v1-vm)^2+(v2-vm)^2+(v3-vm)^2+(v4-vm)^2+(u1-vm)^2+(u4-vm)^2;
         noise(i,j) = noise(i,j)/6;
         alph=-1.5;
         noise(i,j)=log(1+noise(i,j)/50);
         nvf(i,j) = (0.1+noise(i,j))^alph;
    end
end
MSE=mean(mean(nvf.*(I-I1).^2));
score=10*log10((255^2)/MSE);
end

