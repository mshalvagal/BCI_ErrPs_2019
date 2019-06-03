function [ x ] = chanselect(do_select)
%USelects the channel 
% eight fronto-central channels (Fz, FC1, FCz, FC2, C1, Cz, C2, and CPz)
if (do_select)
    x = [1 3 4 5 8 9 10 14]
else 
    x = [1:16]
end

