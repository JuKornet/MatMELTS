clear all; close all; clc

%% Melts-batch launcher written by J.Cornet 28/11/17 updated 30/06/2020

    % This script allows to read an input file containing bulk rock
    % composition and to compute them directly using Melts-batch. MELTs
    % is used to obtain thermodynamic data, composition and fraction 
    % of stable phases along the Liquid Line of Descent (LLD). 
    
    % A list of Parameters is required to pursue the calclulation such as T
    % and P range; T and P Resolution. These parameters do
    % not change from the usual GUI of Rhyolites-Melts. 
    
%% IMPORTANT NOTE FOR INPUT FILES
 
    % the input file must be a .csv format with space delimiter 
    % This is the most common source of error. 
    % Input files must gather sample name, composition, fugacity and fugacity
    % offset. An example is shown in test-file.csv test_file2.csv
    
%% IMPORTANT NOTE FOR MELTs FAILS 

    % If MELTs falls in an infinite loop: kill the program in the command
    % window using ctrl C. 
  
%% List of variables =====> Change your variable here  

Param=[];                                                                                              % Initialization of variable Param... do not change!
T= [1250 700];                                                                                         % Range of T and P you want to explore
P= [2000 2000]; 
Tres=1;                                                                                                % Resolution of temperature and pressure is an increment: 1 is usually good, 0 is for only one parameter T or P to vary.  
Pres=0;
dTdP=0;                                                                                                % if you need to input a gradiant dP/dT
CalcMode='equilibrate';                                                                                % Calcmode: findLiquidus, equilibrate, findLiquidusWet
% Diff='fractionateNone';
% Diff='fractionateSolids';                                                                            % Differentiation Mode: fractionate solids, fractionate liquids, fractionate fluids, Spec, fractionate none
Diff='Spec';                                                                                          % IMPORTANT NOTE: If you use Spec, program will make Batch AND Fractional calculation ===>>>  

Cryst=[40 50 60];                                                                                      % it is useful if you want to explore the effect of changing regime on the same starting composition at a specified Crystallinity (Cryst)
%% Input your water content here
H2O=[2 4 5 6];                                                                                      % ====>>> comment if you don't want to input water content
%% COMPUTING

delete('*.tbl')                                                                                         % Delete the MELTs pre existing output files if the previous calculation failed
Param=[Param; T P Tres Pres dTdP {CalcMode} {Diff}];                                                    % Concatenate Input parameters to fill .melts file
B=pwd;                                                                                                  % Get path of the current folder and List Files and Folders within the current folder
C=struct2cell(dir(sprintf('*.csv')));                                                                   % Read the csv file in current folder
k=1;

for i=1:size(C,2)
    % Find path name and create adequate folder names
    input=fopen(C{1,i});
    [a,b,c]=fileparts(which(C{1,i}));                                                                    % get name to create folder
    comp=textscan(input,'%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%f','Headerlines',1);
    fclose(input); 
      if exist('H2O')==1 
          comp2=[];newnames=[];compf=[];
        for j=1:size(comp{1,1},1)
            % Normalise the composition according to water content input
                for l=1:size(H2O,2)
                    [comp1(l,:),newname]=normalise(comp,H2O,j,l);
                    newnames=[newnames; {newname}];        
                end
                comp2=[comp2; comp1];                
        end
        % Prepare real compositions and inputs for input MELTs files
          comp3=mat2cell(comp2,size(comp2,1),ones(1,size(comp2,2)));
          fO2offset=comp{1,22}(1).*ones(1,size(comp3{1,1},1)).';
          fO2=comp{1,21};
          compf=[compf; {newnames} comp3 {fO2} fO2offset];
      end
      comp=compf;
      
    % folder names depending on calculation type
    if strcmp(Diff,'fractionateNone') ==1
    b=sprintf('%s_batch',b);
    end
    if strcmp(Diff,'Spec')==1
    b=sprintf('%s_Spec',b);
    end
    if strcmp(Diff,'fractionateSolids') ==1 
    b=sprintf('%s_frac',b);
    end
    for j=1:size(comp{1,1},1)
            namefolder=sprintf('./%s/%s',b,cell2mat(comp{1,1}(j)));
            
            % Call Matlab MELTs function, see below
            ini_MELTs(Diff,comp,j,namefolder,b,Param,k,Cryst);
            
    end
  clear comp  % Clear comp in matlab workspace for next calclulation
