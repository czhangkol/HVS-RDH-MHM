function [ECmax,I,EM] = mine_hvs(I,ECfinal,nvf)

%%%%%%%%%% 图像读入
ECmax = 0;
[A,B] = size(I);
J = I;
EM = zeros(A,B);


%%%%%%%%%%%%%%%%%%%% 第一层嵌入
%%%%%%%%%% E是PE，D是NL
E = zeros(A,B);
D = zeros(A,B);

%%%%%%%%%% 水印信息
X = randperm(A*B);
M = zeros(A,B);
for i = 1:A
    for j = 1:B
        M(i,j) = mod(X(B*(i-1)+j),2);
    end
end

%%%%%%%%%% location map
LM = zeros(1,A*B);
index = 0;
for i = 2:A-2
    for j = 2:B-2
        if mod(i+j,2) == 0
            index = index+1;
            if I(i,j) == 0
                I(i,j) = 1;
                LM(index) = 1;
            else
                if I(i,j) == 255
                    I(i,j) = 254;
                    LM(index) = 1;
                end
            end
        end
    end
end
% xC = cell(1,1);
% xC{1} = LM;
% data = arith07(xC);
LM = ones(1,100);
data = ones(1,10);

%%%%%%%%%% location map长度
8*length(data);

%%%%%%%%%% PE和NL的计算
for i = 2:A-2
    for j = 2:B-2
        if mod(i+j,2) == 0
                             v1 = I(i-1,j);                   u6 = I(i-1,j+2);
            v2 = I(i  ,j-1); p  = I(i  ,j);  v4 = I(i  ,j+1); u7 = I(i  ,j+2);
            u1 = I(i+1,j-1); v3 = I(i+1,j);  u4 = I(i+1,j+1); u8 = I(i+1,j+2);
            u2 = I(i+2,j-1); u3 = I(i+2,j);  u5 = I(i+2,j+1); u9 = I(i+2,j+2);
            p = ceil((v1+v2+v3+v4)/4);
            E(i,j) = I(i,j)-p;
            D(i,j) = abs(v2-u1)+abs(u1-u2)+abs(v1-p)+abs(p-v3)+abs(v3-u3)+abs(v4-u4)+abs(u4-u5)+abs(u6-u7)+abs(u7-u8)+abs(u8-u9)+...
                abs(v2-p)+abs(p-v4)+abs(v4-u7)+abs(u1-v3)+abs(v3-u4)+abs(u4-u8)+abs(u2-u3)+abs(u3-u5)+abs(u5-u9);
        end
    end
end

%%%%%%%%%% 2D直方图
max(D(:));
H = zeros(511,max(D(:))+1);
for i = 2:A-2
    for j = 2:B-2
        if mod(i+j,2) == 0
            H(E(i,j)+255,D(i,j)+1) = H(E(i,j)+255,D(i,j)+1)+1;
        end
    end
end

%%%%%%%%%% 2D直方图归一化
Scale = 16;
T = zeros(1,Scale);
for i = 1:Scale
    for j = 1:max(D(:))+1
        if sum(sum(H(:,1:j))) >= index/Scale*i;
            T(i) = j;
            break
        end
    end
end
T-1;

%%%%%%%%%% 2D直方图归一化后的复杂度计算
Dbis = zeros(A,B);
for k = Scale:-1:1
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == 0
                if D(i,j) < T(k)
                    Dbis(i,j) = k;
                end
            end
        end
    end
end

%%%%%%%%%% 重新生成2D直方图
H = zeros(511,Scale);
NVF = zeros(511,Scale);
for i = 2:A-2
    for j = 2:B-2
        if mod(i+j,2) == 0
            H(E(i,j)+255,Dbis(i,j)) = H(E(i,j)+255,Dbis(i,j))+1;
            NVF(E(i,j)+255,Dbis(i,j)) = NVF(E(i,j)+255,Dbis(i,j))+nvf(i,j);
        end
    end
