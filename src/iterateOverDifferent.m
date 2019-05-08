temp = [true, false];
eogcorr = [true,false];
pca = [true,false];
model={'LDA'};
spatial = ["none","spatial","cca"];

for i=1:length(temp)
    for k=1:length(eogcorr)
        for l=1:length(pca)
            for m=1:length(model)
                for n=1:length(spatial)
                    fprintf("---------------------------------------------\n")
                    if strcmp(spatial(n),"none")
                        fprintf(strcat("EOG Correction: ", string(eogcorr(k)),...
                            "\nTemporal Filtering: ", string(temp(i)),...
                            "\nSpatial: ", string(false),...
                            "\nModel: ", string(model(m)),...
                            "\nCCA: ", string(false),...
                            "\nPCA: ", string(pca(l)),"\n"))
                        mean_metrics=tryDifferent(eogcorr(k),...
                            temp(i),false,model(m),false,pca(l))
                    elseif strcmp(spatial(n),"spatial")
                        fprintf(strcat("EOG Correction: ", string(eogcorr(k)),...
                            "\nTemporal Filtering: ", string(temp(i)),...
                            "\nSpatial: ", string(true),...
                            "\nModel: ", string(model(m)),...
                            "\nCCA: ", string(false),...
                            "\nPCA: ", string(pca(l)),"\n"))
                        mean_metrics=tryDifferent(eogcorr(k),...
                            temp(i),true,model(m),false,pca(l))
                    elseif strcmp(spatial(n),"cca")
                        fprintf(strcat("EOG Correction: ", string(eogcorr(k)),...
                            "\nTemporal Filtering: ", string(temp(i)),...
                            "\nSpatial: ", string(false),...
                            "\nModel: ", string(model(m)),...
                            "\nCCA: ", string(true),...
                            "\nPCA: ", string(pca(l)),"\n"))
                        mean_metrics=tryDifferent(eogcorr(k),...
                            temp(i),false,model(m),true,pca(l))
                    end
                    fprintf("---------------------------------------------\n")
                end
            end
        end
    end
end