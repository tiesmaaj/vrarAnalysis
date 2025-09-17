clear; close all; clc;

% Define the filenames for your data (adjust these based on actual file names)
save_name = '1_2_f_22';  % Example name, modify as needed
fileVis = sprintf('vrarVis_%s.csv', save_name);
fileAud = sprintf('VrarAUD_%s.csv', save_name);
fileAV = sprintf('vrarAV_%s.csv', save_name);

% Initialize matrices to store data
dataVis = [];
dataAud = [];
dataAV = [];

% Load the data for Visual, Auditory, and Audiovisual if the files exist
if isfile(fileVis)
    % Load the visual data
    dataTableVis = readtable(fileVis);
    
    % Remove columns 3 and 4 that contain 'NA' values
    dataTableVis(:, [3, 4]) = [];
    
    % Convert the table to a numeric array (this will automatically handle 'NA' as NaN)
    dataVis = table2array(dataTableVis);
    
    % Replace all -1 with 2 in columns 1 and 3 (for dataVis)
    dataVis(dataVis(:, 1) == -1, 1) = 2;
    dataVis(dataVis(:, 3) == -1, 3) = 2;
    
    % Check if values in column 2 are 0 and set column 1 to 0 for those rows
    dataVis(dataVis(:, 2) == 0, 1) = 0;
end

if isfile(fileAud)
    % Load the auditory data
    dataTableAud = readtable(fileAud);
    
    % Remove columns 1 and 2 that contain 'NA' values
    dataTableAud(:, [1, 2]) = [];
    
    % Convert the table to a numeric array (this will automatically handle 'NA' as NaN)
    dataAud = table2array(dataTableAud);
    
    % Replace all -1 with 2 in columns 1 and 3 (for dataAud)
    dataAud(dataAud(:, 1) == -1, 1) = 2;
    dataAud(dataAud(:, 3) == -1, 3) = 2;
    
    % Check if values in column 2 are 0 and set column 1 to 0 for those rows
    dataAud(dataAud(:, 2) == 0, 1) = 0;
end

if isfile(fileAV)
    % Load the audiovisual data
    dataTableAV = readtable(fileAV);
    
    % Convert the table to a numeric array (this will automatically handle 'NA' as NaN)
    dataAV = table2array(dataTableAV);
    
    % Replace all -1 with 2 in columns 1, 3, and 5 (for dataAV)
    dataAV(dataAV(:, 1) == -1, 1) = 2;
    dataAV(dataAV(:, 3) == -1, 3) = 2;
    dataAV(dataAV(:, 5) == -1, 5) = 2;
    
    % Check if values in column 2 or column 4 are 0, and set column 1 or column 3 to 0 for those rows
    dataAV(dataAV(:, 2) == 0, 1) = 0;  % Column 2 is 0, set column 1 to 0
    dataAV(dataAV(:, 4) == 0, 3) = 0;  % Column 4 is 0, set column 3 to 0
end

% Now, dataVis, dataAud, and dataAV matrices contain the cleaned data for analysis

%% Figure variables to keep uniform throughout
scatter_size = 75; figure_font_size = 24;
aud_color = '#d73027'; vis_color = '#4575b4'; both_color = '#009304';
aud_icon = 'o'; vis_icon = '^'; both_icon = 's'; 
right_var = 1; left_var = 2; catch_var = 0; chosen_threshold = 0.72; compare_plot = 0; vel_stair = 0;

% Initialize figure for plotting
fig = figure;

% Check if data exists for Auditory (dataAud), Visual (dataVis), and Audiovisual (dataAV)
datasets = {dataAud, dataVis, dataAV};
colors = {aud_color, vis_color, both_color};
labels = {'Auditory Only', 'Visual Only', 'Audiovisual'};
markers = {aud_icon, vis_icon, both_icon};

std_dev = [];
sensitivity = [];
mu = [];

for i = 1:length(datasets)
    data = datasets{i};
    
    if ~isempty(data)
        % Process and plot each dataset
        save_name = 'stair';
        data(data(:, 1) == 0, 1) = 3;  % Modify values where the first column equals 0
        
        % Placeholder functions - replace these with actual function calls
        [right_vs_left, right_group, left_group] = direction_plotter(data);
        try
            rightward_prob = multisensory_rightward_prob_calc(right_vs_left, right_group, left_group, right_var, left_var);
        catch
            rightward_prob = unisensory_rightward_prob_calc(right_vs_left, right_group, left_group, right_var, left_var);
        end
        [total_coh_frequency, left_coh_vals, right_coh_vals, coherence_lvls, coherence_counts, coherence_frequency] = frequency_plotter(data, right_vs_left);
        [fig, p_values, ci, threshold, xData, yData, x, p, sz, std_gaussian, mdl] = normCDF_plotter(coherence_lvls, ...
        rightward_prob, chosen_threshold, left_coh_vals, right_coh_vals, ...
        coherence_frequency, compare_plot, save_name, vel_stair);
        
        % Plot the results
        scatter(xData, yData, sz, 'LineWidth', 2, 'MarkerEdgeColor', colors{i}, 'HandleVisibility', 'off');
        hold on;
        plot(x, p, 'LineWidth', 4, 'Color', colors{i}, 'DisplayName', labels{i});
        std_dev(i) = std_gaussian;
        sensitivity(i) = round(1/std_gaussian, 2);
        mu(i) = mdl.Coefficients{1,1};
        models.(sprintf('Model%d', i)) = mdl;
        xyData.(sprintf('xData%d', i)) = xData;
        xyData.(sprintf('yData%d', i)) = yData;
    end
end

% Set figure properties
title('');
legend('Location', 'NorthWest');
xlabel('Coherence ((-)Leftward, (+)Rightward)');
ylabel('Proportion Rightward Response');
xlim([-0.5 0.5])
ylim([0 1])
xticks([-0.5 0 0.5])
yticks([0 0.2 0.4 0.6 0.8 1.0])


% Beautify plot (optional function, assuming it's defined elsewhere)
beautifyplot;
unmatlabifyplot(0);

% Set the axes to take up the full monitor screen
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 24);

Results_MLE = MLE_Calculations_A_V_AV(models.Model1, models.Model2, models.Model3, xyData.yData1, xyData.yData2, xyData.yData3, xyData.xData1, xyData.xData2, xyData.xData3);

disp('Sensitivity for A, V, AV')
disp(sensitivity)
disp('PSE for A, V, AV')
disp(mu)
disp(Results_MLE)
