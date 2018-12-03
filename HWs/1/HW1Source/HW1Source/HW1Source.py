import cv2
import numpy as np
from scipy import ndimage
import matplotlib.pyplot as plt
from skimage import measure

# Question 1
def dilation(image, kernel):
	kernel_x, kernel_y = kernel.shape
	kernel_center_x, kernel_center_y = int(kernel_x / 2), int(kernel_y / 2) # index, not width
	image_x, image_y = image.shape
	output = np.zeros((image_x, image_y))

	kernel_points = [(x - kernel_center_x, y - kernel_center_y) for x in range(kernel_x) for y in range(kernel_y) if kernel[x][y] == 255]

	for i in range(image_x):
		for j in range(image_y):
			if image[i][j] > 0:
				output[i][j] = 255
				for k in range(len(kernel_points)):
					kpkx, kpky = kernel_points[k][0], kernel_points[k][1]
					if (0 <= i + kpkx and i + kpkx < image_x) and (0 <= j + kpky and j + kpky < image_y):
						output[i + kpkx][j + kpky] = 255
	return output

def erosion(image, kernel):
	kernel_x, kernel_y = kernel.shape
	kernel_center_x, kernel_center_y = int(kernel_x / 2), int(kernel_y / 2) # index, not width
	image_x, image_y = image.shape
	output = np.zeros((image_x, image_y))

	kernel_points = [(x - kernel_center_x, y - kernel_center_y) for x in range(kernel_x) for y in range(kernel_y) if kernel[x][y] == 255]

	for i in range(image_x):
		for j in range(image_y):
				flag = True
				for k in range(len(kernel_points)):
					kpkx, kpky = kernel_points[k][0], kernel_points[k][1]
					if (0 <= i + kpkx and i + kpkx < image_x) and (0 <= j + kpky and j + kpky < image_y):
						if image[i + kpkx][j + kpky] != 255:
							flag = False
							break
				if flag == True:
					output[i][j] = 255
	return output

# Question 2
sonnet_orig = cv2.imread("../../Data/sonnet.png", 0)
sonnet = cv2.adaptiveThreshold(sonnet_orig, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 4)

tmp = erosion(sonnet, np.full((1, 25), 255))
tmp = erosion(tmp, np.full((1, 11), 255))
tmp = dilation(tmp, np.full((5, 1), 255))
tmp = erosion(tmp, np.full((13, 1), 255))

i, j = tmp.shape
for x in range(i):
	for y in range(j):
		tmp[x][y] = 0 if sonnet[x][y] == 0 and tmp[x][y] == 0 else 255

# Uncomment the following two lines to see the output image
cv2.imshow("image", tmp)
cv2.waitKey(0)

# Question 3
graveyard_orig = cv2.imread("../../Data/airplane_graveyard.jpg")
b,g,r = cv2.split(graveyard_orig)
ret, graveyard = cv2.threshold(b, 225, 255, cv2.THRESH_BINARY)
tmp = graveyard
tmp = erosion(tmp, np.full((1,2), 255))
tmp = dilation(tmp, np.full((1, 2), 255))
tmp = erosion(tmp, np.full((2,1), 255))
tmp = dilation(tmp, np.full((2, 1), 255))

tmp = dilation(tmp, np.full((10, 10), 255))

x, y = tmp.shape
for i in range(x):
	for j in range(y):
		tmp[i][j] = 255 if graveyard[i][j] == 255 and  tmp[i][j] == 255 else 0

# source for connected components: 
# https://stackoverflow.com/questions/46441893/connected-component-labeling-in-python
tmp = np.array(tmp, dtype=np.uint8)
lret, labels = cv2.connectedComponents(tmp)
label_hue = np.uint8(179*labels/np.max(labels))
blank_ch = 255*np.ones_like(label_hue)
labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
labeled_img[label_hue==0] = 0

cv2.imshow('image', labeled_img)
cv2.waitKey()

# Question 4
# Part 1: Train Station
# Frame 2
station_background = cv2.imread("../../Data/station/0.png")
station_1 = cv2.imread("../../Data/station/1.png")

station_background_gray = cv2.cvtColor(station_background, cv2.COLOR_BGR2GRAY)
station_1_gray = cv2.cvtColor(station_1, cv2.COLOR_BGR2GRAY)
diff_1 = station_1_gray - station_background_gray
ret, tmp = cv2.threshold(diff_1, 80, 255, cv2.THRESH_BINARY)

