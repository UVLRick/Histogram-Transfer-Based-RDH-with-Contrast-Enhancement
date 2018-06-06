%%
%clc;close all;
% rate33=[];
% for i=1:147
%     if mod(i,3)==1 || mod(i,3)==0
%         rate33=[rate33 rate3(i)];
%     end
% end
% rate44=[];
% for i=1:112
%     if mod(i,11)==0
%         continue;
%     end
%     rate44=[rate44 rate4(i)];
% end
% rate3=rate33;rate4=rate44;
% rate11=rate1(10:10:end);rate22=rate2(10:10:end);rate33=rate3(10:10:end);rate44=rate4(10:10:end);
% 
% figure;
% x=50:50:50*length(rate1);
% y=500:500:500*length(rate11);
% plot(x,rate1,'-r');hold on;
% 
% x=50:50:50*length(rate2);
% 
% plot(x,rate2,'-b');
% 
% x=50:50:50*length(rate3);
% 
% plot(x,rate3,'-g');
% 
% x=50:50:50*length(rate4);
% 
% plot(x,rate4,'-c');
% 
% % print -dmeta filename
% legend('Lena','Baboon','Photographer','DSP','Location','SouthEast');
% y=500:500:500*length(rate11);plot(y,rate11,'.r');
% y=500:500:500*length(rate22);plot(y,rate22,'xb');
% y=500:500:500*length(rate33);plot(y,rate33,'og');
% y=500:500:500*length(rate44);plot(y,rate44,'dc');
% 
% % plot(x,HistOptimal','red');
% % hold on;
% % plot(x,Hist,'blue');
% print -dmeta 'disp';


addpath 'C:\Users\yqc_s\Desktop\new\IWT';
addpath 'C:\Users\yqc_s\Desktop\new\arithmetic';
addpath 'C:\Users\yqc_s\Desktop\new\functions';
addpath 'C:\Users\yqc_s\Desktop\new\PCQI';
addpath 'C:\Users\yqc_s\Desktop\new\PEE';
[ImgIn,filename,pathname]=loadim();
ImgIn=imresize(ImgIn,[512 512]);OriHist=imhist(ImgIn);
ImgIn=double(ImgIn);
[row,col]=size(ImgIn);
ImgOut=ImgIn;Hist=OriHist;PeakNum=50;
%��¼��bin��λ�ã����ڷ�0bin�����λ�ã���¼ֵΪ�Ҳ��0bin�ǵڼ�����0����������ֵ����˵���������Ҳࣩ
[HistSort,HistIdx]=sort(Hist);Zeros=length(find(Hist==0));OriZero=Zeros;
auxinfoZeroValue=[];
for i=1:Zeros
    BehindList=Hist(HistIdx(i):end);Behind=find(BehindList>0,1)+HistIdx(i)-1;
    if isempty(Behind)
        ZeroBefore=sum(HistIdx(1:Zeros)<256);Lc=256-ZeroBefore;
    else
        ZeroBefore=sum(HistIdx(1:Zeros)<Behind);Lc=Behind-ZeroBefore;
    end
    auxinfoZeroValue=[auxinfoZeroValue dec2bin(Lc,8)-48];
end
%ͼ��Ԥ������<=10�ĻҶ��������ĺϲ�(���Բ�������) %����λ��,value+flag+number+map
%˵����1.������� 2.��ÿһ���ڣ������λ��Ϊ��ǰ���ڵķ�0bin��λ�üӼ�1
%�Ƚ����ϲ����ں��ϲ�ǰ�Ҷ�ֵ��ת�Ƹ��ʣ�������ת�Ƹ������ɹ�����������ǰ�����չ��������뱣��LM
auxinfoI=[];CombValue=[];CombNum=[];
disp('��ʼͼ��Ԥ������<=20�ĻҶ��������ĺϲ�');
for i=1:256
  [rcomb,ccomb]=size(CombValue);
  if Hist(i)>0 && Hist(i)<=20
    HistMin=Hist(i);Hist(i)=0;
    [HistSort,HistIdx]=sort(Hist);
    FrontList=Hist(i:-1:1);BehindList=Hist(i:end);
    Front=i-find(FrontList>0,1)+1;Behind=find(BehindList>0,1)+i-1;
    abf=find(FrontList>0,1);abb=find(BehindList>0,1);
    if isempty(Behind)
        if isempty(find(CombValue==Front, 1)) && isempty(find(CombValue==i,1))
            CombValue(rcomb+1,1)=i;CombNum(rcomb+1,1)=OriHist(i);
            CombValue(rcomb+1,2)=Front;CombNum(rcomb+1,2)=OriHist(Front);
        elseif isempty(find(CombValue==Front, 1))
            [R,~]=find(CombValue==i, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Front;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Front);
        elseif isempty(find(CombValue==i, 1))
            [R,~]=find(CombValue==Front, 1);
            CombValue(R,length(CombValue(R,:))+1)=i;CombNum(R,length(CombValue(R,:)))=OriHist(i);
        else
            [R,~]=find(CombValue==Front, 1);[R1,~]=find(CombValue==i, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,i-1,Front-1);Hist(Front)=Hist(Front)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Front-1);
    elseif isempty(Front)
        if isempty(find(CombValue==Behind, 1)) && isempty(find(CombValue==i,1))
            CombValue(rcomb+1,1)=i;CombNum(rcomb+1,1)=OriHist(i);
            CombValue(rcomb+1,2)=Behind;CombNum(rcomb+1,2)=OriHist(Behind);
        elseif isempty(find(CombValue==Behind, 1))
            [R,~]=find(CombValue==i, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Behind;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Behind);
        elseif isempty(find(CombValue==i, 1))
            [R,~]=find(CombValue==Behind, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=i;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(i);
        else
            [R,~]=find(CombValue==Behind, 1);[R1,~]=find(CombValue==i, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,i-1,Behind-1);Hist(Behind)=Hist(Behind)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Behind-1);
    elseif Hist(Front)*abf<Hist(Behind)*abb
         if isempty(find(CombValue==Front, 1)) && isempty(find(CombValue==i,1))
            CombValue(rcomb+1,1)=i;CombNum(rcomb+1,1)=OriHist(i);
            CombValue(rcomb+1,2)=Front;CombNum(rcomb+1,2)=OriHist(Front);
        elseif isempty(find(CombValue==Front, 1))
            [R,~]=find(CombValue==i, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Front;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Front);
        elseif isempty(find(CombValue==i, 1))
            [R,~]=find(CombValue==Front, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=i;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(i);
        else
            [R,~]=find(CombValue==Front, 1);[R1,~]=find(CombValue==i, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,i-1,Front-1);Hist(Front)=Hist(Front)+HistMin;
    else
         if isempty(find(CombValue==Behind, 1)) && isempty(find(CombValue==i,1))
            CombValue(rcomb+1,1)=i;CombNum(rcomb+1,1)=OriHist(i);
            CombValue(rcomb+1,2)=Behind;CombNum(rcomb+1,2)=OriHist(Behind);
        elseif isempty(find(CombValue==Behind, 1))
            [R,~]=find(CombValue==i, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Behind;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Behind);
        elseif isempty(find(CombValue==i, 1))
            [R,~]=find(CombValue==Behind, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=i;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(i);
        else
            [R,~]=find(CombValue==Behind, 1);[R1,~]=find(CombValue==i, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,i-1,Behind-1);Hist(Behind)=Hist(Behind)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Behind-1);
    end
  end
end
%����Location Map
[~,HistIdx]=sort(Hist);Zeros=length(find(Hist==0));[R,C]=size(CombValue);CombNumBackup=CombNum;
for i=1:R
    for j=1:C
        CombNum(i,j)=CombNumBackup(i,j)/sum(CombNumBackup(i,:),2);
    end
end
for i=1:R
    LEN=length(find(CombValue(i,:)>0));
    CVMIN=min(CombValue(i,1:LEN));
    ZeroBefore=sum(HistIdx(1:Zeros)<CVMIN);Lc=CVMIN-ZeroBefore;
    pseq=CombNum(i,1:length(find(CombNum(i,:)>0)));
    core=huff(pseq);%������������,���������ö���
        for k=1:512
            for l=1:512
                j=find(CombValue(i,1:LEN)==ImgIn(k,l)+1);
                if ~isempty(j)
                    auxinfoI=[auxinfoI core{j}-48];
                end
            end
        end   
    for j=LEN:-1:1
        auxinfoI=[dec2bin(CombNumBackup(i,j),4)-48 auxinfoI];
    end
    auxinfoI=[dec2bin(Lc,8)-48 auxinfoI];
end

x=1:1:256;CombValue=[];CombNum=[];
%�ͽ��ϲ���С��ֱ��ͼ������fra2��0λ
disp(['��ʼ�ϲ���С��ֱ��ͼ������' num2str(PeakNum-Zeros) '����λ']);
for i=1:PeakNum-Zeros
[rcomb,ccomb]=size(CombValue);
    [HistSort,HistIdx]=sort(Hist);%Ϊ��Ѱ����Сֵ
    HistMin=HistSort(i+Zeros);Index=HistIdx(i+Zeros);Hist(Index)=0;
    [HistSort,HistIdx]=sort(Hist);
    FrontList=Hist(Index:-1:1);BehindList=Hist(Index:end);
    Front=Index-find(FrontList>0,1)+1;Behind=find(BehindList>0,1)+Index-1;
    abf=find(FrontList>0,1);abb=find(BehindList>0,1);
    if isempty(Behind)
        if isempty(find(CombValue==Front, 1)) && isempty(find(CombValue==Index,1))
            CombValue(rcomb+1,1)=Index;CombNum(rcomb+1,1)=OriHist(Index);
            CombValue(rcomb+1,2)=Front;CombNum(rcomb+1,2)=OriHist(Front);
        elseif isempty(find(CombValue==Front, 1))
            [R,~]=find(CombValue==Index, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Front;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Front);
        elseif isempty(find(CombValue==Index, 1))
            [R,~]=find(CombValue==Front, 1);
            CombValue(R,length(CombValue(R,:))+1)=Index;CombNum(R,length(CombValue(R,:)))=OriHist(Index);
        else
            [R,~]=find(CombValue==Front, 1);[R1,~]=find(CombValue==Index, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,Index-1,Front-1);Hist(Front)=Hist(Front)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Front-1);
    elseif isempty(Front)
        if isempty(find(CombValue==Behind, 1)) && isempty(find(CombValue==Index,1))
            CombValue(rcomb+1,1)=Index;CombNum(rcomb+1,1)=OriHist(Index);
            CombValue(rcomb+1,2)=Behind;CombNum(rcomb+1,2)=OriHist(Behind);
        elseif isempty(find(CombValue==Behind, 1))
            [R,~]=find(CombValue==Index, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Behind;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Behind);
        elseif isempty(find(CombValue==Index, 1))
            [R,~]=find(CombValue==Behind, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Index;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Index);
        else
            [R,~]=find(CombValue==Behind, 1);[R1,~]=find(CombValue==Index, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,Index-1,Behind-1);Hist(Behind)=Hist(Behind)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Behind-1);
    elseif Hist(Front)*abf<Hist(Behind)*abb
         if isempty(find(CombValue==Front, 1)) && isempty(find(CombValue==Index,1))
            CombValue(rcomb+1,1)=Index;CombNum(rcomb+1,1)=OriHist(Index);
            CombValue(rcomb+1,2)=Front;CombNum(rcomb+1,2)=OriHist(Front);
        elseif isempty(find(CombValue==Front, 1))
            [R,~]=find(CombValue==Index, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Front;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Front);
        elseif isempty(find(CombValue==Index, 1))
            [R,~]=find(CombValue==Front, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Index;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Index);
        else
            [R,~]=find(CombValue==Front, 1);[R1,~]=find(CombValue==Index, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,Index-1,Front-1);Hist(Front)=Hist(Front)+HistMin;
    else
         if isempty(find(CombValue==Behind, 1)) && isempty(find(CombValue==Index,1))
            CombValue(rcomb+1,1)=Index;CombNum(rcomb+1,1)=OriHist(Index);
            CombValue(rcomb+1,2)=Behind;CombNum(rcomb+1,2)=OriHist(Behind);
        elseif isempty(find(CombValue==Behind, 1))
            [R,~]=find(CombValue==Index, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Behind;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Behind);
        elseif isempty(find(CombValue==Index, 1))
            [R,~]=find(CombValue==Behind, 1);
            CombValue(R,length(find(CombValue(R,:)>0))+1)=Index;CombNum(R,length(find(CombValue(R,:)>0)))=OriHist(Index);
        else
            [R,~]=find(CombValue==Behind, 1);[R1,~]=find(CombValue==Index, 1);LEN=length(find(CombValue(R,:)>0));
            CombValue(R1,length(find(CombValue(R1,:)>0))+1:length(find(CombValue(R1,:)>0))+LEN)=CombValue(R,1:LEN);CombNum(R1,length(find(CombNum(R1,:)>0))+1:length(find(CombNum(R1,:)>0))+LEN)=CombNum(R,1:LEN);
            CombValue(R,:)=[];CombNum(R,:)=[];
        end
        ImgBuff=ImgOut;ImgOut=move(ImgOut,Index-1,Behind-1);Hist(Behind)=Hist(Behind)+HistMin;
