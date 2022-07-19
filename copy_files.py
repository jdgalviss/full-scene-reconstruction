import numpy as np
import shutil
import os
from pathlib import Path
from tqdm import tqdm


resources_path = 'panoptic-reconstruction/resources/front3d/train_list_3d.txt'
new_resources_path = 'panoptic-reconstruction/resources/front3d/train_list_3d_new.txt'

data_path = '/media/jdgalviss/JDG/TUM/front3d-full/front3d-full/'
new_data_path = 'front-3d/'
resources = open(resources_path, 'r').readlines()

total_length = len(resources)
new_lines=[]
for idx, sample in tqdm(enumerate(resources), total=total_length):

    if idx%4 == 0:
        scene_id = sample.split('/')[0]
        id = sample.split('/')[1].replace('\n', '')
        # read viewlist
        # print(data_path + scene_id + f"/viewlist_{id}.txt")
        try:
            viewlist = open(data_path + scene_id + f"/viewlist_{id}.txt", 'r')
            viewlist_length = len(viewlist.readlines())
        except:
            continue
        if viewlist_length > 2:
            new_lines.append(sample.replace('\n', ''))
            output_path = Path(new_data_path + scene_id)
            output_path.mkdir(exist_ok=True, parents=True)
            #camposes
            file_orig = data_path + scene_id + f"/campose_{id}.npz"
            file_dest = new_data_path + scene_id + f"/campose_{id}.npz"
            shutil.copyfile(file_orig,file_dest)

            #depth
            file_orig = data_path + scene_id + f"/depth_{id}.exr"
            file_dest = new_data_path + scene_id + f"/depth_{id}.exr"
            shutil.copyfile(file_orig,file_dest)

            #geometry
            file_orig = data_path + scene_id + f"/geometry_{id}.npz"
            file_dest = new_data_path + scene_id + f"/geometry_{id}.npz"
            shutil.copyfile(file_orig,file_dest)

            #rgb
            file_orig = data_path + scene_id + f"/rgb_{id}.png"
            file_dest = new_data_path + scene_id + f"/rgb_{id}.png"
            shutil.copyfile(file_orig,file_dest)

            #segmentation
            file_orig = data_path + scene_id + f"/segmentation_{id}.mapped.npz"
            file_dest = new_data_path + scene_id + f"/segmentation_{id}.mapped.npz"
            shutil.copyfile(file_orig,file_dest)

            #viewlist
            file_orig = data_path + scene_id + f"/viewlist_{id}.txt"
            file_dest = new_data_path + scene_id + f"/viewlist_{id}.txt"
            shutil.copyfile(file_orig,file_dest)

            #weighting
            file_orig = data_path + scene_id + f"/weighting_{id}.npz"
            file_dest = new_data_path + scene_id + f"/weighting_{id}.npz"
            shutil.copyfile(file_orig,file_dest)

with open(new_resources_path, 'w') as fp:
    fp.write('\n'.join(new_lines))

