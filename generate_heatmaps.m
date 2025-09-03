
clear all;

%%% parameters
opts = struct();
opts.time_smooth = false;
opts.resize = true;
opts.flatten = true;
opts.ksstdx = 20;
opts.ksstdy = 20;
opts.normalize = true;



%% compute the fast heat map for each pictures' group map and subjects' map
for age = 1:5
    eval(['load cdata_' num2str(age)]);
    pic_list = dir('Image/*.jpg');
    images = {track_data.Image};
    for j=1:24
        pn = pic_list(j).name;
        ind = ismember(images, pn);
        data_sub = track_data(ind);

        for i=1:numel(data_sub)
            sub = data_sub(i).sub;
            Tracking = data_sub(i).track_scale;
            x=Tracking(:,1)/1324;
            y=Tracking(:,2)/936;
            fixation_time = Tracking(:,4);
            map = fastheatmap(x, y, fixation_time, [936, 1324], opts);
            cd children_heatmaps
            if ~exist(pn(1:end-4))
                mkdir(pn(1:end-4))
            end
            save([pn(1:end-4) '/map_sub' num2str(sub)], 'map');
            cd ..
            disp([pn ' ' 'sub' num2str(sub) ' completed']);
        end
    end
end

%% average based on the new group and then 
sub_info = readtable('Subject_information.xlsx', 'Sheet', 'Exp_03_Development_N=135');

uniqueGroups = unique(sub_info.Group);
pic_list = dir('Image/*.jpg');
cd children_heatmaps
for i=1:numel(uniqueGroups)
     % Get the current group value
    currentGroup = uniqueGroups{i};   
    % Filter: pick only the rows where 'group' matches currentGroup
    current_sub = sub_info(strcmp(sub_info.Group,currentGroup), :);
    sub_nums = current_sub.Subject;
    group_map = 0;
    for p=1:24
        pn = pic_list(p).name;
        img_folder = pn(1:end-4);
        cd(img_folder)
        img_map = 0;
        for j=1:numel(sub_nums)
            if exist(['map_sub' num2str(sub_nums(j)) '.mat'])
                load(['map_sub' num2str(sub_nums(j)) '.mat']);
            else
                disp(['No data from subject ' num2str(sub_nums(j))])
            end
            img_map = img_map + map;
        end
        img_map = (img_map-min(img_map(:)))./(max(img_map(:))-min(img_map(:)));
        cd ..
        if p>12
            img_map = [img_map(:, floor(end/2)+1 : end), img_map(:, 1 : floor(end/2))];
        end
    end
    group_map = group_map + img_map;
    group_map = (group_map-min(group_map(:)))./(max(group_map(:))-min(group_map(:)));

    save(['group_map_' num2str(currentGroup) '.mat'], 'group_map');
end
cd ..
%% present the heat maps
for i=1:5
    load(['children_heatmaps/group_map_' num2str(i+3) '~' num2str(i+4) '.mat']);
    subplot(2,3,i);
    imagesc(group_map);
end