end



%% Functions

%% ini_MELTs launch the program xMELTs in the LINUX environment ====>>>> FOR MAC YOU NEED TO COMPILE MELTs WITH THE MAKEFILE.MAC. IT WON T WORK OTHERWISE
function ini_MELTs(Frac,comp,ind,namefolder,folder,Param,ind2,Cryst)
mkdir(folder)                                                                             % create folder for each spreadsheet
mkdir(namefolder)                                                                         % create subfolder for each samples

% If Differentiation Mode = Batch
if strcmp(Frac,'fractionateNone') ==1
writemeltsxml(folder,comp,Param,ind,namefolder)                                           % Create .melts files see file writemeltsxml.m
% Run Melts-batch *.xml
command2=sprintf('./Melts-batch %s/%s.xml',namefolder,cell2mat(comp{1,1}(ind)));          % write the final command to run in the Linux Bash environment as specified by the xMELTs tutorial: ./Melts-batch *.xml               
cmd2=unix(command2);                                                                      % Launch command
movefiles(ind2,namefolder);
EaSpF(namefolder,Frac);                                                                   % Extract and Sort see EaSpF.m file
end

% If Differentiation Mode = Spec
if strcmp(Frac,'Spec')==1
    strb=sprintf('%s/%s',namefolder,'batch');mkdir(strb)
    Param{1,7}='fractionateNone';writemeltsxml(namefolder,comp,Param,ind,strb);
    command2=sprintf('./Melts-batch %s/%s.xml',strb,cell2mat(comp{1,1}(ind)));cmd2=unix(command2);
    movefiles(ind2,strb);
    EaSpF(strb,'fractionateNone')
    for n=1:size(Cryst,2)
     compr=[];
     namefolder2=sprintf('%s_%d%%Crys',namefolder,Cryst(1,n));
     strf=sprintf('%s/%s_%d',namefolder,'frac',Cryst(n));   % Create subfolder for each Crystallinity rate you want to explore
     strc=sprintf('%s/%s_%d',namefolder,'Compiled',Cryst(n));mkdir(strf);mkdir(strc);
     [T_melt,Melt_extract]=ExtractMeltCryst(strb,Cryst(n));

     compr= [compr; {comp{1,1}(ind)} Melt_extract {comp{21}(1)} comp{22}(1)];
     
     Param{1,7}='fractionateSolids';Param{1,1}(1,1)=T_melt;writemeltsxml(namefolder,compr,Param,1,strf);
     % Run Melts-batch *.xml
     command2=sprintf('./Melts-batch %s/%s.xml',strf,cell2mat(comp{1,1}(ind)));
     cmd2=unix(command2);
     
     
     movefiles(ind2,strf);
     EaSpF(strf,'fractionateSolids')
     concatenation(strb,strf,strc,Cryst(n),T_melt)
    end
n=0;
end

% If Differentiation Mode = Fractionate Solids
if strcmp(Frac,'fractionateSolids') ==1                                                    % mkdir(namefolder);mkdir(namefolder_Pro);
writemeltsxml(folder,comp,Param,ind,namefolder)                                            % Create .xml files see function writemeltsxml.m               
 % Run Melts-batch *.xml
str1=sprintf('%s/%s.xml',namefolder,cell2mat(comp{1,1}(ind))); 
% Run Melts-batch *.xml    
command2=sprintf('./Melts-batch %s',str1);                                                 % write the final command to run in the Linux Bash environment as specified by the xMELTs tutorial: ./Melts-batch ./InputDir ./OutputDir ./PrcessedDir
cmd2=unix(command2);             

movefiles(ind2,namefolder);
EaSpF(namefolder,Frac);
end
ind2=1;
end

%% Create output files 
function concatenation(str1,str2,str3,Cryst,T)
 
