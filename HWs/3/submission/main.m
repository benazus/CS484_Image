file_count = 10;
in = input("Enter superpixel count: ");
cluster_count = input("Enter cluster count: ");
threshold = input("Enter neighbourhood threshold: ");
if in < 1
    in = 500;
end

if cluster_count < 1
    cluster_count = 100;
end

images = cell(file_count, 1);
wavelengths = [10 15 20 25];
orientations = [0 45 90 135];
gabor_filter_bank = gabor(wavelengths, orientations);
superpixels_found = zeros(file_count, 1);
sps = zeros(460, 700, file_count);
gabor_representations = [];
lab_representations = [];

a_min = 0;
a_max = 0;
b_min = 0;
b_max = 0;
l_min = 0;
l_max = 0;
for i = 1:file_count
   if i < 10
        str = strcat("../data/0", string(i), ".png");
    else
        str = strcat("../data/", string(i), ".png");
    end
    
    tmp = imread(str);
    tmp = imresize(tmp, [460, 700]);
    [x, y] = size(tmp);
    
    if x ~= 460
       tmp = imrotate(tmp, 270);
    end
    images{i} = tmp;
    
    tmp_lab = rgb2lab(tmp);
    a = tmp_lab(:, :, 1);
    b = tmp_lab(:, :, 2);
    l = tmp_lab(:, :, 3);
    a_min_i = min(a(:));
    a_max_i = max(a(:));
    b_min_i = min(b(:));
    b_max_i = max(b(:));
    l_min_i = min(l(:));
    l_max_i = max(l(:));
    
    if a_min_i < a_min
        a_min = a_min_i;
    end   
    if a_max_i > a_max
        a_max = a_max_i;
    end
    if b_min_i < b_min
        b_min = b_min_i;
    end   
    if b_max_i > b_max
        b_max = b_max_i;
    end
    if l_min_i < l_min
        l_min = l_min_i;
    end   
    if l_max_i > l_max
        l_max = l_max_i;
    end
    
end

a_bucket_size = (a_max - a_min) / 8;
b_bucket_size = (b_max - b_min) / 8;
l_bucket_size = (l_max - l_min) / 8;

