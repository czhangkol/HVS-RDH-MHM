function [ score ] = jndd(I,I1)
[m,n]=size(I);
JND=zeros(m,n);
W=[1.40 1.01 1.16 1.66 2.40 3.43 4.79 6.56
   1.01 1.45 1.32 1.52 2.00 2.71 3.67 4.93
   1.16 1.32 2.24 2.59 2.98 3.64 4.60 5.88
   1.66 1.52 2.59 3.77 4.55 5.30 6.28 7.60
   2.40 2.20 2.98 4.55 6.15 7.46 8.71 10.17
   3.43 2.71 3.64 5.30 7.46 9.62 11.58 13.51
   4.79 3.67 4.60 6.28 8.71 11.58 14.50 17.29
   6.56 4.93 5.88 7.60 10.17 13.51 17.29 21.15];
t=1;r=1;
for i=1:m
    for j=1:n
        if mod(i+j,2)==0
            shadow(t)=I(i,j);t=t+1;
        else
            blank(r)=I(i,j);r=r+1;
        end
    end
end
N=length(shadow)/64;
for i=1:N
    A=reshape(shadow(1+(i-1)*64:1:64+(i-1)*64),8,8);
    B=reshape(blank(1+(i-1)*64:1:64+(i-1)*64),8,8);
    A=A';B=B';
    C=dct2(A);
    C=(abs(C)+W).*sign(C);
    V=idct2(C);
    J=abs(V-A);J=J';
    shadow(1+(i-1)*64:1:64+(i-1)*64)=reshape(J,1,64);
    C=dct2(B);
    C=(abs(C)+W).*sign(C);
    V=idct2(C);
    J=abs(V-B);J=J';
    blank(1+(i-1)*64:1:64+(i-1)*64)=reshape(J,1,64);
end
t=1;r=1;
for i=1:m
    for j=1:n
        if mod(i+j,2)==0
            JND(i,j)=shadow(t);t=t+1;
        else
            JND(i,j)=blank(r);r=r+1;
        end
    end
end
for i=2:m-1
    for j=2:n-1
        JND(i,j)=((JND(i-1,j)+JND(i,j-1)+JND(i,j+1)+JND(i+1,j))/4);
        if JND(i,j)~=0
        end      
    end
end

JND = JND+1;
score=mean(mean(abs(I-I1)./JND))*10;
t=1;
end

