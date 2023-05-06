function [ score ] = wpsnr(I,I1)
%WPSNR 此处显示有关此函数的摘要
%   此处显示详细说明
[d1,d2] = size(I);W=1;
noise = zeros(size(I));
nvf = zeros(size(I));
pfor = 1;
flag = ones(size(I)); 
for i = 2:d1-1
    for j = 2:d2-1
        if i-W <=0 || j-W <=0 || i+W >d1 || j+W >d2
            upper = max([1,i-W]);
            bottom = min([d1,i+W]);
            left = max([1,j-W]);
            right = min([d2,j+W]);
            A = I(upper:bottom,left:right);
            A = A(:);
            B = flag(upper:bottom,left:right);
            B = B(:);
        else
            A = I(i-W:i+W,j-W:j+W);
            A = A(:);
            B = flag(i-W:i+W,j-W:j+W);
            B = B(:);
        end
        mA = sum(A.*B)/sum(B);
        sqA = (A-mA).^2;
        temp = sum(sqA.*B);
        noise(i,j) =  temp;
        pfor = pfor + 1;
    end
end

 
maxN = max(max(noise));
minN = min(min(noise));

theta = 75/maxN;

nvf = 1./(1+theta.*noise);

MSE=mean(mean(nvf.*(I-I1).^2));
score=10*log10((255^2)/MSE);
end

