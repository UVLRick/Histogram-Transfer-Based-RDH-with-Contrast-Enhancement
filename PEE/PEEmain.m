function [RCE,REE,RMBE,PSNR,RealSSIM,ApproxPayload,ZZ]=PEEmain(OriIm,I,filename,pathname,prepay)
% This file is RDH with PEH transfer
% Originally introduced by Pro.Zhang 
% "Reversible Data Hiding with Optimal Transfer"
% Code author: William Ying
% 2018.1.1
OriIm=double(OriIm);I=double(I);%[RCE,REE,RMBE,PSNR,RealSSIM,RealPCQI,ZZ]
%%
%embedding
disp('SetA��ʼǶ����Ϣ');
[PEH,Ie,y,seq]=prediction(I,0);%Ie��prediction error,y������
[T,P1,~]=RevMat(0.125,20000,PEH);

%%
%ע�⣺ֻҪ��ת�Ƶĸ��������κ�һ���ᳬ���߽磬������������أ�
futility_block=[];%��Ч�Ŀ����
Z=I;Ienew=Ie;
aux_info=[];aux_count=0;payload=[];
code=round(rand(1,200000));CODE=code;
[ps,replace,index]=ps_replace(T);%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
[ps1,replace1,index1]=ps_replace(T');%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
h=waitbar(0,'Encoding...');aux_extra=[];
for block=0:63%��ͼ���зֳ�64*64��64��
      waitbar(block/64,h,['Block:' num2str(block+1)]);r_rev=64*(mod(block,8));c_rev=64*floor(block/8);%���и��ݿ����������
      payload_block=[];sat_value=[];sat_r=[];sat_c=[];
%       if block==1%��block1��LSBд���block1��ʼ�Ļָ�������
%           LSB=[];
%           for lsbBlock=1:1
%             lsbj_rev=(lsbBlock-1)*64;
%             for lsbi=1:64
%                 for lsbj=1:64
%                     LSB=[LSB mod(Z(lsbi,lsbj+lsbj_rev),2)];
%                 end
%             end
%           end
%           code=[LSB code];
%       end
      if block~=0
          code=[aux_info code];%�ڶ���С�鿪ʼ���aux info
          aux_count=aux_count+length(aux_info);
      end
%         H(Y|X)
        Z1=I(r_rev+1:r_rev+64,c_rev+1:c_rev+64);Ie1=Ie(r_rev+1:r_rev+64,c_rev+1:c_rev+64);
        for q=1:length(index)
            [r,c]=find(Ie1==y(index(q)));%Ѱ������ʱ��-1
            %ȥ����SetB������ء��߽������Լ����͵����أ�������λ����Ϣ
            irmv=1;
            while irmv<=length(r)
                if mod(r(irmv)+c(irmv),2)==1 || r_rev+r(irmv)==1 || r_rev+r(irmv)==512 || c_rev+c(irmv)==1 || c_rev+c(irmv)==512
                    r(irmv)=[];c(irmv)=[];
                    irmv=irmv-1;
                else
                    len=sum(replace(index(q),:)>0);
                    PossibleError=y(replace(index(q),1:len));
                    PossibleValue=Z1(r(irmv),c(irmv))-Ie1(r(irmv),c(irmv))+PossibleError;
                    if ~isempty(find(PossibleValue>255, 1)) && ~isempty(find(PossibleValue<0, 1))
                        sat_value=[sat_value Z1(r(irmv),c(irmv))];sat_r=[sat_r r(irmv)];sat_c=[sat_c c(irmv)];
                        %�Ƿ���Ҫ���Ҷ�ֵ�޸�Ϊ0 or 255��
                        r(irmv)=[];c(irmv)=[];
                        irmv=irmv-1;
                    end
                end
                irmv=irmv+1;
            end
            pseq=ps(index(q),1:find(ps(index(q),:),1,'last'));
            core=huff(pseq);%������������
            corelen=[];
            for icore=1:length(core)
                corelen(icore)=length(core{icore});%������������
            end
            for ir=1:length(r)
               codestring='';
               for iserlen=1:max(corelen)
                  codestring=strcat(codestring,num2str(code(iserlen))); 
                  coreindex=find(corelen==iserlen);watch=0;
                  for ifind=1:length(coreindex)
                     if strcmp(codestring,core{coreindex(ifind)})==1
                         Z(r_rev+r(ir),c_rev+c(ir))=Z(r_rev+r(ir),c_rev+c(ir))-Ie1(r(ir),c(ir));
                         Z(r_rev+r(ir),c_rev+c(ir))=Z(r_rev+r(ir),c_rev+c(ir))+y(replace(index(q),coreindex(ifind)));
                         Ienew(r_rev+r(ir),c_rev+c(ir))=y(replace(index(q),coreindex(ifind)));
                         payload_block=[payload_block code(1:iserlen)];
                         code(1:iserlen)=[];watch=1;
                         break; 
                     end
                  end
                  if watch==1
                    break;
                  end
               end
            end
        end
        lenpay=length(payload_block);
        if block~=0 && lenaux>lenpay%���aux�Ƿ񳬳�payload
            futility_block=[futility_block block];
%             ��ÿ�Ƕ����Ϣ��������ԭ����aux��12λ��1,�����˶�block63�Ĵ���
            aux_extra=aux_info(lenpay+1:end);
            lenauxextra=length(aux_extra);
            aux_extra_bin=dec2bin(lenauxextra,11)-48;
            code(1:lenauxextra)=[];
            aux_extra=[1 aux_extra_bin aux_extra];
        end
        aux_info=[];
%         H(X|Y)
        Z1=Z(r_rev+1:r_rev+64,c_rev+1:c_rev+64);Ienew1=Ienew(r_rev+1:r_rev+64,c_rev+1:c_rev+64);
        %���汥������λ����Ϣ��ע�⣺ÿ��������Ҫ18λ�����棬���۽ϴ�
        for q=1:length(sat_value)
           aux_info=[aux_info dec2bin(sat_value(q),6)-48 dec2bin(sat_r(q),6)-48 dec2bin(sat_c(q),6)-48];
        end
        aux_info=[dec2bin(length(sat_value),10)-48 aux_info];

        for q=1:length(index1)
            [r,c]=find(Ienew1==y(index1(q)));
            %ȥ����SetB������ء��߽������뱥�͵�����
            irmv=1;
            while irmv<=length(r)
                if mod(r(irmv)+c(irmv),2)==1 || r_rev+r(irmv)==1 || r_rev+r(irmv)==512 || c_rev+c(irmv)==1 || c_rev+c(irmv)==512
                    r(irmv)=[];c(irmv)=[];
                    irmv=irmv-1;
                else
                    Issat=0;
                    for isat=1:length(sat_r)
                       if sat_r(isat)==r(irmv) && sat_c(isat)==c(irmv)
                            Issat=1;
                       end
                    end
                    if Issat==1
                        r(irmv)=[];c(irmv)=[];
                        irmv=irmv-1;
                    end
                end
                irmv=irmv+1;
            end
            pseq=ps1(index1(q),1:find(ps1(index1(q),:),1,'last'));
            core=huff(pseq);%����������
            for ir=1:length(r)
               origin=Ie(r_rev+r(ir),c_rev+c(ir));
               len=sum(replace1(index1(q),:)>0);
               serie=find(y(replace1(index1(q),1:len))==origin,1,'first');%��ȡ����+1
               huffcode=core{serie};
               for istore=1:length(huffcode)
                  if  huffcode(istore)=='1'
                      aux_info=[aux_info 1]; 
                  else
                      aux_info=[aux_info 0];
                  end
               end
            end 
        end
        lenaux_bin=dec2bin(length(aux_info),12)-48;
        aux_info=[lenaux_bin aux_info];lenaux=length(aux_info);
        payload=[payload payload_block];
        if ~isempty(aux_extra)
            aux_info=[aux_extra aux_info];lenaux=length(aux_info);
            aux_extra=[];
        end   
end

% %%
% %Set A B���ɴ���
% WeightBin=[];
% for i=1:4
%     WeightBin=[WeightBin dec2bin_zero(seq(i),8)];
% end
% emin=min(min(Ienew));emax=max(max(Ienew));y=emin:emax;
% newPEH=zeros(emax-emin+1,1);
% for i=2:512-1
%         for j=2:512-1
%             if mod((i+j),2)==0
%                 idx=Ienew(i,j)-emin+1;
%                 newPEH(idx)=newPEH(idx)+1;
%             end
%         end
% end
% thresh=round(512*512/4096);i=1;
% while i<=length(newPEH)
%     if newPEH(i)<thresh
%         newPEH(i)=[];y(i)=[];
%     else
%         i=i+1;
%     end
% end
% newPEH=round(newPEH*2048/(512*512));
% DPEH=[];
% for i=1:length(PEH)
%     if newPEH(i)>PEH(i)
%         bin=1;
%     else
%         bin=0;
%     end
%     bin=[bin dec2bin(abs(newPEH(i)-PEH(i)),6)-48];
%     DPEH=[DPEH bin];
% end
%  aux_info=[WeightBin DPEH aux_info];

%%
disp('SetB��ʼǶ����Ϣ');
[PEH,Ie,y,seq]=prediction(I,1);%Ie��prediction error,y������
[T,P2,~]=RevMat(0.125,40000,PEH);


ApproxPayload=P1+P2;

%%
%embedding
%ע�⣺ֻҪ��ת�Ƶĸ��������κ�һ���ᳬ���߽磬������������أ�
futility_block=[];%��Ч�Ŀ����
ZZ=Z;Ienew=Ie;
code=round(rand(1,200000));CODE=code;
[ps,replace,index]=ps_replace(T);%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
[ps1,replace1,index1]=ps_replace(T');%ȷ�����лҶ�ֵ��ת�Ƹ������Ӧ�Ҷ�ֵ
h=waitbar(0,'Encoding...');aux_extra=[];
for block=0:63%��ͼ���зֳ�64*64��64��
      waitbar(block/64,h,['Block:' num2str(block+1)]);r_rev=64*(mod(block,8));c_rev=64*floor(block/8);%���и��ݿ����������
      payload_block=[];sat_value=[];sat_r=[];sat_c=[];
      if block==1%��block1��LSBд���block1��ʼ�Ļָ�������
          LSB=[];
          for lsbBlock=1:1
            lsbj_rev=(lsbBlock-1)*64;
            for lsbi=1:64
                for lsbj=1:64
                    LSB=[LSB mod(Z(lsbi,lsbj+lsbj_rev),2)];
                end
            end
          end
          code=[LSB code];
      end
 
          code=[aux_info code];
          aux_count=aux_count+length(aux_info);

%         H(Y|X)
        ZZ1=Z(r_rev+1:r_rev+64,c_rev+1:c_rev+64);Ie1=Ie(r_rev+1:r_rev+64,c_rev+1:c_rev+64);
        for q=1:length(index)
            [r,c]=find(Ie1==y(index(q)));%Ѱ������ʱ��-1
            %ȥ����SetA��������Լ����͵����أ�������λ����Ϣ
            irmv=1;
            while irmv<=length(r)
                if mod(r(irmv)+c(irmv),2)==0 || r_rev+r(irmv)==1 || r_rev+r(irmv)==512 || c_rev+c(irmv)==1 || c_rev+c(irmv)==512
                    r(irmv)=[];c(irmv)=[];
                    irmv=irmv-1;
                else
                    len=sum(replace(index(q),:)>0);
                    PossibleError=y(replace(index(q),1:len));
                    PossibleValue=Z1(r(irmv),c(irmv))-Ie1(r(irmv),c(irmv))+PossibleError;
                    if ~isempty(find(PossibleValue>255, 1)) && ~isempty(find(PossibleValue<0, 1))
                        sat_value=[sat_value Z1(r(irmv),c(irmv))];sat_r=[sat_r r(irmv)];sat_c=[sat_c c(irmv)];
                        %�Ƿ���Ҫ���Ҷ�ֵ�޸�Ϊ0 or 255��
                        r(irmv)=[];c(irmv)=[];
                        irmv=irmv-1;
                    end
                end
                irmv=irmv+1;
            end
            pseq=ps(index(q),1:find(ps(index(q),:),1,'last'));
            core=huff(pseq);%������������
            corelen=[];
            for icore=1:length(core)
                corelen(icore)=length(core{icore});%������������
            end
            for ir=1:length(r)
               codestring='';
               for iserlen=1:max(corelen)
                  codestring=strcat(codestring,num2str(code(iserlen))); 
                  coreindex=find(corelen==iserlen);watch=0;
                  for ifind=1:length(coreindex)
                     if strcmp(codestring,core{coreindex(ifind)})==1
                         ZZ(r_rev+r(ir),c_rev+c(ir))=ZZ(r_rev+r(ir),c_rev+c(ir))-Ie1(r(ir),c(ir));
                         ZZ(r_rev+r(ir),c_rev+c(ir))=ZZ(r_rev+r(ir),c_rev+c(ir))+y(replace(index(q),coreindex(ifind)));
                         Ienew(r_rev+r(ir),c_rev+c(ir))=y(replace(index(q),coreindex(ifind)));
                         payload_block=[payload_block code(1:iserlen)];
                         code(1:iserlen)=[];watch=1;
                         break; 
                     end
                  end
                  if watch==1
                    break;
                  end
               end
            end
        end
        lenpay=length(payload_block);
        if lenaux>lenpay%���aux�Ƿ񳬳�payload
            futility_block=[futility_block block];
%             ��ÿ�Ƕ����Ϣ��������ԭ����aux��12λ��1,�����˶�block63�Ĵ���
            aux_extra=aux_info(lenpay+1:end);
            lenauxextra=length(aux_extra);
            aux_extra_bin=dec2bin(lenauxextra,11)-48;
            code(1:lenauxextra)=[];
            aux_extra=[1 aux_extra_bin aux_extra];
        end
        aux_info=[];
%         H(X|Y)
        ZZ1=ZZ(r_rev+1:r_rev+64,c_rev+1:c_rev+64);Ienew1=Ienew(r_rev+1:r_rev+64,c_rev+1:c_rev+64);
        %���汥������λ����Ϣ��ע�⣺ÿ��������Ҫ18λ�����棬���۽ϴ�
        for q=1:length(sat_value)
           aux_info=[aux_info dec2bin(sat_value(q),6)-48 dec2bin(sat_r(q),6)-48 dec2bin(sat_c(q),6)-48];
        end
        aux_info=[aux_info dec2bin(length(sat_value),8)-48];
        for q=1:length(index1)
            [r,c]=find(Ienew1==y(index1(q)));
            %ȥ����SetA��������뱥�͵�����
            irmv=1;
            while irmv<=length(r)
                if mod(r(irmv)+c(irmv),2)==0 || r_rev+r(irmv)==1 || r_rev+r(irmv)==512 || c_rev+c(irmv)==1 || c_rev+c(irmv)==512
                    r(irmv)=[];c(irmv)=[];
                    irmv=irmv-1;
                else
                    Issat=0;
                    for isat=1:length(sat_r)
                       if sat_r(isat)==r(irmv) && sat_c(isat)==c(irmv)
                            Issat=1;
                       end
                    end
                    if Issat==1
                        r(irmv)=[];c(irmv)=[];
                        irmv=irmv-1;
                    end
                end
                irmv=irmv+1;
            end
            pseq=ps1(index1(q),1:find(ps1(index1(q),:),1,'last'));
            core=huff(pseq);%����������
            for ir=1:length(r)
               origin=Ie(r_rev+r(ir),c_rev+c(ir));
               len=sum(replace1(index1(q),:)>0);
               serie=find(y(replace1(index1(q),1:len))==origin,1,'first');%��ȡ����+1
               huffcode=core{serie};
               for istore=1:length(huffcode)
                  if  huffcode(istore)=='1'
                      aux_info=[aux_info 1]; 
                  else
                      aux_info=[aux_info 0];
                  end
               end
            end 
        end
        lenaux_bin=dec2bin(length(aux_info),12)-48;
        aux_info=[lenaux_bin aux_info];lenaux=length(aux_info);
        payload=[payload payload_block];
        if ~isempty(aux_extra)
            aux_info=[aux_extra aux_info];lenaux=length(aux_info);
            aux_extra=[];
        end   
end

% %%
% %�滻LSB
% disp('��ʼ��дLSB����...');
% WeightBin=[];
% for i=1:4
%     WeightBin=[WeightBin dec2bin_zero(seq(i),8)];
% end
% emin=min(min(Ienew));emax=max(max(Ienew));y=emin:emax;
% newPEH=zeros(emax-emin+1,1);
% for i=2:512-1
%         for j=2:512-1
%             if mod((i+j),2)==1
%                 idx=Ienew(i,j)-emin+1;
%                 newPEH(idx)=newPEH(idx)+1;
%             end
%         end
% end
% thresh=round(512*512/4096);i=1;
% while i<=length(newPEH)
%     if newPEH(i)<thresh
%         newPEH(i)=[];y(i)=[];
%     else
%         i=i+1;
%     end
% end
% newPEH=round(newPEH*2048/(512*512));
% DPEH=[];
% for i=1:length(PEH)
%     if newPEH(i)>PEH(i)
%         bin=1;
%     else
%         bin=0;
%     end
%     bin=[bin dec2bin(abs(newPEH(i)-PEH(i)),6)-48];
%     DPEH=[DPEH bin];
% end
%  aux_info=[WeightBin DPEH aux_info];
% %%
% z=1;
%     for lsbi=1:64
%                  for lsbj=1:64
%                       ZZ(lsbi,lsbj)=ZZ(lsbi,lsbj)-mod(ZZ(lsbi,lsbj),2)+aux_info(z);
%                       z=z+1;
%                       if z>length(aux_info)
%                         break;
%                       end
%                  end
%                  if z>length(aux_info)
%                       break;
%                  end
%     end
% 
% %%
% if (length(payload)-aux_count)<=0
%     disp('ERROR:Capacity of PEH is not positive!');
%     return;
% end
OriIm=uint8(OriIm);ZZ=uint8(ZZ);
figure;
subplot(1,2,1),imshow(OriIm);
subplot(1,2,2),imshow(ZZ);
OriIm=double(OriIm);ZZ=double(ZZ);
[RCE,REE,RMBE]=similarity(OriIm,ZZ);
[RealSSIM, ~] = ssim(OriIm,ZZ);
[PSNR,~]=psnr(OriIm,ZZ);
ApproxPayload=length(payload)-aux_count;
ZZ=uint8(ZZ);
% imwrite(ZZ,[pathname 'pic\' filename(1:end-4) '_PEE.bmp']);
imwrite(ZZ,'1.bmp');
% disp(['Ƕ����ɣ�Payload=' num2str(length(payload)-aux_count+prepay)]);
% disp(['Ƕ����ɣ�REE:' num2str(REE) ',RMBE:' num2str(RMBE) ',RCE:' num2str(RCE) ',PSNR:' num2str(PSNR) ',SSIM:' num2str(RealSSIM) ',PCQI:' num2str(RealPCQI)]);
% % saveas(gca,'jj.jpg');

end
