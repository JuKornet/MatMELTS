function [Fraction_data]=EaSpF(str,calctype)
%% General information
% The following function allows the user to use output results per steps instead of per stable phases.
% It also allows the user to have the data in wt% instead of grams, which is the only fraction data MELTs is giving. 

%% Initialization
output_melt=[];Fraction_data=[];numphase=0;
%% The outputs are in grams!! You have to translate them to wt%. To do that you need to extract all the phases to normalise on 100
     
files = dir( fullfile(str,'*.tbl') );   %% List only the .tbl file ==>> stable phases. collect data for normalisation
files = {files.name}';   
[paths,names_out,ext]=fileparts(str);
name_out=sprintf('./%s/output_MELTs_%s_%s.txt',str,names_out,calctype);
phases_file=numel(files); % Number of stable phases stabilizing along the LLD. 
data = cell(phases_file,1); 

%% Compile all the stable phases into one single file ==> make it easier to normalise

for i=1:phases_file % explore all the files
    fname = fullfile(str,files{i});   % Give the actual name of the tbl file of interest
    
    input=fopen(fname,'r');
    data_norm_wt=textscan(input,...
        '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f'...
        ,'Delimiter',',','Headerlines',1);
    fclose(input);
    
    ID=data_norm_wt{1,1} ;
    [paths,names,ext]=fileparts(fname);
    comp=data_norm_wt(7:21); 
    comp=cell2mat(comp);endmembers=data_norm_wt(31:38);endmembers=cell2mat(endmembers);
    T=data_norm_wt{1,2};P=data_norm_wt{1,3};frac=data_norm_wt{1,5}; 

    % Change names of stable phases and add names when appropriate
    for ind=1:size(ID,1)
        names2=0;names3=0;
            if strcmp(names,'melts-liquid')
                names='melt';
                endmembers=zeros(size(endmembers));
            end
            if strcmp(names,'rhm-oxide')
                names='oxide';
            end
            % MELTs gives only a feldspar.tbl output. Here it is decomposed
            % in kfsp and Plagioclase
            if strcmp(names,'feldspar')
                if endmembers(ind,3)>=0.1
                    names2='Kfsp';
                elseif endmembers(ind,3)< 0.1
                    names2='plagioclase';
                end
            end
            % MELTs gives only a clinopyroxene.tbl output. Here it is decomposed
            % in CaTschermarks and Fe3 + cpx (jadeite and others)
            if strcmp(names,'clinopyroxene')
                if endmembers(ind,4)>0.5
                    names2='CaTschermark';
                elseif endmembers(ind,5)+endmembers(ind,6)+endmembers(ind,7)> 0.5
                    names2='Fe3cpx';
                end
            end
        if names2~=0      
            names3=names;
            names=names2;
        end
        output_melt=[output_melt; ID(ind) {names} T(ind) P(ind) frac(ind) 0 comp(ind,:) endmembers(ind,:)];  % Concatenate all stable phases data into one file
        if names3~=0
        names=names3;
        end
    end   
end

%% Sort according to ID and concatenate string for print function

output_melt=cell2table(output_melt);output_melt=sortrows(output_melt,1);    
output_melt.Properties.VariableNames={'ID' 'Stable_phase' 'Temp' 'Press' 'Frac' 'New_Frac' 'Comp' 'End_members'};
names_ph=unique(output_melt.Stable_phase);

%% Pick mass data with same ID for Normalisation ===>>> Different for batch and frac calculation. For Batch, the gms values equals the wt% values
names_f=[];Frac_wt=[];
ID=output_melt.ID;max_val=max(ID); 
F_previous=cell(size(names_ph,1),2);
F=cell(size(names_ph,1),2);   % Parametrization of F variables for normalization (F=fraction)
F(:,1)=names_ph;
F_previous(:,1)=names_ph;F_previous(:,2)={zeros(1,2)};
F(:,2)={zeros(1,2)}; % Reinitialize variable F for each temperature step

