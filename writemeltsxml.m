%% writemelts.m ===>>> Function to write .xml file for FRACTIONATION calculation. // Do not take into account assimilant calculation and suppression of solid solution

function writemeltsxml(ttle,Inputs,Param,ind,folder)

name=cell2mat(Inputs{1,1}(ind)); name2=sprintf('%s/%s.xml',folder,name);
fO2=cell2mat(Inputs{1,21}(1));

fileID=fopen(name2,'w');
fprintf(fileID,'<?xml version="1.0" encoding="UTF-8"?> \n');
fprintf(fileID,'<MELTSinput> \n');
fprintf(fileID,'	<initialize> \n');
% fprintf(fileID,'         <modelSelection>rhyolite-MELTS_v1.2.x</modelSelection> \n');
fprintf(fileID,'         <modelSelection>MELTS_v1.2.x</modelSelection> \n');
fprintf(fileID,'                <SiO2>%0.2f</SiO2> \n',Inputs{1,2}(ind));
fprintf(fileID,'                <TiO2>%0.2f</TiO2> \n',Inputs{1,3}(ind));
fprintf(fileID,'                <Al2O3>%0.2f</Al2O3> \n',Inputs{1,4}(ind));
fprintf(fileID,'                <Fe2O3>%0.2f</Fe2O3> \n',Inputs{1,5}(ind));
fprintf(fileID,'                <Cr2O3>%0.2f</Cr2O3> \n',Inputs{1,6}(ind));
fprintf(fileID,'                <FeO>%0.2f</FeO> \n',Inputs{1,7}(ind));
fprintf(fileID,'                <MnO>%0.2f</MnO>\n',Inputs{1,8}(ind));
fprintf(fileID,'                <MgO>%0.2f</MgO> \n',Inputs{1,9}(ind));
fprintf(fileID,'                <NiO>%0.2f</NiO> \n',Inputs{1,10}(ind));
fprintf(fileID,'                <CoO>%0.2f</CoO> \n',Inputs{1,11}(ind));
fprintf(fileID,'                <CaO>%0.2f</CaO>\n',Inputs{1,12}(ind));
fprintf(fileID,'                <Na2O>%0.2f</Na2O> \n',Inputs{1,13}(ind));
fprintf(fileID,'                <K2O>%0.2f</K2O> \n',Inputs{1,14}(ind));
fprintf(fileID,'                <P2O5>%0.2f</P2O5> \n',Inputs{1,15}(ind));
fprintf(fileID,'                <H2O>%0.2f</H2O> \n',Inputs{1,16}(ind));
fprintf(fileID,'                <CO2>%0.2f</CO2>  \n',Inputs{1,17}(ind));
fprintf(fileID,'	</initialize> \n');	
fprintf(fileID,'	<calculationMode>%s</calculationMode> \n',Param{1,6});
fprintf(fileID,'	<title>%s_%s</title> \n',name,ttle);	
fprintf(fileID,'	<sessionID>%s_%s</sessionID> \n',name,ttle);	
fprintf(fileID,'	<constraints> \n');	
fprintf(fileID,'         <setTP> \n');
fprintf(fileID,'                <initialT>%0.2f</initialT> \n',Param{1,1}(1,1));
fprintf(fileID,'                <finalT>%0.2f</finalT> \n',Param{1,1}(1,2));
fprintf(fileID,'                <incT>%0.2f</incT> \n',Param{1,3});
fprintf(fileID,'                <initialP>%0.2f</initialP> \n',Param{1,2}(1,1));
fprintf(fileID,'                <finalP>%0.2f</finalP> \n',Param{1,2}(1,2));
fprintf(fileID,'                <incP>%0.2f</incP> \n',Param{1,4});
fprintf(fileID,'                <dpdt>%0.2f</dpdt> \n',Param{1,5});
fprintf(fileID,'                <fo2Path>%s</fo2Path> \n',fO2);
fprintf(fileID,'                <fo2Offset>%0.2f</fo2Offset> \n',Inputs{1,22}(ind));
fprintf(fileID,'         </setTP> \n');
fprintf(fileID,'	</constraints> \n');	
fprintf(fileID,'	<fractionationMode>%s</fractionationMode> \n',Param{1,7});	
fprintf(fileID,'</MELTSinput> \n');
fclose(fileID);