end
%%%%%%直方图可视化
% see = [1,4,8,12,16];
% x = 1:1:511; x = x - 255;
% for i=1:length(see)
%     j = see(i);
%     y = H(:,j); y = y';
%     plot(x,y,'LineWidth',2,'markersize',10);hold on;
%     xlabel('The prediction-error')
%     ylabel('The frequency');
% %     ylabel('The mean value of NVF');
%     lgd=legend('n=1','n=4','n=8','n=12','n=16');
%     set(gca, 'YGrid','on');
%     set(gca, 'XGrid','on'); % X轴的网格
%     set(lgd,'FontName','Times New Roman','FontSize',24,'Interpreter','latex')
%     set(gca,'Fontname', 'Times New Roman','FontSize',24,'FontWeight','bold');
%     set(gca,'xlim',[-40,40],'xtick',[-40:10:40]);%x坐标轴范围
% end

maxb=8;
%%%%%不同bin下的容量
ECbis = zeros(maxb,Scale);
EDbis = zeros(maxb,Scale);
for i = 1:Scale
    for j = 1:maxb
        b = j-1;
        ECbis(j,i)=H(b+255,i)+H(-b-1+255,i);
        EDbis(j,i)=0.5*(NVF(b+255,i)+NVF(-b-1+255,i))+sum(NVF(b+1+255:511,i))+sum(NVF(1:-b-2+255,i));
    end
end
%%%%%直方图熵
entropyH = zeros(1,Scale/2);
for i=1:Scale/2
    p=H(:,i)/sum(H(:,i));
    index=find(p);
    entropyH(i)=-sum(p(index).*log2(p(index)));
end
mark = mean(entropyH);

W = 250*ones(maxb+1,Scale);
for i = 1:Scale
    W(1:8,i)=0:1:7;
end

%%%%参数回退标记
back = zeros(maxb+1,Scale);
% if mark >= 4
%     for i = 2:Scale/2
%         for j = 2:maxb
%             x1 = ECbis(j-1,i); x2 = ECbis(j,i);
%                 if (((x1-x2)/x2)>=0.3)
%                     back(j,i)=1;
%                 end
%         end
%     end
% else
%     for i = 2:Scale/2  
%         for j = 2:maxb-1
%             x1 = ECbis(j-1,i); x2 = ECbis(j,i);
%             Q = sum(ECbis(j-1:maxb,i))/sum(ECbis(:,i));
%                 if (((x1-x2)/x2)>=0.9)&&(Q>=0.15)
%                     back(j,i)=1;
%                 end
%         end
%     end
% end
if mark >= 4
    for i = 2:Scale/2
        for j = 2:maxb
            x1 = ECbis(j-1,i); x2 = ECbis(j,i);
                if (((x1-x2)/x2)>=0.9)
                    back(j,i)=1;
                end
        end
    end
else
    for i = 2:Scale/2  
        for j = 2:maxb-1
            x1 = ECbis(j-1,i); x2 = ECbis(j,i);
            Q = sum(ECbis(j-1:maxb,i))/sum(ECbis(:,i));
                if (((x1-x2)/x2)>=0.9)&&(Q>=0.5)
                    back(j,i)=1;
                end
        end
    end
end
nb_1=sum(sum(back));

%%%%%%%%%% 辅助信息长度：16*3,a; 4, 255; LM; 18 message; hist para
s = ceil(log2(T(Scale-1)));
if sum(LM) == 0
    Aux = Scale*3+4+1+17+(Scale-1)*s+4;
else
    Aux = Scale*3+4+1+8*length(data)+17+17+(Scale-1)*s+4;
end

%%%%%%%%%% 参数计算
EC = fix(ECfinal/2)+Aux;
MSEmin = 10000000000000000;
R = zeros(1,Scale);
S = zeros(1,Scale);
run = ones(1,Scale);
flag = 0;