for ind2=1:max_val         % Run a loop for the total number of steps ran by MELTs
       indice=ID==ind2;    % Create variabe that correlates the number of steps and the loop
       norm=output_melt(indice,:);  % Sort the output files created above according to the ID and ind2 (indice)

         for ind3=1:size(norm,1)
             if strcmp(calctype,'fractionateSolids') 
               match=ismember(F(:,1),norm.Stable_phase(ind3));
               match2=ismember(F_previous(:,1),norm.Stable_phase(ind3));
               [row_match,col_match]=find(match==1);
               [row_match2,col_match]=find(match2==1);

               F{row_match,2}(1,1)=norm.Frac(ind3);
               
               melt=ismember(norm.Stable_phase,'melt');
               water=ismember(norm.Stable_phase,'water');
               
                    if find(melt(ind3)==1)
                        F{row_match,2}(1,2)=F{row_match,2}(1,1);                       
                    else
                        F{row_match,2}(1,2)=F{row_match,2}(1,1)+F_previous{row_match2,2}(1,2);
                    end
               F_previous=F;

               
               F_new=cell2mat(F(:,2));
                   tot_frac=sum(F_new(:,2),1)-F_new(end,2);
                   normalisation=F_new(1:end-1,2).*100./tot_frac;
                   normalisation(end+1)=F_new(end,2);
                   normalisation(row_match);
                   norm.New_Frac(ind3)= normalisation(row_match);              
               names_f=[names_f; {table2array(norm.Stable_phase(ind3))}];
               Frac_wt=[Frac_wt; norm.New_Frac(ind3)];
               F{ind3,2}(1,1)=0;
             end
             
            if strcmp(calctype,'fractionateNone')            
                names_f=[names_f; {table2array(norm.Stable_phase(ind3))}];
            end
         end          
end

sprintf('This script gives the total amount in wt%% of phases crystallised along the LLD')

%% Print to txt file
output_melt1=table2array(output_melt(:,1));output_melt2=table2array(output_melt(:,3:end));
names_f=string(names_f);
output_melt_f=[output_melt1 output_melt2];output_melt_f(isnan(output_melt_f))=0;
fileID=fopen(name_out,'w');

    fprintf(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n',...
        'ID','Stable_phase','Temp','Press','Frac(wt%)','SiO2','TiO2','Al2O3','Fe2O3','Cr2O3','FeO','MnO','MgO'...
        ,'NiO','CoO','CaO','Na2O','K2O','P2O5','H2O','EM1','EM2','EM3','EM4','EM5','EM6' ,'EM7','EM8');
for ind4=1:size(output_melt_f,1)
    if strcmp(calctype,'fractionateNone')
        fprintf(fileID,'%d %s %d %0.1f %0.2f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n '...
        ,output_melt_f(ind4,1),names_f(ind4), output_melt_f(ind4,2),output_melt_f(ind4,3),output_melt_f(ind4,4),output_melt_f(ind4,6:20),output_melt_f(ind4,21:end));   % collect data in a single file .txt
    end
    if strcmp(calctype,'fractionateSolids') 
    fprintf(fileID,'%d %s %d %0.1f %0.2f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n '...
        ,output_melt_f(ind4,1),names_f(ind4), output_melt_f(ind4,2),output_melt_f(ind4,3),Frac_wt(ind4),output_melt_f(ind4,6:20),output_melt_f(ind4,21:end));   % collect data in a single file .txt
    end
end
 fclose(fileID);

%% OLD STYLE 
            
%             melt=ismember(norm.Stable_phase,'melt');[row_m,col_m]=find(melt==1);          
%             fsp=ismember(norm.Stable_phase,'plagioclase');[row_fsp,col_fsp]=find(fsp==1);
%             Grt=ismember(norm.Stable_phase,'garnet');[row_gt,col_gt]=find(Grt==1);
%             opx=ismember(norm.Stable_phase,'orthopyroxene');[row_opx,col_opx]=find(opx==1);
%             cpx=ismember(norm.Stable_phase,'clinopyroxene');[row_cpx,col_cpx]=find(cpx==1);
%             water=ismember(norm.Stable_phase,'water');[row_wt,col_wt]=find(water==1);
%             biotite=ismember(norm.Stable_phase,'biotite');[row_bt,col_bt]=find(biotite==1);
%             amph=ismember(norm.Stable_phase,'amphibole');[row_amph,col_amph]=find(amph==1);
%             spinel=ismember(norm.Stable_phase,'spinel');[row_sp,col_sp]=find(spinel==1);
%             Qz=ismember(norm.Stable_phase,'quartz');[row_qz,col_qz]=find(Qz==1);
%             oxides=ismember(norm.Stable_phase,'oxide');[row_ox,col_ox]=find(oxides==1);
%             leuc=ismember(norm.Stable_phase,'leucite');[row_leuc,col_leuc]=find(leuc==1);
%             apa=ismember(norm.Stable_phase,'apatite');[row_apa,col_apa]=find(apa==1);
 
 %             if strcmp(calctype,'fractionateSolids')           
