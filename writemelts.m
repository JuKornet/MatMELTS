%% writemelts.m ===>>> Function to write .melts file for equilibrium calculation in MELTs

function writemelts(ttle,comp,Param,ind,folder)

name=cell2mat(comp{1,1}(ind)); name2=sprintf('%s/%s.melts',folder,name);
fO2=cell2mat(comp{1,21}(ind));

fileID=fopen(name2,'w');
a=fprintf(fileID,'Title: %s_%s \n',name,ttle);
b=fprintf(fileID,'Initial Composition: SiO2 %f \n',comp{1,2}(ind));
c=fprintf(fileID,'Initial Composition: TiO2 %f \n',comp{1,3}(ind));
d=fprintf(fileID,'Initial Composition: Al2O3 %f \n',comp{1,4}(ind));
e=fprintf(fileID,'Initial Composition: Fe2O3 %f \n',comp{1,5}(ind));
f=fprintf(fileID,'Initial Composition: Cr2O3 %f \n',comp{1,6}(ind));
g=fprintf(fileID,'Initial Composition: FeO %f \n',comp{1,7}(ind));
h=fprintf(fileID,'Initial Composition: MnO %f \n',comp{1,8}(ind));
i=fprintf(fileID,'Initial Composition: MgO %f \n',comp{1,9}(ind));
j=fprintf(fileID,'Initial Composition: NiO %f \n',comp{1,10}(ind));
k=fprintf(fileID,'Initial Composition: CoO %f \n',comp{1,11}(ind));
l=fprintf(fileID,'Initial Composition: CaO %f \n',comp{1,12}(ind));
m=fprintf(fileID,'Initial Composition: Na2O %f \n',comp{1,13}(ind));
n=fprintf(fileID,'Initial Composition: K2O %f \n',comp{1,14}(ind));
o=fprintf(fileID,'Initial Composition: P2O5 %f \n',comp{1,15}(ind));
p=fprintf(fileID,'Initial Composition: H2O %f \n',comp{1,16}(ind));
q=fprintf(fileID,'Initial Composition: CO2 %f \n',comp{1,17}(ind));
r=fprintf(fileID,'Initial Composition: SO3 %f \n',comp{1,18}(ind));
s=fprintf(fileID,'Initial Composition: Cl2O-1 %f \n',comp{1,19}(ind));
t=fprintf(fileID,'Initial Composition: F2O-1 %f \n',comp{1,20}(ind));
u=fprintf(fileID,'Initial Temperature: %f \n',Param{1,1}(1,1));
v=fprintf(fileID,'Final Temperature: %f \n',Param{1,1}(1,2));
w=fprintf(fileID,'Initial Pressure: %f \n',Param{1,2}(1,1));
x=fprintf(fileID,'Final Pressure: %f \n',Param{1,2}(1,2));
y=fprintf(fileID,'Increment Temperature: %f \n',Param{1,3});
z=fprintf(fileID,'Increment Pressure: %f \n',Param{1,4});
aa=fprintf(fileID,'dp/dt: %f \n',Param{1,5});
bb=fprintf(fileID,'log fo2 Path: %s \n',fO2);
% cc=fprintf(fileID,'Mode: %s',Param{1,7});
fclose(fileID);



 








 
