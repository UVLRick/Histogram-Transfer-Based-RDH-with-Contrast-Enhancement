%%
clc;close all;
addpath 'IWT/';
addpath 'arithmetic/';
addpath 'functions/';
%decoding algorithm
% load aux_info.mat aux_info;
% load auxDeltaT.mat auxDeltaT;
% load auxPreprocess.mat auxPreprocess;
Z=imread('target.bmp');AUX=[];Z_recover=Z;
%��n��block��ȡ��[aux_info auxDeltaT auxPreprocess]
BlockNum=bin2dec(char(mod(Z(1,1),2)+48))+1;
disp(['��ǰLSB�������' num2str(BlockNum)]);
for lsbBlock=1:BlockNum
    lsbj_rev=(lsbBlock-1)*64;
    for i=1:64
        for j=1:64
            AUX=[AUX mod(Z(i,j+lsbj_rev),2)];
        end
    end
end
AUX(1)=[];
auxlen=bin2dec(char(AUX(1:12)+48));aux_info=AUX(1:12+auxlen);
lenZ=bin2dec(char(AUX(auxlen+30:auxlen+29+8)+48));
if AUX(auxlen+29)==1
    lenZ=-lenZ;
end
lenDeltaT=12*(256-bin2dec(char(AUX(auxlen+13:auxlen+12+8)+48))-bin2dec(char(AUX(auxlen+21:auxlen+20+8)+48))-lenZ+1)+25;
auxDeltaT=AUX(auxlen+13:auxlen+12+lenDeltaT);
disp(['auxDeltaT���ȣ�' num2str(length(auxDeltaT))]);
disp(['aux_info���ȣ�' num2str(length(aux_info))]);

debed=[];aux_extra=[];storage=[];
disp('������auxDeltaT���ԭʼһάֱ��ͼ');
Trans_recover=dequantize(auxDeltaT);%256*12bits
disp('��ʼ����ת�ƾ����������ҪһЩʱ��...');
[T_quan_recover]=Matrix(20000,Trans_recover,1,1);

