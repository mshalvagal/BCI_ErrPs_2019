MCC_ = arrayfun(@(x) mean(x.mcc),models_metrics);
AUC_ = arrayfun(@(x) mean(x.auc),models_metrics);
Accuracy_ = arrayfun(@(x) mean(x.accuracy),models_metrics);
plot(MCC_,'-d')
hold on;
plot(AUC_,'-d');
plot(Accuracy_,'-d');
xticks([1 2 3 4 5 6]);
xticklabels({'LDA','Diag LDA','Diag QDA','SVM','RBF SVM','RF'});
legend('MCC','AUC','Accuracy');
title('Average Performance per Model');
xlabel('Model') ;
ylabel('Performance') ;


%%
best_model = models_metrics(2);
plot([best_model.accuracy],'-d');
hold on;
plot([best_model.mcc],'-d')
plot([best_model.tpr],'-d')
plot([best_model.fpr],'-d')
plot([best_model.auc],'-d')
plot([best_model.fmeasure],'-d')
xticks([1 2 3 4]);
xticklabels({'Subject 1','Subject 2','Subject 3','Subject 4'});
legend('Accuracy','MCC','TPR','FPR','AUC','Fmeasure');
title('Diagonal LDA performance per Subject')
xlabel('Subject')
ylabel('Performance')
%%
overall_mean_metrics.conf_matrix = zeros(2);
    for x = 1:4
       overall_mean_metrics.conf_matrix = overall_mean_metrics.conf_matrix + all_metrics(x).conf_matrix;
    end 
disp(overall_mean_metrics.conf_matrix/4)
%%
varacc = var([best_model.accuracy])
varmcc = var([best_model.mcc])
varauc = var([best_model.auc])