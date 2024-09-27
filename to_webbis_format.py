# {
#   "id": "000001",
#   "height": 2449,
#   "width": 1366,
#   "segmentations": {
#     "majority-vote": [
#       [
#         [
#           [
#             [85, 0],
#             [43, 0],
#             [43, 48],
#             [43, 96],
#             [218, 96],
#             [1323, 96],
#             [1323, 48],
#             [1323, 0],
#             [85, 0]
#           ]
#         ]
#       ],

import os
import json
import cv2
import numpy as np


screenshots_dir = 'C:/Users/minhh/Downloads/webis-webseg-20-selected (1)'
results_dir = 'c:/Users/minhh/Downloads/sam-results-20240926T222517Z-001/sam-results'
results_files = sorted([file for file in os.listdir(results_dir) if file.endswith('.npy')])
webis_results_dir = 'webis_results'
if not os.path.exists(webis_results_dir):
    os.makedirs(webis_results_dir)
    
print(results_files)
ids = []
for file in results_files:
    print(file)
    number = file.split('-')[0]
    res = np.load(os.path.join(results_dir, file), allow_pickle=True)
    size = res.item()['size']
    masks = res.item()['masks']
    print(size)
    print(masks[0])
    
    img = cv2.imread(os.path.join(screenshots_dir, number, 'screenshot.png'))
    org_size = img.shape[:2]
    # for each bbox in masks, resize the bbox to the original size
    webis_result = {
        'id': number,
        'height': org_size[0],
        'width': org_size[1],
        'segmentations': {
            'sam': []
        }
    }
    polygons = []
    for mask in masks:
        bbox = mask['bbox']
        scale_x = org_size[1] / size[1]
        scale_y = org_size[0] / size[0]
        bbox[0] *= scale_x
        bbox[1] *= scale_y
        bbox[2] *= scale_x
        bbox[3] *= scale_y
        bbox = [int(x) for x in bbox]
        
        # format it as a list of points forming a polygon, with the first and last points being the same
        # [[x1, y1], [x2, y2], ..., [x1, y1]]
        polygon = [[[[bbox[0], bbox[1]], [bbox[0] + bbox[2], bbox[1]], [bbox[0] + bbox[2], bbox[1] + bbox[3]], [bbox[0], bbox[1] + bbox[3]], [bbox[0], bbox[1]]]]]
        polygons.append(polygon)
        
    webis_result['segmentations']['sam'] = polygons
    
    with open(os.path.join(webis_results_dir, f'{number}.json'), 'w') as f:
        json.dump(webis_result, f, indent=2)
        
    ids.append(number)
    
with open("ids.json", "w") as f:
    json.dump(ids, f)
    

    