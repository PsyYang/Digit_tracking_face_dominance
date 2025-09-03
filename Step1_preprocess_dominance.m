% combine data of all subjects
clear all;
fn = {'4-5 ans', '5-6 ans', '6-7 ans', '7-8 ans', '8-9 ans', 'adult'};
[indx,~] = listdlg('PromptString','Which group do you want to look at',...
    'SelectionMode','single','ListString',fn);
% We need to maunally select the group we want to process
switch indx
    case 1
        folder = '4-5age_raw_data';
    case 2
        folder = '5-6age_raw_data';
    case 3
        folder = '6-7age_raw_data';
    case 4
        folder = '7-8age_raw_data';
    case 5
        folder = '8-9age_raw_data';
    case 6
        folder = 'adult_raw_data';
end
file_list = dir([folder '/sub*.mat']);

for i = 1:numel(file_list) % loop for each subject
    file_name = file_list(i).name;
    load(fullfile(folder,file_name));
    subdata = result.data;
    subnum = result.num;
    % loop for each image
    for j = 1:24
        subdata(j).sub = subnum;
        subdata(j).age = indx;
        wH = subdata(j).xpout.wH;
        wW = subdata(j).xpout.wW;    
        tp = subdata(j).TimePoint;
        tracking = subdata(j).Tracking;
        subdata(j).dist = tracking(end,6); % the fourth column is not dist
        subdata(j).RT = tp(3)-tp(1);
        % transform the corrdinates from screen space to image space
        w_gap = (wW-1324)/2;
        h_gap = (wH-936)/2;
        tracking(:,1) = tracking(:,1) - w_gap;
        tracking(:,2) = tracking(:,2) - h_gap;
        tracking = tracking(inpolygon(tracking(:,1), tracking(:,2), [0 0 1324 1324], [0 936 936 0]),:); % remove points outside the image
        subdata(j).track_scale = tracking;  % scale the coordinate      
    end
    if i==1
        track_data = subdata;
    else
        track_data = [track_data subdata];
    end
end
% It's not written as a for loop, so don't forget to manually save the data!

