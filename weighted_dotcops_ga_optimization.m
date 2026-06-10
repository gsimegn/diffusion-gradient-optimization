% =========================================================================
% Gradient Scheme Optimization for PRESS-Localized Edited MRS
% Using Weighted Pathway Suppression
%
% This MATLAB script implements a weighted DOTCOPS (Dephasing Optimization
% Through Coherence Order Pathway Selection) framework for optimization of
% crusher gradient schemes in PRESS-localized edited magnetic resonance
% spectroscopy (MRS).
%
% The optimization employs a volume-based likelihood model to prioritize
% coherence transfer pathways (CTPs) according to their probability of
% generating out-of-voxel (OOV) artifacts. A genetic algorithm with a
% dual-penalty objective function is used to maximize unwanted pathway
% suppression while satisfying scanner hardware and sequence timing
% constraints.
%
% Author:
%   Gizeaddis Simegn
%
% Affiliation:
%   Department of Radiology
%   Johns Hopkins University School of Medicine
%
% Associated Publication:
%   Simegn et.al.
%   "Gradient Scheme Optimization for PRESS-Localized Edited MRS Using
%   Weighted Pathway Suppression"
%   PMID: 41261502
%
% Repository:
%   https://github.com/gsimegn/gradient-scheme-optimization-press-edited-mrs
%
% License:
%   MIT License
%
% Version:
%   v1.0.0
%
% =========================================================================

% Define bounds and constraints
ub = [2.09 2.08 2.09 3.23 3.23 3.23 9.75 9.75 9.75 3.22 3.22 3.22 5.725 5.725 5.725];%Siemens
%dotcops = [-1 1 0 -0.27 0.73 -1 -0.73 0.27 -1 -1 -1 -1 1 1 -1]*2.09;
%ub = [1.73 1.73 1.73 3.17 3.17 3.17 9.6 9.6 9.6 3.18 3.18 3.18 5.76 5.76 5.76] - 0.31; %philips 

lb = -ub;
% lb([1 4 5 7 9 10 12 13 14 15]) = 0;
% ub([2 3 6 8 11]) = 0;

Aeq = [1 0 0 -1 0 0 -1 0 0 1 0 0 1 0 0; ...
        0 1 0 0 -1 0 0 -1 0 0 1 0 0 1 0; ...
        0 0 1 0 0 -1 0 0 -1 0 0 1 0 0 1];
beq = [0; 0; 0]; % G1-G2-G3+G4+G5 = 0;

% Precompute P matrix and weighting vector
P = zeros(5, 81);
P(1,:) = repmat([-1 0 1], 1, 27);
P(2,:) = repmat([-1*ones(1,3), zeros(1,3), ones(1,3)], 1, 9);
P(3,:) = repmat([-1*ones(1,9), zeros(1,9), ones(1,9)], 1, 3);
P(4,:) = [repmat(-1,1,27), repmat(0,1,27), repmat(1,1,27)];
P(5,:) = -1;
P = [P(:,1:24), P(:,26:end)];%exclude pathway 25

weighting_baseline = 0.1;
weighting = [2.5000 0.5000 0.2500 0.0100 5.0000 0.0100 0.0500 0.1000 ... %large value for important ones
             0.5000 0.0100 0.0020 0.0010 0.0010 0.5000 0.0010 0.0010 ...
             0.0020 0.0100 0.0500 0.0100 0.0050 0.0010 0.5000 0.0010 ...
             5.0000 0.0500 0.2500 0.0100 0.0020 0.0010 0.0000 0.0200  ...
             0.0000 0.0002 0.0004 0.0020 0.1000 0.0200 0.0100 0.0100 ...
             0.0100 0.0100 0.0200 0.1000 0.0020 0.0004 0.0002 ...
             0.0000 0.0200 0.0000 0.0010 0.0020 0.0100 0.0500 0.0100 ...
             0.0050 0.0002 0.1000 0.0002 0.0010 0.0020 0.0100 0.0020 ...
             0.0004 0.0002 0.0002 0.1000 0.0002 0.0002 0.0004 0.0020 ...
             0.1000 0.0200 0.0100 0.0020 1.0000 0.0020 0.0500 0.1000 0.5000]/5*(1-weighting_baseline) + weighting_baseline;

% Configure GA options
options = optimoptions('ga', ...
    'FunctionTolerance', 1e-8, ...
    'UseParallel', true);

% Initialize storage
all_G = [];
all_vals = [];
min_so_far = Inf;
G_best = [];

% Store cost function and RMS values for plotting
cost_values = zeros(1, 100);
rms_values = zeros(1, 100);


% Run GA optimization multiple times
for ii = 1:100
    fprintf('Iteration %d\n', ii);
    G_out = ga(@(G) negDfunc(G, P, weighting), 15, [], [], Aeq, beq, lb, ub, [], options);
    current_val = negDfunc(G_out, P, weighting);
    
    % Store results
    all_G = [all_G; G_out];
    all_vals = [all_vals; current_val];

    % Store for plotting
    cost_values(ii) = current_val;
    rms_values(ii) = rms(G_out(13:15));
    
    % Update best solution
    if current_val < min_so_far
        G_best = G_out;
        min_so_far = current_val;
    end
    
    fprintf('Current value: %.4f, RMS: %.4f\n', current_val, rms(G_out(13:15)));
