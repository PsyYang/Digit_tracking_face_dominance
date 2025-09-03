function apply_map(pic, map)
image(pic)
axis off
hold on
im = imagesc(map);
set(im,'AlphaData',0.5);
hold off
end