for a1 = run(1):maxb+1
    run(2)=a1-back(a1,2);
    for a2 = run(2):maxb+1
        run(3)=a2-back(a2,3);
        for a3 = run(3):maxb+1
            run(4)=a3-back(a3,4);
            for a4 = run(4):maxb+1
                run(5)=a4-back(a4,5);
                for a5 = run(5):maxb+1
                    run(6)=a5-back(a5,6);
                    for a6 = run(6):maxb+1
                        run(7)=a6-back(a6,7);
                        for a7 = run(7):maxb+1
                            run(8)=a7-back(a7,8);
                            for a8 = run(8):maxb+1
                                run(9)=a8-back(a8,9);
                                for a9 = run(9):maxb+1
                                    run(10)=a9-back(a9,10);
                                    for a10 = run(10):maxb+1
                                        run(11)=a10-back(a10,11);
                                        for a11 = run(11):maxb+1
                                            run(12)=a11-back(a11,12);
                                            for a12 = run(12):maxb+1
                                                run(13)=a12-back(a12,13);
                                                for a13 = run(13):maxb+1
                                                    run(14)=a13-back(a13,14);
                                                    for a14 = run(14):maxb+1
                                                        run(15)=a14-back(a14,15);
                                                        for a15 = run(15):maxb+1
                                                            run(16)=a15-back(a15,16);
                                                            for a16 = run(16):maxb+1
                                        
                                                                        S = [W(a1,1) W(a2,2) W(a3,3) W(a4,4) W(a5,5) W(a6,6) W(a7,7) W(a8,8) W(a9,9) W(a10,10) W(a11,11) W(a12,12) W(a13,13) W(a14,14) W(a15,15) W(a16,16)];
                                                                        x = 0;
                                                                        for k = 1:Scale
                                                                            x = x+H(S(k)+255,k)+H(-S(k)-1+255,k);
                                                                        end
                                                                        if x >= EC
                                                                            flag = 1;
                                                                            y = 0;
                                                                            for k = 1:Scale
                                                                                 y = y+0.5*(NVF(S(k)+255,k)+NVF(-S(k)-1+255,k))+sum(NVF(S(k)+1+255:511,k))+sum(NVF(1:-S(k)-2+255,k));
                                                                            end
                                                                            if y/x < MSEmin
                                                                                MSEmin = y/x;
                                                                                R = S;
                                                                            end
                                                                        end                                                                    
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

if flag == 1
    %%%%%%%%%% 辅助信息长度修改
    Scalebis = Scale-1;
    for  i = Scale:-1:1
        if R(i) == 250
            Scalebis = i-1;
        end
    end
    Scalebis;
    s = ceil(log2(T(Scalebis)));
    if sum(LM) == 0
        Aux = Scalebis*3+4+1+17+Scalebis*s+4;
    else
        Aux = Scalebis*3+4+1+8*length(data)+17+17+Scalebis*s+4;
    end
    EC = fix(ECfinal/2)+Aux;
    %%%%%%%%%% 真实嵌入
    EM = zeros(A,B);
    Nend = 0;
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == 0 && EC > 0
                Nend = Nend+1;
                k = Dbis(i,j);
                if E(i,j) == R(k)
                    EC = EC-1;
                    I(i,j) = I(i,j)+M(i,j);
                    EM(i,j) = 1;
                end
                if E(i,j) == -R(k)-1
                    EC = EC-1;
                    I(i,j) = I(i,j)-M(i,j);
                    EM(i,j) = 1;
                end
                if E(i,j) > R(k)
                    I(i,j) = I(i,j)+1;
                end
                if E(i,j) < -R(k)-1
                    I(i,j) = I(i,j)-1;
                end
            end
        end
    end
    %%%%%%%%%% 随机信息
    X = randperm(A*B);
    M = zeros(A,B);
    for i = 1:A
        for j = 1:B
            M(i,j) = mod(X(B*(i-1)+j),2);
        end
    end
    %%%%%%%%%% 辅助信息嵌入, LSB-R
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == 0
                if Aux > 0
                    I(i,j) = 2*floor(I(i,j)/2)+M(i,j);
                    Aux = Aux-1;
                end
            end
        end
    end
    R;