file1=sprintf('%s/output_MELTs_batch_fractionateNone.txt',str1);
file2=sprintf('%s/output_MELTs_frac_%d_fractionateSolids.txt',str2,Cryst);
data1=fopen(file1,'r');
batch=textscan(data1,'%d %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Headerlines',1);
fclose(data1);
data2=fopen(file2,'r');
fractional=textscan(data2,'%d %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Headerlines',1);
fclose(data2);

melt=ismember(batch{1,2}(:),'melt');[row_m,col_m]=find(melt==1);

[row_conc,col_conc]=find(batch{1,3}(:)== T-1);
bitch=batch{1,1}(1:row_conc-1);
butch=cell2mat(batch(1,3:end));
butch=butch(1:row_conc-1,:);
names=batch{1,2}(1:row_conc-1);
% batch_data=[bitch {names} butch];
[row_frac,col_frac]=find(fractional{1,3}(:)==T-1);
fric=fractional{1,1}(row_frac:end);fruc=cell2mat(fractional(1,3:end));fruc=fruc(row_frac:end,:);
names2=fractional{1,2}(row_frac:end);
comp=padconcatenation(butch,fruc,1);
names=[names; names2];
ID=padconcatenation(bitch,fric+max(bitch)-1,1);
names=string(names);
file_comp=sprintf('output_MELTs_Comp_%d.txt',Cryst);
fileID=fopen(file_comp,'w');
fprintf(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n',...
        'ID','Stable_phase','Temp','Press','Frac(wt%)','SiO2','TiO2','Al2O3','Fe2O3','Cr2O3','FeO','MnO','MgO'...                   % EM1,..., EM8: end members composition of the phase of interest: Follow the same order as usual MELTs output files
        ,'NiO','CoO','CaO','Na2O','K2O','P2O5','H2O','EM1','EM2','EM3','EM4','EM5','EM6' ,'EM7','EM8');                             % Example: if plagioclase is the phase of interest: EM1 = Albite (mol)   EM2 = Anorthite (mol) EM3 = Sanidine (mol), EM4 to EM8 = 0                           
    for i=1:size(ID,1)
fprintf(fileID,'%d %s %d %0.1f %0.2f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n '...
        ,ID(i),names(i),comp(i,:));
    end
    fclose(fileID);

movefile(file_comp,str3);                                                                                                           % movefile to respective folders

 end

%% Extract Crystallinity of the system for Differentiation mode = Spec

function [Temp,data_melt]=ExtractMeltCryst(str,Cryst)
% Extract data Melt
name_input1=sprintf('%s/melts-liquid.tbl',str);
input1=fopen(name_input1,'r');clear input
melt_data=textscan(input1...
    ,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f'...
    ,'Delimiter',',','Headerlines',1);
fclose(input1);clear input1
F_melt=melt_data{1,5};
% Index=find(F_melt <Cryst+0.5 & F_melt>Cryst-0.5);
Cryst=100-Cryst;
for n=0.5:0.5:5
    Index=find(F_melt <Cryst+n & F_melt>Cryst-n);
    if isempty(Index)==0
        break
    else
       sprintf('EXTRACTMELTCRYST: The amount of crystals you are looking for does not exist: \n Pursuing with NewCryst= Cryst +- 5 to 10') 
       for m=5:0.5:10
           Index=find(F_melt <Cryst+m & F_melt>Cryst-m);
               if isempty(Index)==0
                   break
               end
       end
   end
end

data_melt=cell2mat(melt_data); Temp=data_melt(Index(1),2);
data_melt=data_melt(Index(1),7:25);
data_melt=mat2cell(data_melt,size(data_melt,1),ones(1,size(data_melt,2)));
end

function movefiles(ind2,folder)
names=dir(sprintf('*.tbl'));names2=dir(sprintf('*.out'));
 while ind2<=numel(names)
        Sourcepath=fullfile(pwd,names(ind2).name); destpath=fullfile(pwd,folder);      % Next 2 lines:
        Move=movefile(Sourcepath,destpath);                                                % Move *.tbl and *.out files in respective target folders
        ind2=ind2+1; 
 end
Sourcepath2=fullfile(pwd,names2.name); 
Move2=movefile(Sourcepath2,destpath);
ind2=1;
end