%                     if find(fsp(ind3)==1)
%                         a=find(norm.End_members(row_fsp(:),3)<=0.1);
%                         b=find(norm.End_members(row_fsp(:),3)>0.1);
%                         if a==1                    
%                             norm.Stable_phase(row_fsp(a==1))={'Plagioclase'};
%                             F(1)=F(1)+norm.Frac(row_fsp(a==1)); 
%                             norm.New_Frac(row_fsp(a==1))=F_norm.Var1(1);
%                         elseif b==1
%                             norm.Stable_phase(row_fsp(b==1))={'K-fsp'};
%                             F(2)=F(2)+norm.Frac(row_fsp(b==1));
%                             norm.New_Frac(row_fsp(b==1))=F_norm.Var1(2);
%                         end
%                             if F_norm.Var1(1)==0                
%                                 norm.New_Frac(row_fsp(a==1))=norm.Frac(row_fsp(a==1));
%                             end
%                             if F_norm.Var1(2)==0                
%                                 norm.New_Frac(row_fsp(b==1))=norm.Frac(row_fsp(b==1));
%                             end
%                     end
%                     if find(Grt(ind3)==1)
%                         F(3)=F(3)+norm.Frac(row_gt);
%                         norm.New_Frac(row_gt)=F_norm.Var1(3);
%                         if F_norm.Var1(3)==0                
%                             norm.New_Frac(row_gt)=norm.Frac(row_gt);
%                         end
%                     end
%                     if find(opx(ind3)==1)
%                         F(4)=F(4)+norm.Frac(row_opx);           
%                         norm.New_Frac(row_opx)=F_norm.Var1(4);
%                         if F_norm.Var1(4)==0                
%                             norm.New_Frac(row_opx)=norm.Frac(row_opx);
%                         end
%                     end
%                     if find(cpx(ind3)==1)
%                         if size(norm.New_Frac(row_cpx),1)>1
%                             
%                         end
%                         F(5)=F(5)+norm.Frac(row_cpx);
%                         norm.New_Frac(row_cpx)=F_norm.Var1(5);
%                         if F_norm.Var1(5)==0                
%                             norm.New_Frac(row_cpx)=norm.Frac(row_cpx);
%                         end
%                     end
%                     if find(water(ind3)==1)
%                         F(13)=F(13)+norm.Frac(row_wt);
%                         norm.New_Frac(row_wt)=F_norm.Var1(13);
%                         if F_norm.Var1(13)==0                
%                             norm.New_Frac(row_wt)=norm.Frac(row_wt);
%                         end
%                     end
%                     if find(biotite(ind3)==1)
%                         F(6)=F(6)+norm.Frac(row_bt);
%                         norm.New_Frac(row_bt)=F_norm.Var1(6);
%                         if F_norm.Var1(6)==0                
%                             norm.New_Frac(row_bt)=norm.Frac(row_bt);
%                         end
%                     end
%                     if find(amph(ind3)==1)
%                         F(7)=F(7)+norm.Frac(row_amph);
%                         norm.New_Frac(row_amph)=F_norm.Var1(7);
%                         if F_norm.Var1(7)==0                
%                             norm.New_Frac(row_amph)=norm.Frac(row_amph);
%                         end
%                     end
%                     if find(spinel(ind3)==1)
%                         F(8)=F(8)+norm.Frac(row_sp);
%                         norm.New_Frac(row_sp)=F_norm.Var1(8);
%                         if F_norm.Var1(8)==0                
%                             norm.New_Frac(row_sp)=norm.Frac(row_sp);
%                         end
%                     end
%                     if find(Qz(ind3)==1)
%                         F(9)=F(9)+norm.Frac(row_qz);
%                         norm.New_Frac(row_qz)=F_norm.Var1(9);
%                         if F_norm.Var1(9)==0                
%                             norm.New_Frac(row_qz)=norm.Frac(row_qz);
%                         end
%                     end
%                     if find(oxides(ind3)==1)
%                         F(10)=F(10)+norm.Frac(row_ox);
%                         norm.New_Frac(row_ox)=F_norm.Var1(10);
%                         if F_norm.Var1(10)==0                
%                             norm.New_Frac(row_ox)=norm.Frac(row_ox);
%                         end
%                     end
%                     if find(melt(ind3)==1)
%                         F(14)=norm.Frac(row_m);
%                         norm.New_Frac(row_m)=F_norm.Var1(14);
%                         if F_norm.Var1(14)==0                
%                             norm.New_Frac(row_m)=norm.Frac(row_m);
%                         end
%                     end
%                     if find(leuc(ind3)==1)
%                         F(11)=F(11)+norm.Frac(row_leuc);
%                         norm.New_Frac(row_leuc)=F_norm.Var1(11);
%                         if F_norm.Var1(11)==0                
%                             norm.New_Frac(row_leuc)=norm.Frac(row_leuc);
%                         end
%                     end
%                     if find(apa(ind3)==1)
%                         F(12)=F(12)+norm.Frac(row_apa);
%                         norm.New_Frac(row_apa)=F_norm.Var1(12);
%                         if F_norm.Var1(12)==0                
%                             norm.New_Frac(row_apa)=norm.Frac(row_apa);
%                         end
                  
