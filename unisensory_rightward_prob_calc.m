function [rightward_prob] = unisensory_rightward_prob_calc(right_vs_left, right_group, left_group, right_var, left_var)
% Initialize an empty array
rightward_prob = [];

% Loop over each coherence level and extract the corresponding rows of the matrix for
% i = max(left_group):-1:1 for leftward trials
for i = max(left_group):-1:1
    group_rows = right_vs_left{2,1}(left_group == i, :);
    logical_array = group_rows(:, 3) == left_var;
    count = sum(logical_array);
    percentage = 1 - (count/ size(group_rows, 1));
    rightward_prob = [rightward_prob percentage];
end

% Add to the righward_prob vector the catch trials
if size(right_vs_left, 1) >= 3 && size(right_vs_left{3,1}, 2) >= 2
    group_rows = right_vs_left{3,1};
    logical_array = group_rows(:, 3) == right_var;
    count = sum(logical_array);
    percentage = (count/ size(group_rows, 1));
    rightward_prob = [rightward_prob percentage];
end

% Loop over each coherence level and extract the corresponding rows of the matrix for
% i = 1:max(right_group) for rightward trials
for i = 1:max(right_group)
    group_rows = right_vs_left{1,1}(right_group == i, :);
    logical_array = group_rows(:, 3) == right_var;
    count = sum(logical_array);
    percentage = count/ size(group_rows, 1);
    rightward_prob = [rightward_prob percentage];
end