for i = 1:file_count
    tmp = images{i};
    [labels, count] = superpixels(tmp, in);
    
    figure
    bm = boundarymask(labels);
    imshow(imoverlay(tmp,bm,'cyan'),'InitialMagnification',67);
    
    superpixels_found(i) = count;
    sps(:, :, i) = labels;
    tmp_lab = rgb2lab(tmp);
    tmp = rgb2gray(tmp); 
    [mag, phase] = imgaborfilt(tmp, gabor_filter_bank);
    gaborResponse = imgaborfilt(tmp, gabor_filter_bank);

    
    figure
    subplot(4,4,1);
    x = 1;
    y = 1;
    for p = 1:16
        subplot(4,4, p)
        imshow(gaborResponse(:,:,p),[]);
        theta = wavelengths(x);
        lambda = orientations(y);
        title(sprintf('%d, %d',theta,lambda));
        y = y + 1;
        if y > 4
            x = x + 1; 
            y = 1;
        end
    end
    
    gabor_avg = zeros(count, 16);
    
    ab = zeros(count, 8);
    bb = zeros(count, 8);
    lb = zeros(count, 8);
    
    for j = 1:count
        [x, y] = find(labels == j);
        points = horzcat(x,y);
        l_bucket = zeros(8, 1);
        a_bucket = zeros(8, 1);
        b_bucket = zeros(8, 1);
       
        for k = 1:length(x)
            gabor_avg(j, :) = gabor_avg(j, :) + reshape(mag(points(k, 1), points(k, 2), :), [1, 16]);
            
            l_k = l(points(k, 1), points(k, 2));
            a_k = a(points(k, 1), points(k, 2));
            b_k = b(points(k, 1), points(k, 2));       
                    
            if l_k < l_min + l_bucket_size
                l_bucket(1) = l_bucket(1) + 1;
            elseif l_min + l_bucket_size <= l_k && l_k < l_min +  l_bucket_size * 2
                l_bucket(2) = l_bucket(2) + 1;
            elseif l_min + l_bucket_size * 2 <= l_k && l_k < l_min + l_bucket_size * 3
                l_bucket(3) = l_bucket(3) + 1;
            elseif l_min + l_bucket_size * 3 <= l_k && l_k < l_min + l_bucket_size * 4
                l_bucket(4) = l_bucket(4) + 1;
            elseif l_min + l_bucket_size * 4 <= l_k && l_k < l_min + l_bucket_size * 5
                l_bucket(5) = l_bucket(5) + 1;
            elseif l_min + l_bucket_size * 5 <= l_k && l_k < l_min + l_bucket_size * 6
                l_bucket(6) = l_bucket(6) + 1;
            elseif l_min + l_bucket_size * 6 <= l_k && l_k < l_min + l_bucket_size * 7
                l_bucket(7) = l_bucket(7) + 1;
            else%if l_min + l_bucket_size * 7 <= l_k
                l_bucket(8) = l_bucket(8) + 1;
            end     
            
            if a_k < a_min + a_bucket_size
                a_bucket(1) = a_bucket(1) + 1;
            elseif a_min + a_bucket_size <= a_k && a_k < a_min + a_bucket_size * 2
                a_bucket(2) = a_bucket(2) + 1;
            elseif a_min + a_bucket_size * 2 <= a_k && a_k < a_min + a_bucket_size * 3
                a_bucket(3) = a_bucket(3) + 1;
            elseif a_min + a_bucket_size * 3 <= a_k && a_k < a_min + a_bucket_size * 4
                a_bucket(4) = a_bucket(4) + 1;
            elseif a_min + a_bucket_size * 4 <= a_k && a_k < a_min + a_bucket_size * 5
                a_bucket(5) = a_bucket(5) + 1;
            elseif a_min + a_bucket_size * 5 <= a_k && a_k < a_min + a_bucket_size * 6
                a_bucket(6) = a_bucket(6) + 1;
            elseif a_min + a_bucket_size * 6 <= a_k && a_k < a_min + a_bucket_size * 7
                a_bucket(7) = a_bucket(7) + 1;
            else%if a_min + a_bucket_size * 7 <= a_k && a_k < 128
                a_bucket(8) = a_bucket(8) + 1;
            end
            
            if b_k < b_min + b_bucket_size
                b_bucket(1) = b_bucket(1) + 1;
            elseif b_min + b_bucket_size <= b_k && b_k < b_min + b_bucket_size * 2
                b_bucket(2) = b_bucket(2) + 1;
            elseif b_min + b_bucket_size * 2 <= b_k && b_k < b_min + b_bucket_size * 3
                b_bucket(3) = b_bucket(3) + 1;
            elseif b_min + b_bucket_size * 3 <= b_k && b_k < b_min + b_bucket_size * 4
                b_bucket(4) = b_bucket(4) + 1;
            elseif b_min + b_bucket_size * 4 <= b_k && b_k < b_min + b_bucket_size * 5
                b_bucket(5) = b_bucket(5) + 1;
            elseif b_min + b_bucket_size * 5 <= b_k && b_k < b_min + b_bucket_size * 6
                b_bucket(6) = b_bucket(6) + 1;
            elseif b_min + b_bucket_size * 6 <= b_k && b_k < b_min + b_bucket_size * 7
                b_bucket(7) = b_bucket(7) + 1;
            else%if b_min + b_bucket_size * 7 <= b_k
                b_bucket(8) = b_bucket(8) + 1;
            end               
        end
        gabor_avg(j, :) = gabor_avg(j, :) ./ length(x);
        ab(j, :) = transpose(a_bucket);
        bb(j, :) = transpose(b_bucket);
        lb(j, :) = transpose(l_bucket);
    end
    gabor_representations = [gabor_representations; gabor_avg];
    lab_representations = [lab_representations; ab bb lb];
end

gabor_representations = normalize(gabor_representations, "range");
lab_representations = normalize(lab_representations, "range");