tmp = erosion(tmp, np.array([[0, 255, 0], [255, 255, 255], [0, 255, 0]]))
tmp = erosion(tmp, np.full((11, 11), 255))
tmp = dilation(tmp, np.full((11, 11), 255))
save = tmp
tmp = erosion(tmp, np.full((50, 50), 255))
tmp = dilation(tmp, np.full((250, 200), 255))
tmp = save - tmp
tmp = dilation(tmp, np.full((241, 29), 255))

x, y = tmp.shape
for i in range(x):
	for j in range(y):
		tmp[i][j] = 255 if tmp[i][j] == 255 and save[i][j] == 255 else 0

tmp = np.array(tmp, dtype=np.uint8)
lret, labels = cv2.connectedComponents(tmp)
label_hue = np.uint8(179*labels/np.max(labels))
blank_ch = 255*np.ones_like(label_hue)
labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
labeled_img[label_hue==0] = 0

cv2.imshow('image', labeled_img)
cv2.waitKey()

# Frame 3
station_background = cv2.imread("../../Data/station/0.png")
station_2 = cv2.imread("../../Data/station/2.png")
station_background_gray = cv2.cvtColor(station_background, cv2.COLOR_BGR2GRAY)
station_2_gray = cv2.cvtColor(station_2, cv2.COLOR_BGR2GRAY)
diff_2 = station_2_gray - station_background_gray
ret, tmp = cv2.threshold(diff_2, 50, 255, cv2.THRESH_BINARY)

tmp = erosion(tmp, np.array([[0, 255, 0], [255, 255, 255], [0, 255, 0]]))
tmp = dilation(tmp, np.array([[0, 255, 0], [255, 255, 255], [0, 255, 0]]))
tmp = erosion(tmp, np.full((9, 9), 255))
tmp = dilation(tmp, np.full((25, 9), 255))

save = tmp

tmp = erosion(tmp, np.full((1, 55), 255))
tmp = dilation(tmp, np.full((1, 75), 255))

x, y = tmp.shape
for i in range(x):
	for j in range(y):
		tmp[i][j] = 255 if tmp[i][j] == 0 and save[i][j] == 255 else 0

tmp = erosion(tmp, np.full((13, 23), 255))
tmp = dilation(tmp, np.full((71, 41), 255))

x, y = tmp.shape
for i in range(x):
	for j in range(y):
		tmp[i][j] = 255 if tmp[i][j] == 255 and save[i][j] == 255 else 0

tmp = dilation(tmp, np.full((25, 1), 255))
tmp = erosion(tmp, np.full((1, 5), 255))

tmp = np.array(tmp, dtype=np.uint8)
lret, labels = cv2.connectedComponents(tmp)
label_hue = np.uint8(179*labels/np.max(labels))
blank_ch = 255*np.ones_like(label_hue)
labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
labeled_img[label_hue==0] = 0

cv2.imshow('image', labeled_img)
cv2.waitKey()

# Frame 4
station_background = cv2.imread("../../Data/station/0.png")
station_3 = cv2.imread("../../Data/station/3.png")
station_background_gray = cv2.cvtColor(station_background, cv2.COLOR_BGR2GRAY)
station_3_gray = cv2.cvtColor(station_3, cv2.COLOR_BGR2GRAY)
diff_3 = station_3_gray - station_background_gray

ret, tmp = cv2.threshold(diff_3, 220, 255, cv2.THRESH_BINARY_INV)
save = tmp
tmp = erosion(tmp, np.full((9,1),255))
tmp = dilation(tmp, np.full((9,1), 255))
tmp = erosion(tmp, np.full((5,5),255))
tmp = dilation(tmp, np.full((11,1), 255))
tmp = dilation(tmp, np.full((1,11), 255))

x, y = tmp.shape
for i in range(x):
	for j in range(y):
		tmp[i][j] = 255 if tmp[i][j] == 255 and save[i][j] == 255 else 0

save2 = tmp
tmp = erosion(tmp, np.full((93,43), 255))
tmp = dilation(tmp, np.full((701,151), 255))
tmp = dilation(tmp, np.full((25,25), 255))

x, y = tmp.shape
for i in range(x):
	for j in range(y):
		tmp[i][j] = 255 if tmp[i][j] == 255 and save2[i][j] == 255 else 0

tmp = erosion(tmp, np.full((5,5), 255))
tmp = dilation(tmp, np.full((5,5), 255))

