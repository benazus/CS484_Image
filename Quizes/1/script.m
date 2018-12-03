image = imread("image.jpg");
figure; imshow(image); axis image;
title("Original Image");

%Color histograms
redDistribution = image(:, :, 1);
greenDistribution = image(:, :, 2);
blueDistribution = image(:, :, 3);
[red, x] = imhist(redDistribution);
[green, x] = imhist(greenDistribution);   
[blue, x] = imhist(blueDistribution);
plot(x, red, "Red", x, green, "Green", x, blue, "Blue"); % histograms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Faces
redDistributionPeople = 200 > image(:, :, 1) & image(:, :, 1) > 125;
figure; 
imagesc(redDistributionPeople); colormap(gray); axis image;
title("Red people");

greenDistributionPeople = 200 > image(:, :, 2) & image(:, :, 2) > 70;
figure; 
imagesc(greenDistributionPeople); colormap(gray); axis image;
title("Green people");

blueDistributionPeople = 150 > image(:, :, 3) & image(:, :, 3) > 30;
figure; 
imagesc(blueDistributionPeople); colormap(gray); axis image;
title("Blue people");

merged = (redDistributionPeople & greenDistributionPeople) & blueDistributionPeople;
figure; 
imagesc(merged); colormap(gray); axis image;
title("Red & Green & Blue people");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Cars
redDistributionCar = 135 > image(:, :, 1) & image(:, :, 1) > 100;
figure; 
imagesc(redDistributionCar); colormap(gray); axis image;
title("Red car");

greenDistributionCar = 200 > image(:, :, 2) & image(:, :, 2) > 140;
figure; 
imagesc(greenDistributionCar); colormap(gray); axis image;
title("Green car");

blueDistributionCar = image(:, :, 3) > 185;
figure; 
imagesc(blueDistributionCar); colormap(gray); axis image;
title("Blue car");

merged2 = (redDistributionCar & greenDistributionCar) & blueDistributionCar;
figure; 
imagesc(merged2); colormap(gray); axis image;
title("Red & Green & Blue for car");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Acccessory
redDistributionAccessory = 45 > image(:, :, 1);
figure; 
imagesc(redDistributionAccessory); colormap(gray); axis image;
title("Red accessory");

greenDistributionAccessory = 25 > image(:, :, 2);
figure; 
imagesc(greenDistributionAccessory); colormap(gray); axis image;
title("Green accessory");

blueDistributionAccessory = 44 > image(:, :, 3);
figure; 
imagesc(blueDistributionAccessory); colormap(gray); axis image;
title("Blue accessory");

merged3 = (redDistributionAccessory & greenDistributionAccessory) & blueDistributionAccessory;
figure; 
imagesc(merged3); colormap(gray); axis image;
title("Red & Green & Blue accessory");