representations = [gabor_representations lab_representations];
cluster_labels = kmeans(representations, cluster_count);
falsecolor = cell(file_count, 1);
fr = [];
for i = 1:file_count
    if i == 1
        labels = cluster_labels(1:superpixels_found(1));
        representations_i = representations(1:superpixels_found(1), :);
    elseif 1 < i && i < file_count
        labels = cluster_labels(sum(superpixels_found(1:i)) : sum(superpixels_found(1:i)) + superpixels_found(i));
        representations_i = representations(sum(superpixels_found(1:i)) : sum(superpixels_found(1:i)) + superpixels_found(i), :);
    else
        labels = cluster_labels(sum(superpixels_found(1:file_count - 1)) : sum(superpixels_found(1:file_count - 1)) + superpixels_found(file_count));
        representations_i = representations(sum(superpixels_found(1:file_count - 1)) : sum(superpixels_found(1:file_count - 1)) + superpixels_found(file_count), :);
    end 
     
    falsecolor_label_matrix = zeros(460, 700);
	superpixel_pixels = transpose(struct2cell(regionprops(sps(:, :, i), "PixelList")));
    for j = 1:length(superpixel_pixels)
        [x, y] = size(superpixel_pixels{j});
        for k = 1:x
            falsecolor_label_matrix(superpixel_pixels{j}(k, 1), superpixel_pixels{j}(k, 2)) = labels(j);
        end
    end
    
    figure
    orig = images{i};
    I = imrotate(label2rgb(falsecolor_label_matrix), 270);
    I = imcrop(I, [0 0 700 460]);
    C = imfuse(orig, I, 'blend');
    imshow(C);
    
    stats = transpose(struct2cell(regionprops(sps(:, :, i), "PixelList")));
    for j = 1:superpixels_found(i)
        region_pixels = stats{j};
        x_min = min(region_pixels(:, 1));
        x_max = max(region_pixels(:, 1));
        y_min = min(region_pixels(:, 2));
        y_max = max(region_pixels(:, 2));
        radius = pdist([x_min, y_min; x_max, y_max], "euclidean") / 2;
        center = [(x_min + x_max) / 2 (y_min + y_max) / 2];
        fdnd = radius * 1.5;
        sdnd = radius * 2.5;
        
        fdn_j = [];
        sdn_j = [];
        
        
        for k = 1:superpixels_found(i)
            if k == j
                continue
            else
                region_pixels_k = stats{k};
                
                distances = sqrt((region_pixels_k(:, 1) - center(1)).^2 + (region_pixels_k(:, 2) - center(2)).^2);
                fnc = find(distances <= fdnd);
                snc = find(fdnd < distances & distances < sdnd);
                
                if length(fnc) / length(region_pixels_k) >= threshold
                    fdn_j = [fdn_j; representations_i(k, :)];
                elseif length(snc) / length(region_pixels_k) >= threshold
                    sdn_j = [sdn_j; representations_i(k, :)];
                end
            end
        end
        
        fdn_j = mean(fdn_j, 1);
        sdn_j = mean(sdn_j, 1);
        
        if isempty(fdn_j) == 1
            fdn_j = zeros(1, 40);
        end
        
        if isempty(sdn_j) == 1
            sdn_j = zeros(1, 40);
        end
        
        fr = [fr; representations_i(j, :) fdn_j sdn_j];
    end
end

cluster_labels_f = kmeans(fr, cluster_count);
falsecolor_f = cell(file_count, 1);
for i = 1:file_count
    if i == 1
        labels = cluster_labels_f(1:superpixels_found(1));
    elseif 1 < i && i < file_count
        labels = cluster_labels_f(sum(superpixels_found(1:i)) : sum(superpixels_found(1:i)) + superpixels_found(i));
    else
        labels = cluster_labels_f(sum(superpixels_found(1:file_count - 1)) : sum(superpixels_found(1:file_count - 1)) + superpixels_found(file_count));
    end
    
    falsecolor_label_matrix = zeros(700, 460);
	superpixel_pixels = transpose(struct2cell(regionprops(sps(:, :, i), "PixelList")));
    for j = 1:length(superpixel_pixels)
        [x, y] = size(superpixel_pixels{j});
        for k = 1:x
            falsecolor_label_matrix(superpixel_pixels{j}(k, 1), superpixel_pixels{j}(k, 2)) = labels(j);
        end
    end
    
    figure
    orig = images{i};
    I = imrotate(label2rgb(falsecolor_label_matrix), 270);
    I = imcrop(I, [0 0 700 460]);
    C = imfuse(orig, I, 'blend');
    imshow(C);
end