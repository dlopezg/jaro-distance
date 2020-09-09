clear
clc

% Path definition:
load_directory = 'data_in/';
save_directory = 'analyses_results/';

% Select data from input folder:
n_files = dir([load_directory '*.xlsx']);

tic
for file = 1 : length(n_files)
    
    % Load current file:
    [~,data,~]=xlsread([n_files(file).folder '/' n_files(file).name]);
    [filepath,name,ext] = fileparts([n_files(file).folder '/' n_files(file).name]);
    
    [n_row,n_column] = size (data);
    pos_combinations = nchoosek((1:n_column), 2);
    [n_combinations,~] = size(pos_combinations);
    
    res_matrix = zeros(n_row+2,n_combinations+1);
    n_real_combinations = zeros(n_row,1);
    row_names = cell(1,n_row+2);
    row_names{end-1} = 'Mean:';
    row_names{end} = 'STD:';
    var_names = cell(1,n_combinations+1);
    var_names{1} = 'Disimilarity';
    
    for i = 1 : n_row
        row = data(i,:);
        row_names{i} = ['ELEMENT_' int2str(i)]; 
        for j = 1 : n_combinations
            str_1 = row{pos_combinations(j,1)};
            str_2 = row{pos_combinations(j,2)};
            
            if isempty(str_1) || isempty(str_2)
                res_matrix(i,j+1) = NaN;
            else
                [jd, matches, transpositions, di] = jaro_distance(str_1,str_2);
                n_real_combinations(i) = n_real_combinations(i) + 1;
                res_matrix(i,j+1) = round(di,3);
            end
            
            label = ['C' int2str(pos_combinations(j,1)) '_' 'C' int2str(pos_combinations(j,2))];
            var_names{j+1} = label;
            
        end
        res_matrix(i,1) = round(nansum(res_matrix(i,2:end))/n_real_combinations(i),3);
    end
    
    % Formating output data:
    res_matrix(end-1:end,:) = NaN;
    res_matrix(end-1,1) = round(mean(res_matrix(1:end-2,1)),3);
    res_matrix(end,1) = round(std(res_matrix(1:end-2,1)),3);
    
    % Convert to table format and delete NaN:
    celldata = num2cell(res_matrix);
    [n_row,n_column] = size (celldata);
    
    for i = 1 : n_row
        for j = 1 : n_column
            if isnan(celldata{i,j})
                if i <= n_row -2
                    celldata{i,j} = '-';
                else
                    celldata{i,j} = ' ';
                end
            else
                % Transform to text and replace . per ,
                celldata{i,j} = num2str(celldata{i,j});
                idx = find(celldata{i,j} == '.');
                celldata{i,j}(idx) = ',';
            end
        end
    end
    
    table = cell2table(celldata, 'RowNames', row_names ,'VariableNames', var_names);
    
    
    
    % Save analysis results:
    writetable(table,[save_directory name '.csv'],'WriteRowNames',true,'Delimiter',';')
  %  dlmwrite([save_directory name '.csv'],res_matrix,'delimiter',';');
    
    % Display total process:
    clc
    fprintf('\n');
    fprintf('COMPUTING JARO DISTANCE');
    fprintf('\n');
    fprintf('-----------------------');
    fprintf('\n');
    fprintf(['Files completed: ' int2str(file) '/' int2str(length(n_files))]);
    fprintf('\n');
 
end
toc
fprintf('\n');
fprintf('<strong>Done!</strong>')