end


%%%%%%%%%%%%%%%%%%%% 第二层嵌入
if flag == 1 && EC == 0
    %%%%%%%%%% E是PE，D是NL
    %%%%%%%%%% E是PE，D是NL
    E = zeros(A,B);
    D = zeros(A,B);
    
    %%%%%%%%%% 水印信息
    X = randperm(A*B);
    M = zeros(A,B);
    for i = 1:A
        for j = 1:B
            M(i,j) = mod(X(B*(i-1)+j),2);
        end
    end
    
    %%%%%%%%%% location map
    LM = zeros(1,A*B);
    index = 0;
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == 1
                index = index+1;
                if I(i,j) == 0;
                    I(i,j) = 1;
                    LM(index) = 1;
                else
                    if I(i,j) == 255
                        I(i,j) = 254;
                        LM(index) = 1;
                    end
                end
            end
        end
    end
%     xC = cell(1,1);
%     xC{1} = LM;
%     data = arith07(xC);
    LM = ones(1,100);
    data = ones(1,10);
    %%%%%%%%%% location map长度
    8*length(data);
    
    %%%%%%%%%% PE和NL的计算
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == 1
                                 v1 = I(i-1,j);                   u6 = I(i-1,j+2);
                v2 = I(i  ,j-1); p  = I(i  ,j);  v4 = I(i  ,j+1); u7 = I(i  ,j+2);
                u1 = I(i+1,j-1); v3 = I(i+1,j);  u4 = I(i+1,j+1); u8 = I(i+1,j+2);
                u2 = I(i+2,j-1); u3 = I(i+2,j);  u5 = I(i+2,j+1); u9 = I(i+2,j+2);
                p = ceil((v1+v2+v3+v4)/4);
                E(i,j) = I(i,j)-p;
                D(i,j) = abs(v2-u1)+abs(u1-u2)+abs(v1-p)+abs(p-v3)+abs(v3-u3)+abs(v4-u4)+abs(u4-u5)+abs(u6-u7)+abs(u7-u8)+abs(u8-u9)+...
                    abs(v2-p)+abs(p-v4)+abs(v4-u7)+abs(u1-v3)+abs(v3-u4)+abs(u4-u8)+abs(u2-u3)+abs(u3-u5)+abs(u5-u9);
            end
        end
    end
    
    %%%%%%%%%% 2D直方图
    max(D(:));
    H = zeros(511,max(D(:))+1);
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == 1
                H(E(i,j)+255,D(i,j)+1) = H(E(i,j)+255,D(i,j)+1)+1;
            end
        end
    end
    
    %%%%%%%%%% 2D直方图归一化
    Scale = 16;
    T = zeros(1,Scale);
    for i = 1:Scale
        for j = 1:max(D(:))+1
            if sum(sum(H(:,1:j))) >= index/Scale*i;
                T(i) = j;
                break
            end
        end
    end
    T-1;
    
    %%%%%%%%%% 2D直方图归一化后的复杂度计算
    Dbis = zeros(A,B);
    for k = Scale:-1:1
        for i = 2:A-2
            for j = 2:B-2
                if mod(i+j,2) == 1
                    if D(i,j) < T(k)
                        Dbis(i,j) = k;
                    end
                end
            end
        end
    end
    
    %%%%%%%%%% 重新生成2D直方图
    H = zeros(511,Scale);
    NVF = zeros(511,Scale);
    for i = 2:A-2
        for j = 2:B-2
            if mod(i+j,2) == 1
                H(E(i,j)+255,Dbis(i,j)) = H(E(i,j)+255,Dbis(i,j))+1;
                NVF(E(i,j)+255,Dbis(i,j)) = NVF(E(i,j)+255,Dbis(i,j))+nvf(i,j);
            end
        end
    end
    
    maxb=8;
    entropyH = zeros(1,Scale/2);
    for i=1:Scale/2
        p=H(:,i)/sum(H(:,i));
        index=find(p);
        entropyH(i)=-sum(p(index).*log2(p(index)));
    end
    mark = mean(entropyH);
    ECbis = zeros(maxb,Scale);
    for i = 1:Scale
        for j = 1:maxb
            b = j-1;
            ECbis(j,i)=H(b+255,i)+H(-b-1+255,i);
        end
    end
    
    W = 250*ones(maxb+1,Scale);
    for i = 1:Scale
        W(1:8,i)=0:1:7;
    end

    back = zeros(maxb+1,Scale);
