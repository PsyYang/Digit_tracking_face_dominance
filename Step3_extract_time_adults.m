clear all;
load('cdata_6.mat');


% ROI definitions
ROI_pos = {[120 585 585 120], [740 1205 1205 740],[105 105 715 715], 'face';
[155 550 550 155],[780 1175 1175 780], [278 278 423 423], 'eye';
[255 460 460 255], [870 1075 1075 870], [410 410 655 655], 'nose';};

adult_struct = {};
for i=1:numel(track_data)
    sub = str2double(track_data(i).sub);
    image_name = track_data(i).Image;
    image_no = str2double(image_name(4:5));
    direction = image_name(7:8);
    data = track_data(i).track_scale;
    rt = sum(data(:,4));
    
    for j=1:3
        X1 = ROI_pos{j,1};
        X2 = ROI_pos{j,2};
        Y = ROI_pos{j,3};
        label = ROI_pos{j,4};
        L_box = inpolygon(data(:,1), data(:,2), X1, Y);
        R_box = inpolygon(data(:,1), data(:,2), X2, Y);
        % 17 means low dominance on the left and high dominace on the right
        if strcmp(direction, '17')
            h_ROI = R_box;
            l_ROI = L_box;

        elseif strcmp(direction, '71')
            h_ROI = L_box;
            l_ROI = R_box;

        end
        h_time = sum(data(h_ROI,4));
        l_time = sum(data(l_ROI,4));
        eval(['Time_' label '_h = h_time/rt;']);
        eval(['Time_' label '_l = l_time/rt;']);
        if j==1
            lf = find(L_box,1,'first');
            rf = find(R_box,1,'first');
            if strcmp(direction, '17') 
                if lf>rf
                    first_fix=1; % 1 mean choose high dominance.
                else
                    first_fix=0;
                end
            elseif strcmp(direction, '71')
                if lf<rf
                    first_fix=1;
                else
                    first_fix=0;
                end
            end
        end
    end
    adult_struct(i).sub = sub;
    adult_struct(i).image_name = image_name;
    adult_struct(i).image_no = image_no;
    adult_struct(i).direction = direction;
    adult_struct(i).RT = rt;
    adult_struct(i).first_fix= first_fix;
    adult_struct(i).Time_face_h = Time_face_h;
    adult_struct(i).Time_face_l = Time_face_l;
    adult_struct(i).Time_eye_h = Time_eye_h;
    adult_struct(i).Time_eye_l = Time_eye_l;
    adult_struct(i).Time_nose_h = Time_nose_h;
    adult_struct(i).Time_nose_l = Time_nose_l;
end

adult_data = struct2table(adult_struct);

% read the subject information
adult_sub_info = readtable('Subject_information.xlsx', ...
    'Sheet', 'Exp_01_Adult_N=51', ...
    'Range', 'A:B');  % Columns A:B

% join adult_data (left) with adult_sub_info (right) on sub = Num
adult_data = outerjoin(adult_data, adult_sub_info, ...
    'LeftKeys', 'sub', ...
    'RightKeys', 'Num', ...
    'Type', 'inner');  % or 'left' if you want all rows from adult_data

adult_data.gender = cellstr(categorical(adult_data.Gender, [0 1], {'F','M'}));
adult_data.Time_face = adult_data.Time_face_h + adult_data.Time_face_l;
writetable(adult_data, 'adult_data.csv');

