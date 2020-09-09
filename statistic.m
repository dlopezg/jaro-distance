clear
clc

% Path definition:
load_directory = 'stat_in/';
filename = 'esp_ing_intercomite.xlsx';

% Load current file:
data = xlsread([load_directory filename]);

% Extract conditions:
cond_a = data(:,1);
cond_b = data(:,2);

% Variables distribution (should be normal distributed):
figure
histogram(cond_a,(0:.05:1))
hold on
histogram(cond_b,(0:.05:1))

% T-test:
[h, pvalues] = ttest2(cond_a,cond_b);

%% Output:

disp(['Two sample t-test for: ' filename])
disp('---------------------------------------------')
disp(['p = ' num2str(pvalues)])
disp(['Mean condition 1  = ' num2str(nanmean(cond_a))])
disp(['Std 1  = ' num2str(nanstd(cond_a))])
disp(['Mean condition 2  = ' num2str(nanmean(cond_b))])
disp(['Std 2  = ' num2str(nanstd(cond_b))])



