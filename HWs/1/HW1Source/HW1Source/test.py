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


# Question 4
# Part 2: Photocopy Machine
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