%         LM=locationmap(ImgBuff,ImgOut,i-1,Behind-1);
    end
end
%����Location Map
[~,HistIdx]=sort(Hist);Zeros=length(find(Hist==0));[R,C]=size(CombValue);CombNumBackup=CombNum;
for i=1:R
    for j=1:C
        CombNum(i,j)=CombNumBackup(i,j)/sum(CombNumBackup(i,:),2);
    end
end
for i=1:R
    LEN=length(find(CombValue(i,:)>0));
    CVMIN=min(CombValue(i,1:LEN));
    ZeroBefore=sum(HistIdx(1:Zeros)<CVMIN);Lc=CVMIN-ZeroBefore;
    pseq=CombNum(i,1:length(find(CombNum(i,:)>0)));
    core=huff(pseq);%������������,���������ö���
        for k=1:512
            for l=1:512
                j=find(CombValue(i,1:LEN)==ImgIn(k,l)+1);
                if ~isempty(j)
                    auxinfoI=[auxinfoI core{j}-48];
                end
            end
        end   
    for j=LEN:-1:1
        auxinfoI=[dec2bin(CombNumBackup(i,j),4)-48 auxinfoI];
    end
    auxinfoI=[dec2bin(Lc,8)-48 auxinfoI];
end


ImgRev=zeros(size(ImgIn));
%���غ�CE����
disp('��ʼ��������ʣ��Ҷ�ֵ�����ڷ�ֵ������λ');
HistNew=[];Trans=zeros(256,256);TransOrigin=zeros(256,256);
[HistSort,HistIdx]=sort(Hist);
HistPeak=HistIdx(end:-1:end+1-PeakNum);HistPeakValue=HistSort(end:-1:end+1-PeakNum);

