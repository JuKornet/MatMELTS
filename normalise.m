function [Normalised,newname]=normalise(original,ox,ind,ind2) %ind=j,ind2=l

name=original{1,1}(ind);
oxides= original(1,2:20);
Normalised=zeros(1,19);
for x=1:size(oxides,2)
    Normalised(1,x)=oxides{1,x}(ind)-(oxides{1,x}(ind).*ox(ind2)./100);  
end
Normalised(1,15)=ox(ind2)-(ox(ind2).*ox(ind2)./100);
newname=sprintf('%s-%d%%h2o',cell2mat(name),ox(ind2));

