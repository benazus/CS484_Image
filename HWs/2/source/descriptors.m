function [F, color_histograms, d] = descriptors(input_image)
save = input_image;
input_image = rgb2gray(input_image);
img = im2single(input_image);
F = vl_sift(img);
[~, d] = vl_sift(img);
[image_x, image_y] = size(img);
image_boundaries = [image_x image_y];
color_histograms = zeros(length(F), 64);
i=1;

while i <= length(F)
    point = F(:, i);
    
    centerx = point(1);
    centery = point(2);
    distance = point(3) * 6; % This is 100% empirical
    angle = point(4);
    
    %Descriptor corners
    corner_topRight = [centerx + distance centery - distance];
    corner_topLeft = [centerx - distance centery - distance];
    corner_bottomLeft = [centerx - distance centery + distance];
    corner_bottomRight = [centerx + distance centery + distance];

    rotated_topRight = [((corner_topRight(1) - centerx) * cos(angle) - (corner_topRight(2) - centery) * sin(angle)) + centerx ((corner_topRight(1) - centerx) * sin(angle) + (corner_topRight(2) - centery) * cos(angle)) + centery];
    rotated_topLeft = [((corner_topLeft(1) - centerx) * cos(angle) - (corner_topLeft(2) - centery) * sin(angle)) + centerx ((corner_topLeft(1) - centerx) * sin(angle) + (corner_topLeft(2) - centery) * cos(angle)) + centery];
    rotated_bottomLeft = [((corner_bottomLeft(1) - centerx) * cos(angle) - (corner_bottomLeft(2) - centery) * sin(angle)) + centerx ((corner_bottomLeft(1) - centerx) * sin(angle) + (corner_bottomLeft(2) - centery) * cos(angle)) + centery];
    rotated_bottomRight = [((corner_bottomRight(1) - centerx) * cos(angle) - (corner_bottomRight(2) - centery) * sin(angle)) + centerx ((corner_bottomRight(1) - centerx) * sin(angle) + (corner_bottomRight(2) - centery) * cos(angle)) + centery];

    % Finding line segments passing through corners
    coefficients_rightToTop = polyfit([rotated_topRight(1), rotated_topLeft(1)], [rotated_topRight(2), rotated_topLeft(2)], 1);
    coefficients_topToLeft = polyfit([rotated_topLeft(1), rotated_bottomLeft(1)], [rotated_topLeft(2), rotated_bottomLeft(2)], 1);
    coefficients_leftToBottom = polyfit([rotated_bottomLeft(1), rotated_bottomRight(1)], [rotated_bottomLeft(2), rotated_bottomRight(2)], 1);
    coefficients_bottomToRight = polyfit([rotated_bottomRight(1), rotated_topRight(1)], [rotated_bottomRight(2), rotated_topRight(2)], 1);
    
    % Generate iteration boundaries for color histogram
    %x_max = max([rotated_topRight(1) rotated_topLeft(1) rotated_bottomLeft(1) rotated_bottomRight(1)]);
    %x_min = min([rotated_topRight(1) rotated_topLeft(1) rotated_bottomLeft(1) rotated_bottomRight(1)]);
    y_max = max([rotated_topRight(2) rotated_topLeft(2) rotated_bottomLeft(2) rotated_bottomRight(2)]);
    y_min = min([rotated_topRight(2) rotated_topLeft(2) rotated_bottomLeft(2) rotated_bottomRight(2)]); 
    
    structure_boundaries = cell(round((y_max - y_min + 1), 0), 1);

    if y_min < 1
        y_min = 1;
    end
    if y_min > image_boundaries(2)
        y_min = image_boundaries(2);             
    end        
    if y_max < 1
        y_max = 1;
    end
    if y_max > image_boundaries(2)
        y_max = image_boundaries(2);             
    end

    y_iterate = y_min;
    index = 1;
    while y_iterate <= y_max
        if y_iterate < centery
            x_left = floor((y_iterate - coefficients_topToLeft(2)) / coefficients_topToLeft(1));
            x_right = floor((y_iterate - coefficients_rightToTop(2)) / coefficients_rightToTop(1));

            if x_left < 1
                x_left = 1;
            end
            if x_left > image_boundaries(1)
                x_left = image_boundaries(1);             
            end

            if x_right < 1
                x_right = 1;
            end
            if x_right > image_boundaries(1)
                x_right = image_boundaries(1);             
            end

            structure_boundaries{index} = [floor(y_iterate) x_left x_right];                
        end
        if y_iterate >= centery
            x_left = floor((y_iterate - coefficients_leftToBottom(2)) / coefficients_leftToBottom(1));
            x_right = floor((y_iterate - coefficients_bottomToRight(2)) / coefficients_bottomToRight(1));

            if x_left < 1
                x_left = 1;
            end
            if x_left > image_boundaries(1)
                x_left = image_boundaries(1);             
            end

            if x_right < 1
                x_right = 1;
            end
            if x_right > image_boundaries(1)
                x_right = image_boundaries(1);             
            end

            structure_boundaries{index} = [floor(y_iterate) x_left x_right];
        end
        y_iterate = y_iterate + 1;
        index = index + 1;
    end
    structure_boundaries = structure_boundaries(~cellfun('isempty', structure_boundaries));
    
    % Generate color histograms
    j = 1;
    while j <= length(structure_boundaries)
        index_y = structure_boundaries{j, 1}(1);
        index_x = structure_boundaries{j, 1}(2);
        while index_x <= structure_boundaries{j, 1}(3)
            pixel = save(index_x, index_y, :);
            pixel_red = pixel(1);
            pixel_green = pixel(2);
            pixel_blue = pixel(3);
            category_red = 0;
            category_green = 0;
            category_blue = 0;
            
            if pixel_red < 64
                category_red = 1; end
            if (64 <= pixel_red) && (pixel_red < 128)
                category_red = 2; end
            if (128 <= pixel_red) && (pixel_red < 192)
                category_red = 3; end
            if 192 <= pixel_red
                category_red = 4; end
            
            if pixel_green < 64
                category_green = 1; end
            if (64 <= pixel_green) && (pixel_green < 128)
                category_green = 2; end
            if (128 <= pixel_green) && (pixel_green < 192)
                category_green = 3; end
            if 192 <= pixel_green
                category_green = 4; end
            
            if pixel_blue < 64
                category_blue = 1; end
            if (64 <= pixel_blue) && (pixel_blue < 128)
                category_blue = 2; end
            if (128 <= pixel_blue) && (pixel_blue < 192)
                category_blue = 3; end
            if 192 <= pixel_blue
                category_blue = 4; end
            
            color_histograms(i, ((category_red - 1) * 16 + (category_green - 1) * 4 + category_blue)) = color_histograms(i, ((category_red - 1) * 16 + (category_green - 1) * 4 + category_blue)) + 1;
            index_x = index_x + 1;
        end
        j = j + 1;    
    end
%     bar(color_histograms(i, :))
%     bar(d(:, i))
    i = i + 1;
end
end

