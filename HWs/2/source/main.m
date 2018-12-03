run("../vlfeat/vlfeat-0.9.21/toolbox/vl_setup")

filenames = string(importdata("../data/files.txt", "\n"));
classes = string(importdata("../data/classes.txt", "\n"));

data = cell(length(filenames), 1);
file_count = length(filenames);
image_descriptors = cell(file_count, 3);
descriptor_counts = zeros(file_count, 1);
i = 1;

input1 = input("Enter first cluster count: ");
input2 = input("Enter second cluster count: ");

input3 = input("For Gradient-based, enter 1; for Color-Based, enter 2; for Concatenated, enter 3: ");

while i <= file_count
    str = strcat("../data/", string(filenames(i)));
    tmp = imread(str);
    [x, y] = size(tmp);
    
    if x > 1000 || y > 1000
        tmp = imresize(tmp, [300 300]);
    end
    
    data{i} = tmp;
    
    % Descriptors
    [a, b, c] = descriptors(data{i});
    image_descriptors{i, 1} = transpose(a);
    image_descriptors{i, 2} = b;
    image_descriptors{i, 3} = transpose(c);
    descriptor_counts(i) = length(image_descriptors{i}(:, 1));
    disp("Descriptor for file -> " + i);
    i = i + 1;
end

data_gradient_128 = double(image_descriptors{1, 3});
data_color = double(image_descriptors{1, 2});
data_concat = horzcat(image_descriptors{1, 2}, double(image_descriptors{1, 3}));
i = 2;
while i <= file_count
    data_gradient_128 = vertcat(data_gradient_128, double(image_descriptors{i, 3}));
    data_color = vertcat(data_color, double(image_descriptors{i, 2}));
    concat = horzcat(image_descriptors{i, 2}, double(image_descriptors{i, 3}));
    data_concat = vertcat(data_concat, concat);
    i = i + 1;
end

% K-means clustering
disp("End of descriptor detection, starting k-means clustering.");
[kmeans_gradient_500_C, kmeans_gradient_500_A] = vl_kmeans(transpose(data_gradient_128), input1, 'algorithm', 'ELKAN', 'maxnumcomparisons', 100, 'maxnumiterations', 100);
[kmeans_gradient_1000_C, kmeans_gradient_1000_A] = vl_kmeans(transpose(data_gradient_128), input2, 'algorithm', 'ELKAN', 'maxnumcomparisons', 100, 'maxnumiterations', 100);

[kmeans_color_500_C, kmeans_color_500_A] = vl_kmeans(transpose(data_color), input1, 'algorithm', 'ELKAN', 'maxnumcomparisons', 100, 'maxnumiterations', 100);
[kmeans_color_1000_C, kmeans_color_1000_A] = vl_kmeans(transpose(data_color), input2, 'algorithm', 'ELKAN', 'maxnumcomparisons', 100, 'maxnumiterations', 100);

[kmeans_concat_500_C, kmeans_concat_500_A] = vl_kmeans(transpose(data_concat), input1, 'algorithm', 'ELKAN', 'maxnumcomparisons', 100, 'maxnumiterations', 100);
[kmeans_concat_1000_C, kmeans_concat_1000_A] = vl_kmeans(transpose(data_concat), input2, 'algorithm', 'ELKAN', 'maxnumcomparisons', 100, 'maxnumiterations', 100);

