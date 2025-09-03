%% compute heatmaps
clear all;
for g=1:5
    % load the data
    load(['cdata_' num2str(g) '.mat']);

    ROI_pos = {[120 585 585 120], [740 1205 1205 740],[105 105 715 715], 'face';
        [155 550 550 155],[780 1175 1175 780], [278 278 423 423], 'eye';
        [255 460 460 255], [870 1075 1075 870], [410 410 655 655], 'nose';};

    sum_struct = {};
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
        sum_struct(i).sub = sub;
        %sum_struct(i).age = g;
        sum_struct(i).image_name = image_name;
        sum_struct(i).image_no = image_no;
        sum_struct(i).direction = direction;
        sum_struct(i).RT = rt;
        sum_struct(i).first_fix= first_fix;
        sum_struct(i).Time_face_h = Time_face_h;
        sum_struct(i).Time_face_l = Time_face_l;
        sum_struct(i).Time_eye_h = Time_eye_h;
        sum_struct(i).Time_eye_l = Time_eye_l;
        sum_struct(i).Time_nose_h = Time_nose_h;
        sum_struct(i).Time_nose_l = Time_nose_l;

    end

    eval(['tbl_' num2str(g) ' = struct2table(sum_struct);']);
end

%% combine all the data together
children_data = [tbl_1;tbl_2;tbl_3;tbl_4;tbl_5];
children_sub_info = readtable('Subject_information.xlsx', ...
    'Sheet', 'Exp_03_Development_N=135');
children_sub_info = children_sub_info(:, [1,2,4]);
children_data = outerjoin(children_data, children_sub_info, ...
    'LeftKeys','sub','RightKeys','Subject','Type','inner');
children_data.Time_face = children_data.Time_face_h + children_data.Time_face_l;
children_data.gender = cellstr(categorical(children_data.Gender, [0 1], {'F','M'}));
writetable(children_data, 'children_data.csv');