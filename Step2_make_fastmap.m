%% compute heatmaps for each trial and the average map for each image
clear all;

%%% parameters
opts = struct();
opts.time_smooth = false;
opts.resize = true;
opts.flatten = true;
opts.ksstdx = 10;
opts.ksstdy = 10;
opts.normalize = true;

for g=1:6
    % load the data from a certain group
    eval(['load cdata_' num2str(g)]);

    pic_list = dir('Image/*.jpg');
    images = {track_data.Image};
    for j=1:24
        pn = pic_list(j).name;
        ind = ismember(images, pn);
        data_sub = track_data(ind);
        group_map = 0;

        for i=1:numel(data_sub)
            Tracking = data_sub(i).track_scale;
            x=Tracking(:,1)/1324;
            y=Tracking(:,2)/936;
            fixation_time = Tracking(:,4);
            map = fastheatmap(x, y, fixation_time, [936, 1324], opts);
            % this is the map of each trial
            if g==6
                save(['heatmap/Adults/single_trial_map/' pn(1:end-4) '_sub_' data_sub(i).sub '.mat'], 'map');
            else
                save(['heatmap/Children/single_trial_map/' pn(1:end-4) '_sub_' data_sub(i).sub '.mat'], 'map');
            end
            group_map = group_map + map;
        end
        group_map = group_map/numel(data_sub);
        group_map = (group_map-min(group_map(:)))./(max(group_map(:))-min(group_map(:)));
        % This is the average map across subjects for one image
        %     imagesc(map);

        % apply heatmaps on original images
        pic = imread(['Image/' pn]);
        apply_map(pic, group_map);

        if g==6
            save(['heatmap/Adults/average_image_map/' pn(1:end-4) '_group_map'], 'group_map');
            saveas(gcf, ['heatmap/Adults/average_image_map/' pn(1:end-4) '_map.jpg']);
        end
        disp([pn ' completed']);
    end
    close;
end


%%
clear all;

% find the subjects in each group
filename = 'children_data.csv';
opts = detectImportOptions(filename);
opts.SelectedVariableNames = {'sub', 'age_group'}; % Specify the columns to read by name
% Read certain columns from the CSV file
sub_info = readtable(filename, opts);
sub_info_unique = unique(sub_info, 'rows');
% Find unique groups and their indices
[group, groupIDs] = findgroups(sub_info_unique.age_group);
% Use splitapply to gather 'sub' values for each 'age_group'
subsInGroups = splitapply(@(x) {x}, sub_info_unique.sub, group);
% Create a new table to display age groups with their corresponding subs
groupedSubs = table(groupIDs, subsInGroups, 'VariableNames', {'Age_Group', 'Subs'});

% Navigate to the specified directory
cd heatmap/Adults/average_image_map/
map_list = dir('*.mat');
n_map = numel(map_list);
adult_map = 0;

% Check if the number of maps is correct
if n_map ~= 24
    disp('There is something wrong!');
else
    for i = 1:n_map
        load(map_list(i).name);
        img_number = str2double(regexp(map_list(i).name, 'ID_(\d+)_', 'tokens', 'once'));
        disp(img_number)
        
        if img_number < 12
            % Switch left and right faces
            temp_map = group_map;
            left_face = [120 585 585 120; 105 105 715 715];
            right_face = [740 1205 1205 740; 105 105 715 715];
            
            % Extract regions
            left_region = temp_map(105:715, 120:585);
            right_region = temp_map(105:715, 740:1205);
            
            % Swap regions
            temp_map(105:715, 120:585) = right_region;
            temp_map(105:715, 740:1205) = left_region;
            
            group_map = temp_map;
        end
        
        adult_map = adult_map + group_map;
    end
end

% Normalize the map
adult_map_norm = (adult_map - min(adult_map(:))) ./ (max(adult_map(:)) - min(adult_map(:)));

% Return to the previous directory and save results
cd ../../
save('adult_map.mat', 'adult_map_norm');

% Display and save the heatmap
imagesc(adult_map_norm);
colorbar; % Optional: Adds a colorbar to visualize scale
axis image; % Optional: Makes each pixel square in shape
saveas(gcf, 'adult_map.jpg');


% in each children group
cd Children


