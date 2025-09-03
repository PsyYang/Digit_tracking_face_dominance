# face_dominance
This project aims to test digit-tracking in a face viewing task. Participants saw 24 pairs of faces with high and low dominance. Here, I preprocess the data for the future linear mixed model analysis in R.

## Stimuli
We have 24 pairs of faces. The first half (ID 1-12, labelled as '17') presents low dominance on the left and high dominance face on the right. The other half (ID 14-25, labelled as '71') shows the faces in a reversed location.

## Raw data
The data of each participant was saved in a mat file. Those mat files were saved in different folders based on the age group (4-5y, 5-6y, 6-7y, 7-8y, 8-9y, and adults)

## Combine data
[Step1_preprocess_dominance](https://github.com/PsyYang/Digit_tracking_face_dominance/blob/main/Step1_preprocess_dominance.m)
Combine the single subject data from the same age group into a big mat file, named as cdata_i, i ranges from 1-6, corresponding to the six age groups.

## Generate heatmaps
[Step2_make_fastmap](https://github.com/PsyYang/Digit_tracking_face_dominance/blob/main/Step2_make_fastmap.m)
Generate attention maps for each trial, then average across subjects, and average across images in each age group. Present the average heat maps of six age groups in the end.
### Functions used:
- fastheatmap.m
- filter_2D_heat_map.m
- filter_3D_heat_map.m
- apply_map.m

## Compute time
### Adults
[Step3_extract_time_adults](https://github.com/PsyYang/Digit_tracking_face_dominance/blob/main/Step3_extract_time_adults.m)
#### Saved table
**direction:** 17 means low dominance on the left and high dominance on the right, reverse for 71  
**first_fix:** 1 means first touch on high dominance faces, 0 means first touch on low dominance faces  
**Time_face:** The proportion of time spent on the face areas of the duration time
### Children
[Step4_extract_time_children](https://github.com/PsyYang/Digit_tracking_face_dominance/blob/main/Step4_extract_time_children.m)  
Same as adults, except adding a variable called age indicating the group.

## Linear mixed models
We conducted linear mixed models to test whether participants prefer high or low dominance.
### Time in ROI
[DGT_Time_LMM](https://github.com/PsyYang/Digit_tracking_face_dominance/blob/main/DGT_Time_LMM.Rmd)

### First fixation
[DGT_First_fix](https://github.com/PsyYang/Digit_tracking_face_dominance/blob/main/DGT_First_fix.Rmd)