end

% Plot cost function and RMS values in the same plot
figure;
hold on;
subplot (211), plot(1:100, cost_values, '-o', 'LineWidth', 1.5, 'Color', 'b', 'DisplayName', 'Cost Function');
subplot(212), plot(1:100, rms_values, '-s', 'LineWidth', 1.5, 'Color', 'r', 'DisplayName', 'RMS of G\_out(13:15)');
xlabel('Iteration');
ylabel('Value');
title('Cost function and RMS Trend Over Iterations');
legend;
grid on;
hold off;

% Select top 10 best 
[sorted_vals, sorted_indices] = sort(all_vals);
top10_indices = sorted_indices(1:10);
top10_G = all_G(top10_indices, :);

% Thresholds for each gradient for Siemens
% thresholds = [
%     2.09, 3.23, 9.75, 3.22, 5.725;  % Gradient 1
%     2.08, 3.23, 9.75, 3.22, 5.725;  % Gradient 2
%     2.09, 3.23, 9.75, 3.22, 5.725   % Gradient 3
% ];
% Thresholds for each gradient for Philips
thresholds = [
    1.42, 2.86, 9.29, 2.87, 5.45;  % Gradient 1
    1.42, 2.86, 9.29, 2.87, 5.45;  % Gradient 2
    1.42, 2.86, 9.29, 2.87, 5.45;   % Gradient 3
];

figure;
tiledlayout(3,10); % 3 rows (parameter groups) x 10 columns (schemes)

for i = 1:10
    G_scheme = top10_G(i, :);
    current_val = sorted_vals(i);
    rms_val = rms(G_scheme(13:15));

    % Gradient 1
    ax1 = nexttile(i);
    G1_vals = [G_scheme(1), G_scheme(4), G_scheme(7), G_scheme(10), G_scheme(13)];
    b1 = bar(ax1, G1_vals, 'FaceColor', 'flat'); 
    for j = 1:length(G1_vals)
        rounded_G1 = round(G1_vals(j), 2);
        rounded_threshold = floor(thresholds(1, j)*100)/100;

        if abs(rounded_G1) >= abs(rounded_threshold)
            b1.CData(j, :) = [1 0 0]; % Red if |G| >= |Threshold|
        else
            b1.CData(j, :) = [0 0 1]; % Blue otherwise
        end
    end
    ylim([-7 10]);
    if i == 1
        ylabel('Gradient 1');
    end
    ax1.XTickLabel = []; 

    %title(sprintf('Scheme %d\nVal:%.2f', i, current_val));
    title(sprintf('Scheme %d\nVal:%.2f RMS:%.2f', i, current_val, rms_val));


    % Gradient 2
    ax2 = nexttile(10 + i);
    G2_vals = [G_scheme(2), G_scheme(5), G_scheme(8), G_scheme(11), G_scheme(14)];
    b2 = bar(ax2, G2_vals, 'FaceColor', 'flat'); 
    for j = 1:length(G2_vals)
        rounded_G2 = round(G2_vals(j), 2);
        rounded_threshold = floor(thresholds(2, j)*100)/100;

        if abs(rounded_G2) >= abs(rounded_threshold)
            b2.CData(j, :) = [1 0 0]; % Red if |G| >= |Threshold|
        else
            b2.CData(j, :) = [0 0 1]; % Blue otherwise
        end
    end
    ylim([-7 10]);
    if i == 1
        ylabel('Gradient 2');
    end
    ax2.XTickLabel = []; 

    % Gradient 3
    ax3 = nexttile(20 + i);
    G3_vals = [G_scheme(3), G_scheme(6), G_scheme(9), G_scheme(12), G_scheme(15)];
    b3 = bar(ax3, G3_vals, 'FaceColor', 'flat'); 
    for j = 1:length(G3_vals)
        rounded_G3 = round(G3_vals(j), 2);
        rounded_threshold = floor(thresholds(3, j)*100)/100;

        if abs(rounded_G3) >= abs(rounded_threshold)
            b3.CData(j, :) = [1 0 0]; % Red if |G| >= |Threshold|
        else
            b3.CData(j, :) = [0 0 1]; % Blue otherwise
        end
    end
    ylim([-7 10]);
    if i == 1   
        ylabel('Gradient 3');
    end
    ax3.XTickLabel = []; 
end

sgtitle('Top 10 G Schemes');


% Final results
fprintf('Best value: %.4f\n', negDfunc(G_best, P, weighting));

function out = negDfunc(G, P, weighting)
    G = reshape(G, [3, 5]);
    D = rms(G * P, 1) * sqrt(3);
    out = -1*(min(D./weighting) + mean(D.*weighting));
end
