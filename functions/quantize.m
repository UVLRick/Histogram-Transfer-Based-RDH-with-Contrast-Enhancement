function auxDeltaT=quantize(HistNew,PeakNum)%[8 8 9],HistNew�е�Ԫ�����Ϊ512*512/2048=128��7λ
HistDelta=[];H1=[];auxDeltaT=dec2bin(PeakNum,8)-48;%11λ����λΪ����
for i=1:256
    if HistNew(i)~=0
        if isempty(H1)
            H1=HistNew(i);auxDeltaT=[auxDeltaT dec2bin(i,8)-48];%��һλǰ�ж��ٸ�0
            HistDelta=[HistDelta H1];
            lenZ=max(length(find(HistNew==0))-PeakNum-(i-1),0);
            auxDeltaT=[auxDeltaT 0 dec2bin(lenZ,8)-48];%��ӷ���λ
        else
            H2=HistNew(i);
            HistDelta=[HistDelta H2-H1];
            H1=H2;
        end
    end
end

for i=1:length(HistDelta)
    if HistDelta(i)<0
        auxDeltaT=[auxDeltaT 1];
    else
        auxDeltaT=[auxDeltaT 0];
    end
%     while abs(HistDelta(i))>=2^11
%         aux=[1 1 1 1 1 1 1 1 1 1 1];HistNew(i)=HistNew(i)-(2^11-1);
%         auxDeltaT=[auxDeltaT aux];
%         lenZ=lenZ-1;auxDeltaT(17+1:24+1)=dec2bin(abs(lenZ),8)-48;
%         if lenZ<0
%             auxDeltaT(17)=1;
%         end
%         if HistDelta(i)<0%�ٴ���ӷ���λ
%             auxDeltaT=[auxDeltaT 1];
%         else
%             auxDeltaT=[auxDeltaT 0];
%         end
%         HistDelta(i)=HistDelta(i)-(2^11-1);
%     end
        aux=dec2bin(abs(HistDelta(i)),7)-48;
        auxDeltaT=[auxDeltaT aux];
end