%     if mark >= 4
%         for i = 2:Scale/2
%             for j = 2:maxb
%                 x1 = ECbis(j-1,i); x2 = ECbis(j,i);
%                     if (((x1-x2)/x2)>=0.3)
%                         back(j,i)=1;
%                     end
%             end
%         end
%     else
%         for i = 2:Scale/2
%             for j = 2:maxb
%                 x1 = ECbis(j-1,i); x2 = ECbis(j,i);
%                 Q = sum(ECbis(j-1:maxb,i))/sum(ECbis(:,i));
%                     if (((x1-x2)/x2)>=0.9)&&(Q>=0.15)
%                         back(j,i)=1;
%                     end
%             end
%         end
%     end
    if mark >= 4
        for i = 2:Scale/2
            for j = 2:maxb
                x1 = ECbis(j-1,i); x2 = ECbis(j,i);
                    if (((x1-x2)/x2)>=0.9)
                        back(j,i)=1;
                    end
            end
        end
    else
        for i = 2:Scale/2
            for j = 2:maxb
                x1 = ECbis(j-1,i); x2 = ECbis(j,i);
                Q = sum(ECbis(j-1:maxb,i))/sum(ECbis(:,i));
                    if (((x1-x2)/x2)>=0.9)&&(Q>=0.5)
                        back(j,i)=1;
                    end
            end
        end
    end
    nb_2=sum(sum(back));
    %%%%%%%%%% 辅助信息长度：16*3,a; 4, 255; LM; 18 message; hist para
    s = ceil(log2(T(Scale-1)));    
    if sum(LM) == 0
        Aux = Scale*3+4+1+17+(Scale-1)*s+4;
    else
        Aux = Scale*3+4+1+8*length(data)+17+17+(Scale-1)*s+4;
    end
    
    %%%%%%%%%% 参数计算
    EC = ECfinal-fix(ECfinal/2)+Aux;
    MSEmin = 10000000000000000;
    R = zeros(1,Scale);
    S = zeros(1,Scale);
    run = ones(1,Scale);
    flagbis = 0;
    for a1 = run(1):maxb+1
        run(2)=a1-back(a1,2);
        for a2 = run(2):maxb+1
            run(3)=a2-back(a2,3);
            for a3 = run(3):maxb+1
                run(4)=a3-back(a3,4);
                for a4 = run(4):maxb+1
                    run(5)=a4-back(a4,5);
                    for a5 = run(5):maxb+1
                        run(6)=a5-back(a5,6);
                        for a6 = run(6):maxb+1
                            run(7)=a6-back(a6,7);
                            for a7 = run(7):maxb+1
                                run(8)=a7-back(a7,8);
                                for a8 = run(8):maxb+1
                                    run(9)=a8-back(a8,9);
                                    for a9 = run(9):maxb+1
                                        run(10)=a9-back(a9,10);
                                        for a10 = run(10):maxb+1
                                            run(11)=a10-back(a10,11);
                                            for a11 = run(11):maxb+1
                                                run(12)=a11-back(a11,12);
                                                for a12 = run(12):maxb+1
                                                    run(13)=a12-back(a12,13);
                                                    for a13 = run(13):maxb+1
                                                        run(14)=a13-back(a13,14);
                                                        for a14 = run(14):maxb+1
                                                            run(15)=a14-back(a14,15);
                                                            for a15 = run(15):maxb+1
                                                                run(16)=a15-back(a15,16);
                                                                for a16 = run(16):maxb+1

                                                                            S = [W(a1,1) W(a2,2) W(a3,3) W(a4,4) W(a5,5) W(a6,6) W(a7,7) W(a8,8) W(a9,9) W(a10,10) W(a11,11) W(a12,12) W(a13,13) W(a14,14) W(a15,15) W(a16,16)];
                                                                            x = 0;
                                                                            for k = 1:Scale
                                                                                x = x+H(S(k)+255,k)+H(-S(k)-1+255,k);
                                                                            end
                                                                            if x >= EC
                                                                                flagbis = 1;
                                                                                y = 0;
                                                                                for k = 1:Scale
                                                                                     y = y+0.5*(NVF(S(k)+255,k)+NVF(-S(k)-1+255,k))+sum(NVF(S(k)+1+255:511,k))+sum(NVF(1:-S(k)-2+255,k));
                                                                                end
                                                                                if y/x < MSEmin
                                                                                    MSEmin = y/x;
                                                                                    R = S;
                                                                                end
                                                                            end                                                                    
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if flagbis == 1
        %%%%%%%%%% 辅助信息长度修改
        Scalebis = Scale-1;
        for  i = Scale:-1:1
            if R(i) == 250
                Scalebis = i-1;
            end
        end
        Scalebis;
        s = ceil(log2(T(Scalebis)));
        if sum(LM) == 0
            Aux = Scalebis*3+4+1+17+Scalebis*s+4;
        else
            Aux = Scalebis*3+4+1+8*length(data)+17+17+Scalebis*s+4;
        end
        EC = ECfinal-fix(ECfinal/2)+Aux;
        %%%%%%%%%% 真实嵌入
        Nend = 0;
        for i = 2:A-2
            for j = 2:B-2
                if mod(i+j,2) == 1 && EC > 0
                    Nend = Nend+1;
                    k = Dbis(i,j);
                    if E(i,j) == R(k)
                        EC = EC-1;
                        I(i,j) = I(i,j)+M(i,j);
                        EM(i,j) = 1;
                    end
                    if E(i,j) == -R(k)-1
                        EC = EC-1;
                        I(i,j) = I(i,j)-M(i,j);
                        EM(i,j) = 1;
                    end
                    if E(i,j) > R(k)
                        I(i,j) = I(i,j)+1;
                    end
                    if E(i,j) < -R(k)-1
                        I(i,j) = I(i,j)-1;
                    end
                end
            end
        end
        %%%%%%%%%% 随机信息
        X = randperm(A*B);
        M = zeros(A,B);
        for i = 1:A
            for j = 1:B
                M(i,j) = mod(X(B*(i-1)+j),2);
            end
        end
        %%%%%%%%%% 辅助信息嵌入
        for i = 2:A-2
            for j = 2:B-2
                if mod(i+j,2) == 1
                    if Aux > 0
                        I(i,j) = 2*floor(I(i,j)/2)+M(i,j);
                        Aux = Aux-1;
                    end
                end
            end
        end
    end
    %%%%%%%%%% PSNR
    MSE = 0;t=1;
    for i = 1:A
        for j = 1:B
            MSE = MSE+(I(i,j)-J(i,j))^2;

            if I(i,j)~=J(i,j)
                x(t)=j;y(t)=i;t=t+1;
            end
        end
    end
%     I=im2uint8(I/255);
%     J=im2uint8(J/255);
%     figure(1);imshow(I);
%     figure(2);imshow(J);
%     hold on;
% %     plot(x,y,'.g');
    if EC == 0
        R;
        ECmax = ECfinal;
    else
        ECmax = 0;
    end

end

end