% Bag of words
% you may retrieve a (number of local features) x (size of descriptors)
% chunk from the kmeans output & then count how many descriptors put into which chunk
disp("End of k-means clustering, bag-of-words starting.");
i = 1;
bow_gradient_first_A = zeros(file_count, 500);
bow_gradient_second_A = zeros(file_count, 1000);
bow_color_first_A = zeros(file_count, 500);
bow_color_second_A = zeros(file_count, 1000);
bow_concat_first_A = zeros(file_count, 500);
bow_concat_second_A = zeros(file_count, 1000);
while i <= file_count
    disp("Bag-of-words for file -> " + i);
    if i == 1
        desc_grad_500_A = kmeans_gradient_500_A(1 : descriptor_counts(1));
        desc_grad_1000_A = kmeans_gradient_1000_A(1 : descriptor_counts(1));
        desc_color_500_A = kmeans_color_500_A(1 : descriptor_counts(1));
        desc_color_1000_A = kmeans_color_1000_A(1 : descriptor_counts(1));
        desc_concat_500_A = kmeans_concat_500_A(1 : descriptor_counts(1));
        desc_concat_1000_A = kmeans_concat_1000_A(1 : descriptor_counts(1));
    end
    if 1 < i && i < file_count
        desc_grad_500_A = kmeans_gradient_500_A(sum(descriptor_counts(1:i-1)) + 1 : sum(descriptor_counts(1:i-1)) + descriptor_counts(i));
        desc_grad_1000_A = kmeans_gradient_1000_A(sum(descriptor_counts(1:i-1)) + 1 : sum(descriptor_counts(1:i-1)) + descriptor_counts(i));
        desc_color_500_A = kmeans_color_500_A(sum(descriptor_counts(1:i-1)) + 1 : sum(descriptor_counts(1:i-1)) + descriptor_counts(i));
        desc_color_1000_A = kmeans_color_1000_A(sum(descriptor_counts(1:i-1)) + 1 : sum(descriptor_counts(1:i-1)) + descriptor_counts(i));
        desc_concat_500_A = kmeans_concat_500_A(sum(descriptor_counts(1:i-1)) + 1 : sum(descriptor_counts(1:i-1)) + descriptor_counts(i));
        desc_concat_1000_A = kmeans_concat_1000_A(sum(descriptor_counts(1:i-1)) + 1 : sum(descriptor_counts(1:i-1)) + descriptor_counts(i));
    end
    if i == file_count
        desc_grad_500_A = kmeans_gradient_500_A(sum(descriptor_counts(1:file_count - 1)) + 1 : sum(descriptor_counts(1:file_count - 1)) + descriptor_counts(file_count));
        desc_grad_1000_A = kmeans_gradient_1000_A(sum(descriptor_counts(1:file_count - 1)) + 1 : sum(descriptor_counts(1:file_count - 1)) + descriptor_counts(file_count));
        desc_color_500_A = kmeans_color_500_A(sum(descriptor_counts(1:file_count - 1)) + 1 : sum(descriptor_counts(1:file_count - 1)) + descriptor_counts(file_count));
        desc_color_1000_A = kmeans_color_1000_A(sum(descriptor_counts(1:file_count - 1)) + 1 : sum(descriptor_counts(1:file_count - 1)) + descriptor_counts(file_count));
        desc_concat_500_A = kmeans_concat_500_A(sum(descriptor_counts(1:file_count - 1)) + 1 : sum(descriptor_counts(1:file_count - 1)) + descriptor_counts(file_count));
        desc_concat_1000_A = kmeans_concat_1000_A(sum(descriptor_counts(1:file_count - 1)) + 1 : sum(descriptor_counts(1:file_count - 1)) + descriptor_counts(file_count));
    end
    
    j = 1;
    while j <= descriptor_counts(i)
        bow_gradient_first_A(i, desc_grad_500_A(j)) = bow_gradient_first_A(i, desc_grad_500_A(j)) + 1;
        bow_gradient_second_A(i, desc_grad_1000_A) = bow_gradient_second_A(i, desc_grad_1000_A(j)) + 1;
        bow_color_first_A(i, desc_color_500_A(j)) = bow_color_first_A(i, desc_color_500_A(j)) + 1;
        bow_color_second_A(i, desc_color_1000_A(j)) = bow_color_second_A(i, desc_color_1000_A(j)) + 1;
        bow_concat_first_A(i, desc_concat_500_A(j)) = bow_concat_first_A(i, desc_concat_500_A(j)) + 1;
        bow_concat_second_A(i, desc_concat_1000_A(j)) = bow_concat_second_A(i, desc_concat_1000_A(j)) + 1;
        j = j + 1;
    end
    i = i + 1;
end

disp("bag-of-words finished, t-SNE starting.");
tsne_gradient_first = tsne(bow_gradient_first_A, 'Algorithm', 'exact', 'Distance', 'euclidean');
tsne_gradient_second = tsne(bow_gradient_second_A, 'Algorithm', 'exact', 'Distance', 'euclidean');
tsne_color_first = tsne(bow_color_first_A, 'Algorithm', 'exact', 'Distance', 'euclidean');
tsne_color_second = tsne(bow_color_second_A, 'Algorithm', 'exact', 'Distance', 'euclidean');
tsne_concat_first = tsne(bow_concat_first_A, 'Algorithm', 'exact', 'Distance', 'euclidean');
tsne_concat_second = tsne(bow_concat_second_A, 'Algorithm', 'exact', 'Distance', 'euclidean');

% for each label, plot 2-point in tsne output with same color
if input3 == 1
    figure;
    gscatter(tsne_gradient_first(:,1), tsne_gradient_first(:,2), classes(1:file_count));

    figure;
    gscatter(tsne_gradient_second(:,1), tsne_gradient_second(:,2), classes(1:file_count));
end

if input3 == 2
    figure;
    gscatter(tsne_color_first(:,1), tsne_color_first(:,2), classes(1:file_count));

    figure;
    gscatter(tsne_color_second(:,1), tsne_color_second(:,2), classes(1:file_count));
end

if input3 == 3
    figure;
    gscatter(tsne_concat_first(:,1), tsne_concat_first(:,2), classes(1:file_count));

    figure;
    gscatter(tsne_concat_second(:,1), tsne_concat_second(:,2), classes(1:file_count));
end

if input3 ~= 1 && input3 ~= 2 && input3 ~= 3
    figure;
    gscatter(tsne_gradient_first(:,1), tsne_gradient_first(:,2), classes(1:file_count));

    figure;
    gscatter(tsne_gradient_second(:,1), tsne_gradient_second(:,2), classes(1:file_count));
    
    figure;
    gscatter(tsne_color_first(:,1), tsne_color_first(:,2), classes(1:file_count));

    figure;
    gscatter(tsne_color_second(:,1), tsne_color_second(:,2), classes(1:file_count));
    
    figure;
    gscatter(tsne_concat_first(:,1), tsne_concat_first(:,2), classes(1:file_count));

    figure;
    gscatter(tsne_concat_second(:,1), tsne_concat_second(:,2), classes(1:file_count));
end

disp("End of program.");