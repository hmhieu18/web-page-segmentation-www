# read npy file to a dictionary
import numpy as np
import os
import json
import cv2

def show_anns(anns, image):
    if len(anns) == 0:
        return
    sorted_anns = sorted(anns, key=(lambda x: x['area']), reverse=True)

    for ann in sorted_anns:
        bbox = ann['bbox']
        conf = ann['stability_score']
        # draw bbox on image
        rect = cv2.rectangle(image, (int(bbox[0]), int(bbox[1])), (int(bbox[0] + bbox[2]), int(bbox[1] + bbox[3])), (0, 255, 0), 2)
        text = '{:.1f}'.format(conf)
        cv2.putText(rect, text, (int(bbox[0]), int(bbox[1]) + 15), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    return image

def load_masks(mask_path):
    mask = np.load(mask_path, allow_pickle=True)
    with open('class_dict.json', 'w') as f:
        json.dump(mask.item(), f)
    return mask.item()

# print(load_masks('000080-masks.npy'))
# result = load_masks('000080-masks.npy')

# size = result['size']
# masks = result['masks']

# screenshot = 'screenshot.png'
# image = cv2.imread(screenshot)
# image = cv2.resize(image, (size[1], size[0]))

# image = show_anns(masks, image)
# cv2.imwrite('output.png', image)

# c:\Users\minhh\Downloads\sam-results-20240926T222517Z-001\sam-results contains all the npy files, 
# extract the number of the file
# C:\Users\minhh\Downloads\webis-webseg-20-selected (1)\{number}\screenshot.png

results_dir = 'c:/Users/minhh/Downloads/sam-results-20240926T222517Z-001/sam-results'
screenshots_dir = 'C:/Users/minhh/Downloads/webis-webseg-20-selected (1)'
output_dir = 'output'
if not os.path.exists(output_dir):
    os.makedirs(output_dir)
    
for file in os.listdir(results_dir):
    if file.endswith('.npy'):
        print(file)
        number = file.split('-')[0]
        mask = load_masks(os.path.join(results_dir, file))
        size = mask['size']
        masks = mask['masks']
        
        screenshot = os.path.join(screenshots_dir, number, 'screenshot.png')
        image = cv2.imread(screenshot)
        image = cv2.resize(image, (size[1], size[0]))
        
        image = show_anns(masks, image)
        cv2.imwrite(os.path.join(output_dir, number + '.png'), image)
    