h=waitbar(0,'Decoding...');
[ps,replace,index]=ps_replace(T_quan_recover);%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
[ps1,replace1,index1]=ps_replace(T_quan_recover');%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
disp('��ʼ��ȡ��Ϣ...');
for block=63:-1:0%��ͼ���зֳ�64*64��64��
      waitbar((64-block)/64);r_rev=64*(mod(block,8));c_rev=64*floor(block/8);%���и��ݿ����������
      %ȡ��auxilary information
      if block~=63
          if debed(1)~=1
              lenaux=bin2dec(char(debed(1:12)+48));
              aux_info=debed(13:12+lenaux);
              lenauxextra=0;
          else
              lenauxextra=bin2dec(char(debed(2:12)+48));
              aux_extra=debed(13:12+lenauxextra);
              lenaux=bin2dec(char(debed(13+lenauxextra:24+lenauxextra)+48));
              aux_info=debed(25+lenauxextra:24+lenauxextra+lenaux);
          end
      else
          if aux_info(1)~=1
              lenaux=bin2dec(char(aux_info(1:12)+48));
              aux_info=aux_info(13:12+lenaux);lenauxextra=0;
          else
              lenauxextra=bin2dec(char(aux_info(2:12)+48));
              aux_extra=aux_info(13:12+lenauxextra);
              lenaux=bin2dec(char(aux_info(13+lenauxextra:24+lenauxextra)+48));
              aux_info=aux_info(25+lenauxextra:24+lenauxextra+lenaux);
          end
      end
      if lenaux+lenauxextra<length(debed)%ȡ��Ƕ����Ϣ
          if lenauxextra~=0
              storage=[debed(25+lenauxextra+lenaux:end) storage];
          else
              storage=[debed(13+lenaux:end) storage];
          end
      end
      debed=[];
        %H(X|Y)
        Z1=Z(r_rev+1:r_rev+64,c_rev+1:c_rev+64);
        index0=[];
        for qq=1:256%�õ�һһ��Ӧ����ת��
            if isempty(find(index1==qq, 1))
                index0=[index0 qq];
            end
        end
        for qt=1:length(index0)
            [r,c]=find(Z1==index0(qt)-1);%Ѱ������ʱ��-1
            r0=find(T_quan_recover(:,index0(qt))>0);
               for z=1:length(r)
                   Z_recover(r_rev+r(z),c_rev+c(z))=r0-1;%��ֵʱ��-1
               end
        end
        for q=1:length(index1)
           [r,c]=find(Z1==index1(q)-1);
            pseq=ps1(index1(q),1:find(ps1(index1(q),:),1,'last'));
            core=huff(pseq);%������������
            corelen=[];
            for icore=1:length(core)
                corelen(icore)=length(core{icore});%������������
            end
            for ir=1:length(r)
               codestring='';
               for iserlen=1:max(corelen)
                  codestring=strcat(codestring,num2str(aux_info(iserlen))); 
                  coreindex=find(corelen==iserlen);watch=0;
                  for ifind=1:length(coreindex)
                     if strcmp(codestring,core{coreindex(ifind)})==1
                         new=replace1(index1(q),coreindex(ifind))-1;
                         Z_recover(r_rev+r(ir),c_rev+c(ir))=new;%�滻��-1
                         aux_info(1:iserlen)=[];watch=1;
                         break;
                     end
                  end
                  if watch==1
                    break;
                  end
               end
            end
        end

        %H(Y|X)
        I_recover=Z_recover(r_rev+1:r_rev+64,c_rev+1:c_rev+64);%�ǻָ�ͼ��ĵ�ǰ��

        for q=1:length(index)
            [r,c]=find(I_recover==index(q)-1);%Ѱ������ʱ��-1
            pseq=ps(index(q),1:find(ps(index(q),:),1,'last'));
            core=huff(pseq);%������������
            for ir=1:length(r)
               new=Z1(r(ir),c(ir));serie=find(replace(index(q),:)==new+1);%��ȡ����+1
               huffcode=core{serie};
               for istore=1:length(huffcode)
                  if  huffcode(istore)=='1'
                      debed=[debed 1]; 
                  else
                      debed=[debed 0];
                  end
               end
            end 
        end
        if block==BlockNum
            for lsbBlock=1:BlockNum
                lsbj_rev=(lsbBlock-1)*64;
                for lsbi=1:64
                    for lsbj=1:64
                        Z(i,j+lsbj_rev)=Z(i,j+lsbj_rev)-mod(Z(i,j+lsbj_rev),2)+storage(1);
                        storage(1)=[];
                    end
                end
            end
        end
        if ~isempty(aux_extra)
           debed=[debed aux_extra];
           aux_extra=[];
        end
end
figure,imshow(Z_recover);
%��ȡauxPreprocess
auxLen=bin2dec(char(storage(1:14)+48));
auxPreprocess=storage(15:14+auxLen);
storage(1:14+auxLen)=[];
%%
%reverse preprocessing according to auxPreprocess [Value flag LM ];
%���Ƶ�����ߣ��ٲ�յ���.flag����Ϊ1������Ϊ0
disp('��Ϣ��ȡ��ɣ���ʼ����Preprocess�ķ��任...');
Z_out=Z_recover;
HistZ=imhist(Z_recover);HistLeft=[];
for i=1:256
    if HistZ(i)~=0
        HistLeft=[HistLeft HistZ(i)];
        Z_out=move(Z_out,i-1,length(HistLeft)-1);
    end
end
OriZero=bin2dec(char(auxPreprocess(1:8)+48));auxPreprocess(1:8)=[];ZeroAdded=0;
while ~isempty(auxPreprocess)
    Value=bin2dec(char(auxPreprocess(1:8)+48))-1;auxPreprocess(1:8)=[];
    if length(auxPreprocess)>(OriZero*8)
        [r,c]=find(Z_out==Value);
        flag=auxPreprocess(1);auxPreprocess(1)=[];
        for i=255:-1:Value+flag%ԭbin���Ƶ���ǰValueʱ���ָ�ʱValue����Ҳ��Ҫ+1����������Ҫ
            Z_out=move(Z_out,i,i+1);
        end
        HistLeft=imhist(Z_out);
        for i=1:length(r)
            if auxPreprocess(1)==1
                if flag==1
                    Z_out(r(i),c(i))=Z_out(r(i),c(i))+1;
                else
                    Z_out(r(i),c(i))=Z_out(r(i),c(i))-1;
                end
            end
            auxPreprocess(1)=[];
        end
    else
        for i=255:-1:Value+ZeroAdded%ԭbin���Ƶ���ǰValueʱ���ָ�ʱValue����Ҳ��Ҫ+1����������Ҫ
            Z_out=move(Z_out,i,i+1);
        end
        HistLeft=imhist(Z_out);ZeroAdded=ZeroAdded+1;
    end
end
figure,imshow(Z_out);
figure,imshow(Z_out-ImgIn);
disp('ԭʼͼ��ָ���ɣ�');