for i=1:256
    if Hist(i)~=0
        HistNew=[HistNew Hist(i)];
        Trans(length(HistNew),length(HistNew))=Hist(i);
        [r,c]=find(ImgOut==i-1);
        for k=1:length(r)
            ImgRev(r(k),c(k))=length(HistNew)-1;
        end
        if ~isempty(find(HistPeak==i, 1))
            Trans(length(HistNew),length(HistNew))=0;HistNew=[HistNew 0];
            if i==256
                Trans(length(HistNew)-1,length(HistNew)-1)=Hist(i);%ǰ���
%                 Trans(length(HistNew)-1,length(HistNew))=0;
            elseif i==1
                Trans(length(HistNew),length(HistNew))=Hist(i);%���գ�ǰ���޸ĵ�����ֵ��Ҫ+1��
%                 Trans(length(HistNew),length(HistNew)-1)=0;
                for k=1:length(r)
                    ImgRev(r(k),c(k))=ImgRev(r(k),c(k))+1;
                end
            elseif Hist(i-1)<Hist(i+1)
                Trans(length(HistNew)-1,length(HistNew)-1)=Hist(i);%ǰ���
%                 Trans(length(HistNew)-1,length(HistNew))=0;
            else
                Trans(length(HistNew),length(HistNew))=Hist(i);%���գ�ǰ���޸ĵ�����ֵ��Ҫ+1��
%                 Trans(length(HistNew),length(HistNew)-1)=0;
                for k=1:length(r)
                    ImgRev(r(k),c(k))=ImgRev(r(k),c(k))+1;
                end
            end
        end
    end
end
%������0����HistNew
disp('��ʼ���ԭʼֱ��ͼ...');
Ones=find(Hist>0);HistWeight=0;HeadZeros=0;MinWeight=+inf;
for i=1:length(Ones)
    HistWeight=HistWeight+Ones(i)*Hist(Ones(i));
end
for i=0:256-length(HistNew)
    OutWeight=0;
    for j=1:length(HistNew)
        OutWeight=OutWeight+(i+j)*HistNew(j);
    end
    deltaWeight=abs(OutWeight-HistWeight);
    if deltaWeight<MinWeight
        MinWeight=deltaWeight;HeadZeros=i;
    end
end
len0=length(HistNew);

ImgRev=ImgRev+HeadZeros;
% ImgRev=uint8(ImgRev);%TMǰ������Ч��ͼ
TransTemp=Trans;Trans=zeros(256,256);
Trans(HeadZeros+1:HeadZeros+len0,HeadZeros+1:HeadZeros+len0)=TransTemp(1:len0,1:len0);
for i=1:256
    HistNew(i)=Trans(i,i);
end
Trans=Trans*2048/(512*512);
for i=1:256
    for j=1:256
        if Trans(i,j)<=0.5 && Trans(i,j)>0
            Trans(i,j)=1;
        else
            Trans(i,j)=round(Trans(i,j));%����������ѹ��ת�ƾ���Ĵ�С,Trans��Ȼ��256*256
        end
    end
end

auxPreprocess=[dec2bin(OriZero,8)-48 auxinfoI auxinfoZeroValue];

%%
% Transfer Matrix
disp('��ʼ����ת�ƾ����������ҪһЩʱ��...');

[T,rate,mssim,mpcqi,X]=Matrix(20000,Trans,1,0,ImgIn,ImgRev,row,col);
% for i=1:256
%     Sum=sum(T(i,:),2);
%     if Sum~=0
%         T(i,:)=T(i,:)/Sum;
%     end
% end
% PLOT1=1-T;
rate4=rate*512*512;

HistOptimal=sum(T*512*512/2048);
x=50:50:50*length(rate);
hold on,
% figure,imshow(PLOT1);
plot(rate*512*512)

