[X_train, y_train] = preprocess_eeg('data/a7_20191103', true, false);

%[X_test, y_test] = preprocess_eeg('data/a7_20191103', false);

X_train = reshape(X_train, size(X_train,1),[]);
%%
cp = cvpartition(y_train,'KFold',10);
scores = [];
for i = 1: 10 
   Mdl = fitcdiscr(X_train(cp.training(i), :), y_train(cp.training(i),:));
   preds = Mdl.predict(X_train(cp.test(i), :));
   scores = [scores, mean(y_train(cp.test(i), :) == preds)];
   disp(confusionmat(y_train(cp.test(i), :),preds));
end 