%                     names_f=[names_f; {table2array(norm.Stable_phase(ind3))}];
%             end
 
 
 
% 
% %% Extract data feldspar
% name_input=sprintf('%s/feldspar.tbl',str);
% name_input2=sprintf('%s/quartz.tbl',str);
% if exist(name_input)
% input=fopen(name_input,'r');
% pl_data=textscan(input,...
%     '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Delimiter',',','Headerlines',1);
% fclose(input);
% An=pl_data{1,32}.*100; Ab=pl_data{1,31}.*100; Or=pl_data{1,33}.*100; T_pl=pl_data{1,2};
% F_pl=pl_data{1,5};
% %% Extract data Melt
% name_input1=sprintf('%s/melts-liquid.tbl',str);
% input1=fopen(name_input1,'r');clear input
% melt_data=textscan(input1,...
%     '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Delimiter',',','Headerlines',1);
% fclose(input1);clear input1
% T_melt= melt_data{1,2};F_melt=melt_data{1,5};
% 
%     if exist(name_input2)
%         %% Extract data Quartz
%         input2=fopen(name_input2,'r');clear input
%         qz_data=textscan(input2,...
%             '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Delimiter',',','Headerlines',1);
%         fclose(input2);clear input1
%         T_qz= qz_data{1,2};F_qz=qz_data{1,5};
%     else 
%         T_qz=NaN;F_qz=NaN;
%     end
%     
% %% Extarct necessary data
% 
% % First= sort K-fsp and Pl-fsp
% a=logical(An<=5);
% K_fsp=[An(a==1) Ab(a==1) Or(a==1) ];
% T_ksp= T_pl(a==1);
% F_ksp = F_pl(a==1);
% An_pl=An;Ab_pl=Ab;Or_pl=Or;
% An_pl(a==1)=[];Ab_pl(a==1)=[];Or_pl(a==1)=[];T_pl(a==1)=[];F_pl(a==1)=[];
% 
% % Second: sort matrix when size of Temperature matrices
% % are not consistent                             
% T_melt(1)=[];F_melt(1)=[]; % First line of melt data is for the "find liquidus" function of melt
% % maxLength = max([length(T_melt), length(T_pl), length(F_melt), length(An_pl),length(F_pl)]);
% maxLength = max([length(T_melt), length(T_pl), length(T_ksp), length(T_qz), length(F_melt), length(F_qz),length(F_pl)],length(F_ksp));
% T_melt(length(T_melt)+1:maxLength) = NaN;% Make vector the same lengths
% T_pl(length(T_pl)+1:maxLength) = NaN;
% T_ksp(length(T_ksp)+1:maxLength) = NaN;
% T_qz(length(T_qz)+1:maxLength) = NaN;
% F_melt(length(F_melt)+1:maxLength) = NaN;
% F_ksp(length(F_ksp)+1:maxLength) = NaN;
% F_qz(length(F_qz)+1:maxLength) = NaN;
% F_pl(length(F_pl)+1:maxLength) = NaN;
% 
% [ia]=setdiff(T_melt,T_pl);F_pl=circshift(F_pl,size(ia,1)); % Make the different vector consistent with the Melt_Temp vector
% [ia]=setdiff(T_melt,T_ksp);F_ksp=circshift(F_ksp,size(ia,1));
% [ia]=setdiff(T_melt,T_qz);F_qz=circshift(F_qz,size(ia,1));
% 
% % Third: Exclude from statistics subsolidus
% % crystals if any 
% 
% for n=1:size(T_melt,1)
% if F_melt(n)<2
%     F_qz(n)=NaN;
%     F_ksp(n)=NaN;
%     F_pl(n)=NaN;
% end
% end
% 
% Fraction_data=[F_melt F_pl F_ksp F_qz];
% end