% Loop through each group
for g = 1:3
    % Navigate to the directory containing single trial maps
    cd single_trial_map
    
    % Retrieve subject list for the current group
    sub_list = groupedSubs(g, "Subs").Subs{1,1};
    
    % Process each subject in the list
    for s = 1:size(sub_list, 1)
        sub = sub_list(s);
        
        % Find all map files for the current subject
        map_list = dir(['*_sub_' num2str(sub) '.mat']);
        n_map = numel(map_list);
        child_map = 0;
        
        % Check if the number of maps matches the expected count
        if n_map ~= 24
            disp('There is something wrong!');
        else
            for i = 1:n_map
                load(map_list(i).name);
                img_number = str2double(regexp(map_list(i).name, 'ID_(\d+)_', 'tokens', 'once'));
                
                if img_number < 12
                    % Switch left and right faces
                    temp_map = map;
                    left_face = [120 585 585 120; 105 105 715 715];
                    right_face = [740 1205 1205 740; 105 105 715 715];
                    
                    % Extract regions
                    left_region = temp_map(105:715, 120:585);
                    right_region = temp_map(105:715, 740:1205);
                    
                    % Swap regions
                    temp_map(105:715, 120:585) = right_region;
                    temp_map(105:715, 740:1205) = left_region;
                    
                    map = temp_map;
                end
                
                child_map = child_map + map;
            end
        end
        
        % Normalize the accumulated map
        child_map_norm = (child_map - min(child_map(:))) / (max(child_map(:)) - min(child_map(:)));
        
        % Ensure the directory for saving results exists
        if ~exist(['../average_subject_map/Group' num2str(g)], 'dir')
            mkdir(['../average_subject_map/Group' num2str(g)]);
        end
        
        % Save the normalized map and the image
        cd ..  % Go back to the parent directory before saving
        save(['average_subject_map/Group' num2str(g) '/sub_' num2str(sub) '_map.mat'], 'child_map_norm');
        imagesc(child_map_norm); colorbar; axis image;
        saveas(gcf, ['average_subject_map/Group' num2str(g) '/sub_' num2str(sub) '_map.jpg']);
        
        % Return to the single_trial_map directory for the next subject
        cd single_trial_map
    end
    
    % Go back to the parent directory after processing all subjects in a group
    cd ..
end

% Finally, navigate back to the original base directory
cd ..



%% 
clear all

for g = 1:3
    cd Children/average_subject_map
    cd(['Group' num2str(g)]);
    map_list = dir('*.mat');
    n_map = numel(map_list);
    children_map = 0;
    
    for i=1:n_map
        load(map_list(i).name);
        children_map = children_map + child_map_norm;
    end

    children_map_norm = (children_map - min(children_map(:)))./(max(children_map(:)) - min(children_map(:)));
    cd ..
    cd ..
    cd ..
    save(['children_group' num2str(g) '.mat'], 'children_map_norm');
    imagesc(children_map_norm);
    saveas(gcf, ['children_group' num2str(g) '.jpg']);
end



%% show four maps together
clear all
% 0) Create a new figure 
h = figure('Units','inches','Position',[1 1 8 6]);  

% 1) Subplots
subplot(2,2,1);
load('children_group1.mat');
imagesc(children_map_norm);
xlabel('4-5y','FontWeight','bold');
set(gca,'XTick',[],'YTick',[]);

subplot(2,2,2);
load('children_group2.mat');
imagesc(children_map_norm);
xlabel('6-7y','FontWeight','bold');
set(gca,'XTick',[],'YTick',[]);

subplot(2,2,3);
load('children_group3.mat');
imagesc(children_map_norm);
xlabel('7-9y','FontWeight','bold');
set(gca,'XTick',[],'YTick',[]);

subplot(2,2,4);
load('adult_map.mat');
imagesc(adult_map_norm);
xlabel('Adults','FontWeight','bold');
set(gca,'XTick',[],'YTick',[]);

% 2) Ensure the vector renderer for the figure
set(h, 'Renderer', 'painters');

% 3) Match paper size to screen size
set(h, 'PaperUnits',   'inches', ...
       'PaperPosition', [0 0 8 6]);

% 4a) Export to PDF (vector + 600 dpi raster fallback)
print(h, 'Figure2a.pdf', '-dpdf', '-r600');