tmp = np.array(tmp, dtype=np.uint8)
lret, labels = cv2.connectedComponents(tmp)
label_hue = np.uint8(179*labels/np.max(labels))
blank_ch = 255*np.ones_like(label_hue)
labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
labeled_img[label_hue==0] = 0

cv2.imshow('image', labeled_img)
cv2.waitKey()

# Question 4
# Part 2: Photocopy Machine
# Frame 2
photocopy_background = cv2.imread("../../Data/copyMachine/0.png")
copy_1 = cv2.imread("../../Data/copyMachine/1.png")

photocopy_background_gray = cv2.cvtColor(photocopy_background, cv2.COLOR_BGR2GRAY)
copy_1_gray = cv2.cvtColor(copy_1, cv2.COLOR_BGR2GRAY)
diff_1 = copy_1_gray - photocopy_background_gray
ret, tmp = cv2.threshold(diff_1, 200, 255, cv2.THRESH_BINARY_INV)

tmp = erosion(tmp, np.full((5, 1), 255))
tmp = erosion(tmp, np.full((1, 3), 255))

tmp = np.array(tmp, dtype=np.uint8)
lret, labels = cv2.connectedComponents(tmp)
label_hue = np.uint8(179*labels/np.max(labels))
blank_ch = 255*np.ones_like(label_hue)
labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
labeled_img[label_hue==0] = 0

cv2.imshow('image', labeled_img)
cv2.waitKey()

# Frame 3
photocopy_background = cv2.imread("../../Data/copyMachine/0.png")
copy_2 = cv2.imread("../../Data/copyMachine/2.png")

photocopy_background_gray = cv2.cvtColor(photocopy_background, cv2.COLOR_BGR2GRAY)
copy_2_gray = cv2.cvtColor(copy_2, cv2.COLOR_BGR2GRAY)
diff_2 = copy_2_gray - photocopy_background_gray
ret, tmp = cv2.threshold(diff_2, 200, 255, cv2.THRESH_BINARY_INV)

tmp = erosion(tmp, np.full((3,3), 255))
save = tmp

tmp = erosion(tmp, np.full((15,15), 255))
tmp = dilation(tmp, np.full((100, 50), 255))
tmp = erosion(tmp, np.full((15,15), 255))
tmp = dilation(tmp, np.full((15, 15), 255))

x, y = tmp.shape
for i in range(x):
	for j in range(y):
		tmp[i][j] = 255 if tmp[i][j] == 255 and save[i][j] == 255 else 0

tmp = dilation(tmp, np.full((11, 5), 255))

tmp = np.array(tmp, dtype=np.uint8)
lret, labels = cv2.connectedComponents(tmp)
label_hue = np.uint8(179*labels/np.max(labels))
blank_ch = 255*np.ones_like(label_hue)
labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
labeled_img[label_hue==0] = 0

cv2.imshow('image', labeled_img)
cv2.waitKey()

# Frame 4
photocopy_background = cv2.imread("../../Data/copyMachine/0.png")
copy_3 = cv2.imread("../../Data/copyMachine/3.png")

photocopy_background_gray = cv2.cvtColor(photocopy_background, cv2.COLOR_BGR2GRAY)
copy_3_gray = cv2.cvtColor(copy_3, cv2.COLOR_BGR2GRAY)
diff_3 = copy_3_gray - photocopy_background_gray
ret, tmp = cv2.threshold(diff_3, 220, 255, cv2.THRESH_BINARY_INV)

save = tmp

tmp = dilation(tmp, np.full((3,3), 255))
tmp = erosion(tmp, np.full((3,3), 255))

x, y = tmp.shape
for i in range(x):
	for j in range(y):
		tmp[i][j] = 255 if tmp[i][j] == 255 and save[i][j] == 255 else 0

tmp = erosion(tmp, np.full((5,5), 255))

tmp = np.array(tmp, dtype=np.uint8)
lret, labels = cv2.connectedComponents(tmp)
label_hue = np.uint8(179*labels/np.max(labels))
blank_ch = 255*np.ones_like(label_hue)
labeled_img = cv2.merge([label_hue, blank_ch, blank_ch])
labeled_img = cv2.cvtColor(labeled_img, cv2.COLOR_HSV2BGR)
labeled_img[label_hue==0] = 0

cv2.imshow('image', labeled_img)
cv2.waitKey()