% print -dmeta filename
% legend('A','B');
% plot(x,HistOptimal','red');
% hold on;
% plot(x,Hist,'blue');
% hold off;
% figure;
% subplot(1,2,1),plot(rate,mssim,'red');
% subplot(1,2,2),plot(rate,mpcqi,'red');
Realpayload=rate(end)*512*512-length(auxPreprocess);
% [bpp,SSIM,Pcqi,ImgComp,PurePayload]=RDHCE(ImgIn,50,rate(end),filename,pathname);
% [RCE(1),REE(1),RMBE(1)]=similarity(ImgIn,ImgComp);
% subplot(1,2,1),hold on,plot(bpp,SSIM,'blue'),hold off;
% subplot(1,2,2),hold on,plot(bpp,Pcqi,'blue'),hold off;

ImgIn=double(ImgIn);X=double(X);
[RCE,REE,RMBE]=similarity(ImgIn,X);
[RealSSIM, ~] = ssim(ImgIn,X);
[PSNR,~]=psnr(ImgIn,X);

% X=uint8(X);
% figure,imshow(X);


[RCE,REE,RMBE,PSNR,RealSSIM,ApproxPayload,ZZ]=PEEmain(ImgIn,X,filename,pathname,Realpayload);


% Z=uint8(Z);ImgIn=uint8(ImgIn);
% figure;
% subplot(1,3,1),imshow(ImgIn);
% subplot(1,3,2),imshow(ImgComp);
% subplot(1,3,3),imshow(Z);
% imwrite(Z,[pathname 'pic\' filename(1:end-4) '_target.bmp']);
disp(['Ƕ����ɣ�REE:' num2str(REE) ',RMBE:' num2str(RMBE) ',RCE:' num2str(RCE) ',PSNR:' num2str(PSNR) ',SSIM:' num2str(RealSSIM) ]);
disp(['Payload:' num2str(Realpayload+ApproxPayload)]);
disp(['ͼ��Ԥ���������������' num2str(length(auxPreprocess))]);
% figure,imshow(X);



% %%
% % embed algorithm
% % ImgRev=double(ImgRev);
% auxDeltaT=quantize(HistNew,PeakNum);
% %��ʱһ��С�鲻���Ա�������LSB����˿�����Ҫ���С�����������Ϣ
% BlockNum=1;
% disp(['��ǰ������Ϣ��Ҫ��LSB�������' num2str(BlockNum)]);
% lenAP=length(auxPreprocess);
% auxPreprocess=[dec2bin(lenAP,14)-48 auxPreprocess];
% false=0;
% while false==0
% disp('��ʼǶ����Ϣ');
% futility_block=[];%��Ч�Ŀ����
% Z=ImgRev;
% aux_info=[];aux_count=0;payload=[];
% code=round(rand(1,200000));code=[auxPreprocess code];CODE=code;
% [ps,replace,index]=ps_replace(T);%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
% [ps1,replace1,index1]=ps_replace(T');%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
% h=waitbar(0,'Encoding...');aux_extra=[];
% for block=0:63%��ͼ���зֳ�64*64��64��
%       waitbar(block/64,h,['Block:' num2str(block+1)]);r_rev=64*(mod(block,8));c_rev=64*floor(block/8);%���и��ݿ����������
%       payload_block=[];
%       if block==BlockNum%��block1��LSBд���block1��ʼ�Ļָ�������
%           LSB=[];
%           for lsbBlock=1:BlockNum
%             lsbj_rev=(lsbBlock-1)*64;
%             for lsbi=1:64
%                 for lsbj=1:64
%                     LSB=[LSB mod(Z(lsbi,lsbj+lsbj_rev),2)];
%                 end
%             end
%           end
%           code=[LSB code];
%       end
%       if block~=0
%           code=[aux_info code];%�ڶ���С�鿪ʼ���aux info
%           aux_count=aux_count+length(aux_info);
% %           aux_info=[];
%       end
% 
% %         H(Y|X)
%         Z1=ImgRev(r_rev+1:r_rev+64,c_rev+1:c_rev+64);
%         index0=[];
%         for qq=1:256%�õ�һһ��Ӧ����ת��
%             if isempty(find(index==qq, 1)) && sum(T(qq,:),2)~=0
%                 index0=[index0 qq];
%             end
%         end
%         for qt=1:length(index0)
%             [r,c]=find(Z1==index0(qt)-1);%Ѱ������ʱ��-1
%             r0=find(T(index0(qt),:)>0);
%                for z=1:length(r)
%                    Z(r_rev+r(z),c_rev+c(z))=r0-1;%��ֵʱ��-1
%                end
%         end
%         for q=1:length(index)
%             [r,c]=find(Z1==index(q)-1);%Ѱ������ʱ��-1
%             pseq=ps(index(q),1:find(ps(index(q),:),1,'last'));
%             core=huff(pseq);%������������
%             corelen=[];
%             for icore=1:length(core)
%                 corelen(icore)=length(core{icore});%������������
%             end
%             for ir=1:length(r)
%                codestring='';
%                for iserlen=1:max(corelen)
%                   codestring=strcat(codestring,num2str(code(iserlen))); 
%                   coreindex=find(corelen==iserlen);watch=0;
%                   for ifind=1:length(coreindex)
%                      if strcmp(codestring,core{coreindex(ifind)})==1
%                          Z(r_rev+r(ir),c_rev+c(ir))=replace(index(q),coreindex(ifind))-1;%�滻��-1
%                          payload_block=[payload_block code(1:iserlen)];
%                          code(1:iserlen)=[];watch=1;
%                          break; 
%                      end
%                   end
%                   if watch==1
%                     break;
%                   end
%                end
%             end
%         end
%         lenpay=length(payload_block);
%         if block~=0 && lenaux>lenpay%���aux�Ƿ񳬳�payload
%             futility_block=[futility_block block];
% %             ��ÿ�Ƕ����Ϣ��������ԭ����aux��12λ��1,�����˶�block63�Ĵ���
%             aux_extra=aux_info(lenpay+1:end);
%             lenauxextra=length(aux_extra);
%             aux_extra_bin=dec2bin(lenauxextra,11)-48;
%             code(1:lenauxextra)=[];
%             aux_extra=[1 aux_extra_bin aux_extra];
%         end
%         aux_info=[];
% %         H(X|Y)
%         Z1=Z(r_rev+1:r_rev+64,c_rev+1:c_rev+64);%Z1�Ѿ������޸�
%         for q=1:length(index1)
%             [r,c]=find(Z1==index1(q)-1);%Ѱ������ʱ��-1
%             pseq=ps1(index1(q),1:find(ps1(index1(q),:),1,'last'));
%             core=huff(pseq);%����������
%             for ir=1:length(r)
%                origin=ImgRev(r_rev+r(ir),c_rev+c(ir));serie=find(replace1(index1(q),:)==origin+1);%��ȡ����+1
%                huffcode=core{serie};
%                for istore=1:length(huffcode)
%                   if  huffcode(istore)=='1'
%                       aux_info=[aux_info 1]; 
%                   else
%                       aux_info=[aux_info 0];
%                   end
%                end
%             end 
%         end
%         lenaux_bin=dec2bin(length(aux_info),12)-48;
%         aux_info=[lenaux_bin aux_info];lenaux=length(aux_info);
%         payload=[payload payload_block];
%         if ~isempty(aux_extra)
%             aux_info=[aux_extra aux_info];lenaux=length(aux_info);
%             aux_extra=[];
%         end   
% end
% % aux_count=aux_count+length(aux_info);
% %������Ҫ��ͼ����ֱ�Ӷ�ȡ�ĸ�����Ϣ
% AUX=[dec2bin(BlockNum-1,1)-48 aux_info auxDeltaT];z=1;
% disp(['auxDeltaT���ȣ�' num2str(length(auxDeltaT))]);
% disp(['auxPreprocess���ȣ�' num2str(length(auxPreprocess))]);
% disp(['aux_info���ȣ�' num2str(length(aux_info))]);
% Realpayload=length(payload)-aux_count-BlockNum*64*64-length(auxPreprocess);
% disp(['--->��ǰPayload��' num2str(Realpayload)]);
% if length(AUX)>(BlockNum*64*64)%���������������������Ч����һ��LSB����Ƕ��
%     BlockNum=BlockNum+1;
%     disp(['����AUX���ȳ�����ǰ�����С������Ƕ�������Ч����������Ƕ�롣��ǰ��Ҫ������' num2str(BlockNum)]);
% else
%     false=1;
% end
% end
% %��[BlockNum aux_info auxDeltaT auxPreprocess]������LSB
% disp('��ʼ��дLSB����...');
% for lsbBlock=1:BlockNum
%     lsbj_rev=(lsbBlock-1)*64;
%     for lsbi=1:64
%                  for lsbj=1:64
%                       Z(lsbi,lsbj+lsbj_rev)=Z(lsbi,lsbj+lsbj_rev)-mod(Z(lsbi,lsbj+lsbj_rev),2)+AUX(z);
%                       z=z+1;
%                       if z>length(AUX)
%                         break;
%                       end
%                  end
%                  if z>length(AUX)
%                       break;
%                  end
%     end
% end
% [RCE(2),REE(2),RMBE(2)]=similarity(ImgIn,Z);
% [RealSSIM, ~] = ssim(ImgIn,Z);
% % [RealPCQI, ~] = PCQI(ImgIn,Z);
% [PSNR,MSE]=psnr(ImgIn,Z);
% Z=uint8(Z);ImgIn=uint8(ImgIn);
% figure;
% subplot(1,3,1),imshow(ImgIn);
% subplot(1,3,2),imshow(ImgComp);
% subplot(1,3,3),imshow(Z);
% imwrite(Z,[pathname 'pic\' filename(1:end-4) '_target.bmp']);
% disp(['Ƕ����ɣ�REE:' num2str(REE(2)) ',RMBE:' num2str(RMBE(2)) ',RCE:' num2str(RCE(2)) ',PSNR:' num2str(PSNR) ',SSIM:' num2str(RealSSIM) ',PCQI:' num2str(RealPCQI)]);
% % print -dmeta filename
% 
% 
% %%
% % ===��2����Ƕ�룺��С���任���ƵǶ��===
% T_ini = 10; %12;%��T����10ʱ�����ܵ��������>255 ��<0��%���Ǹ�Ϊ�����Ա�Ƕ�������Ϣ������ֵ��ֵ��ʾΪ8λ
% Overhead_len_total=0;
% Payload_rate_total =0; 
% Payload_rate = 0.5; %Ԥ����Ƕ�븺����,���Ըı䣬һЩͼ������Щ����Lena��Ԥ��λ0.5,barbara��СЩ��
% LL =  ceil((5/4)*(T_ini+1));
% while 1
%     [img_histModi_1,Loca_map_1] = histogram_modi_1(double(Z),LL);
%      % ====  Perform integer LWT of the image + �����������  =====
%     [N,T,m,n,cA,coefQC_cH,coefQC_cV,coefQC_cD,e,cH,cV,cD] = lwt_QE(Loca_map_1,img_histModi_1,T_ini ,Payload_rate );
%     % == coefQC_cH,coefQC_cV,coefQC_cD Ϊ M*M cell�ṹ  ==
%     % ==== ������Ϣ��Overhead��BDS+��ֵT+�������e��+ˮӡw��,�ж��Ƿ�����Ƕ�븺���� ====
%     [Overhead_w,Overhead_len,w_len,overhead_toomuch] = generate_overhead_wm(Loca_map_1,T_ini ,N,m,n,e,Payload_rate);
%       
%     if overhead_toomuch==1  %������Ƕ�븺����
%        Payload_rate = Payload_rate - 0.05; %���͸�����,����Payload_rate���֪�����
%        PSNR_wm = 0;
%        continue;
%     end 
%     %-----��Ƕ�뵽LH�Ӵ���Ȼ��HL,HH�Ӵ�-----
%     [coefQC_cHW,coefQC_cVW,coefQC_cDW] = embed_function(Overhead_w,m,n,coefQC_cH,coefQC_cV,coefQC_cD,N);
%     % ====  Perform integer ILWT of the image   =====    
%         img_name=filename;
%     [PSNR_wm,mssim_wm,img_ori_wm_restruct ] = ilwt_QE(cA,coefQC_cHW,coefQC_cVW,coefQC_cDW,img_name,Payload_rate ); 
% 
%     Payload_rate_total = Payload_rate;   
% %     Overhead_len_total = Overhead_len; 
% 
% %     filename_WM = sprintf('%s_%.3f%s%d%s%d%s',img_name,Payload_rate_total,'_L',L_best ,'_T',T_ini,'_WM.bmp');
%     max_pixelval = max(max(img_ori_wm_restruct)) ;
%     min_pixelval = min(min(img_ori_wm_restruct)) ;
%     if max_pixelval>255 || min_pixelval<0
%        LL = LL+1;  %���ʱ����ֱ��ͼ����ѹ����,���֪����� 
%        disp('overflow');
%        continue;
%     else
%         break; %
%     end
% end
% % t_escape = toc;
% % disp('escape time for embedding:');
% % disp(t_escape); 
% 
% figure;
% imshow(uint8(img_ori_wm_restruct));
% imwrite(uint8(img_ori_wm_restruct),'IWT.bmp'); %Image embedded watermarking 
% % Overhead_len_total = Overhead_len_total + Overhead_len;
% % wm_len_total = pure_hide_wm_len_best + w_len;
% % disp(pure_hide_wm_len_best);
% disp(w_len);
% % fid = fopen('experiment_result.txt','a');
% % fprintf(fid,'\n%s: %s%0.3f %s%.2f %s%.3f %s%.4f %s%d %s%d',filename_WM, ...
% %     'pure hiding rate', Payload_rate_total,'psnr_val=',PSNR_wm,'mssim =',mssim_wm,'rce_val =',rce_val,'wm_all=',wm_len_total,'Overhead_all=',Overhead_len_total);
% % fclose(fid);
% measurement(ImgIn,uint8(img_ori_wm_restruct));
% 
% 
% %%
% %PEH Shifting
% % [RCE,REE,RMBE,PSNR,RealSSIM,RealPCQI,ZZ]=PEEmain(ImgIn,Z,filename,pathname,Realpayload);
% 
% 
% % %%
% % %IWT embed����test
% % Z=ImgIn;
% % [W,encode,auxlen,IO,V,H,D,A]=IWTembed(Z);
% % %%
% % %IWT decode
% % [IW,encodeCompare,auxlen1]=IWTdebed(W,IO,V,H,D,A);
% % Diff=double(IW)-double(ImgIn);
% % 
% % %
% % % decoding algorithm
% % debed=[];aux_extra=[];storage=[];
% % Z_recover=Z;
% % Trans_recover=dequantize(auxDeltaT);%2560bits
% % [T_quan_recover]=Matrix(20000,Trans,1,1);
% % 
% % dT=T-T_quan_recover;
% % 
% % h=waitbar(0,'Decoding...');
% % [ps,replace,index]=ps_replace(T_quan_recover);%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
% % [ps1,replace1,index1]=ps_replace(T_quan_recover');%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
% % for block=63:-1:0%��ͼ���зֳ�32*32��64��
% %       waitbar((64-block)/64);r_rev=32*(mod(block,8));c_rev=32*floor(block/8);%���и��ݿ����������
% % %       ȡ��auxilary information
% %       if block~=63
% %           if debed(1)~=1
% %               lenaux=bin2dec(char(debed(1:12)+48));
% %               aux_info=debed(13:12+lenaux);
% %               lenauxextra=0;
% %           else
% %               lenauxextra=bin2dec(char(debed(2:12)+48));
% %               aux_extra=debed(13:12+lenauxextra);
% %               lenaux=bin2dec(char(debed(13+lenauxextra:24+lenauxextra)+48));
% %               aux_info=debed(25+lenauxextra:24+lenauxextra+lenaux);
% %           end
% %       else
% %           if aux_info(1)~=1
% %               lenaux=bin2dec(char(aux_info(1:12)+48));
% %               aux_info=aux_info(13:12+lenaux);lenauxextra=0;
% %           else
% %               lenauxextra=bin2dec(char(aux_info(2:12)+48));
% %               aux_extra=aux_info(13:12+lenauxextra);
% %               lenaux=bin2dec(char(aux_info(13+lenauxextra:24+lenauxextra)+48));
% %               aux_info=aux_info(25+lenauxextra:24+lenauxextra+lenaux);
% %           end
% %       end
% %       if lenaux+lenauxextra<length(debed)%ȡ��Ƕ����Ϣ
% %           if lenauxextra~=0
% %               storage=[debed(25+lenauxextra+lenaux:end) storage];
% %           else
% %               storage=[debed(13+lenaux:end) storage];
% %           end
% %       end
% %       debed=[];
% %         H(X|Y)
% %         Z1=Z(r_rev+1:r_rev+32,c_rev+1:c_rev+32);
% %         index0=[];
% %         for qq=1:256%�õ�һһ��Ӧ����ת��
% %             if isempty(find(index1==qq, 1))
% %                 index0=[index0 qq];
% %             end
% %         end
% %         for qt=1:length(index0)
% %             [r,c]=find(Z1==index0(qt)-1);%Ѱ������ʱ��-1
% %             r0=find(T_quan_recover(:,index0(qt))>0);
% %                for z=1:length(r)
% %                    Z_recover(r_rev+r(z),c_rev+c(z))=r0-1;%��ֵʱ��-1
% %                end
% %         end
% %         for q=1:length(index1)
% %            [r,c]=find(Z1==index1(q)-1);
% %             pseq=ps1(index1(q),1:find(ps1(index1(q),:),1,'last'));
% %             core=huff(pseq);%������������
% %             corelen=[];
% %             for icore=1:length(core)
% %                 corelen(icore)=length(core{icore});%������������
% %             end
% %             for ir=1:length(r)
% %                codestring='';
% %                for iserlen=1:max(corelen)
% %                   codestring=strcat(codestring,num2str(aux_info(iserlen))); 
% %                   coreindex=find(corelen==iserlen);watch=0;
% %                   for ifind=1:length(coreindex)
% %                      if strcmp(codestring,core{coreindex(ifind)})==1
% %                          new=replace1(index1(q),coreindex(ifind))-1;
% %                          Z_recover(r_rev+r(ir),c_rev+c(ir))=new;%�滻��-1
% %                          aux_info(1:iserlen)=[];watch=1;
% %                          break;
% %                      end
% %                   end
% %                   if watch==1
% %                     break;
% %                   end
% %                end
% %             end
% %         end
% % 
% %         %H(Y|X)
% %         I_recover=Z_recover(r_rev+1:r_rev+32,c_rev+1:c_rev+32);%�ǻָ�ͼ��ĵ�ǰ��
% % 
% %         for q=1:length(index)
% %             [r,c]=find(I_recover==index(q)-1);%Ѱ������ʱ��-1
% %             pseq=ps(index(q),1:find(ps(index(q),:),1,'last'));
% %             core=huff(pseq);%������������
% %             for ir=1:length(r)
% %                new=Z1(r(ir),c(ir));serie=find(replace(index(q),:)==new+1);%��ȡ����+1
% %                huffcode=core{serie};
% %                for istore=1:length(huffcode)
% %                   if  huffcode(istore)=='1'
% %                       debed=[debed 1]; 
% %                   else
% %                       debed=[debed 0];
% %                   end
% %                end
% %             end 
% %         end
% %         if ~isempty(aux_extra)
% %            debed=[debed aux_extra];
% %            aux_extra=[];
% %         end
% %         imshow(Z_recover);
% % end
% % figure,imshow(Z_recover);
% % Zdiff=abs(Z_recover-ImgRev);
% % 
% % 
% % %
% % % reverse preprocessing according to auxPreprocess [Value flag LM ];
% % % ���Ƶ�����ߣ��ٲ�յ���.flag����Ϊ1������Ϊ0
% % Z_out=ImgRev;
% % HistZ=imhist(ImgRev);HistLeft=[];
% % for i=1:256
% %     if HistZ(i)~=0
% %         HistLeft=[HistLeft HistZ(i)];
% %         Z_out=move(Z_out,i-1,length(HistLeft)-1);
% %     end
% % end
% % OriZero=bin2dec(char(auxPreprocess(1:8)+48));auxPreprocess(1:8)=[];ZeroAdded=0;
% % while ~isempty(auxPreprocess)
% %     Value=bin2dec(char(auxPreprocess(1:8)+48))-1;auxPreprocess(1:8)=[];
% %     if length(auxPreprocess)>(OriZero*8)
% %         [r,c]=find(Z_out==Value);
% %         flag=auxPreprocess(1);auxPreprocess(1)=[];
% %         for i=255:-1:Value+flag%ԭbin���Ƶ���ǰValueʱ���ָ�ʱValue����Ҳ��Ҫ+1����������Ҫ
% %             Z_out=move(Z_out,i,i+1);
% %         end
% %         HistLeft=imhist(Z_out);
% %         for i=1:length(r)
% %             if auxPreprocess(1)==1
% %                 if flag==1
% %                     Z_out(r(i),c(i))=Z_out(r(i),c(i))+1;
% %                 else
% %                     Z_out(r(i),c(i))=Z_out(r(i),c(i))-1;
% %                 end
% %             end
% %             auxPreprocess(1)=[];
% %         end
% %     else
% %         for i=255:-1:Value+ZeroAdded%ԭbin���Ƶ���ǰValueʱ���ָ�ʱValue����Ҳ��Ҫ+1����������Ҫ
% %             Z_out=move(Z_out,i,i+1);
% %         end
% %         HistLeft=imhist(Z_out);ZeroAdded=ZeroAdded+1;
% %     end
% % end
% % figure,imshow(Z_out);
% % figure,imshow(Z_out-ImgIn);
% 
% % print -dmeta filename