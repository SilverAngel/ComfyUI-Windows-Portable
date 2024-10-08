#!/bin/bash
set -eux

gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

workdir=$(pwd)

export PYTHONPYCACHEPREFIX="$workdir"/pycache

ls -lahF

mkdir -p "$workdir"/ComfyUI_Windows_portable

# ComfyUI main app
$gcs https://github.com/comfyanonymous/ComfyUI.git \
    "$workdir"/ComfyUI_Windows_portable/ComfyUI

# TAESD model for image on-the-fly preview
$gcs https://github.com/madebyollin/taesd.git
cp taesd/*.pth \
    "$workdir"/ComfyUI_Windows_portable/ComfyUI/models/vae_approx/
rm -rf taesd

# CUSTOM NODES
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes
$gcs https://github.com/ltdrdata/ComfyUI-Manager.git

# Workspace

# General
$gcs https://github.com/cubiq/ComfyUI_essentials.git
$gcs https://github.com/jags111/efficiency-nodes-comfyui.git
$gcs https://github.com/kijai/ComfyUI-KJNodes.git
$gcs https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
$gcs https://github.com/rgthree/rgthree-comfy.git
$gcs https://github.com/shiimizu/ComfyUI_smZNodes.git
$gcs https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git
$gcs https://github.com/crystian/ComfyUI-Crystools
$gcs https://github.com/alexopus/ComfyUI-Image-Saver


# Control
$gcs https://github.com/cubiq/ComfyUI_InstantID.git
$gcs https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
$gcs https://github.com/Fannovel16/comfyui_controlnet_aux.git
$gcs https://github.com/Gourieff/comfyui-reactor-node.git
$gcs https://github.com/huchenlei/ComfyUI-layerdiffuse.git
$gcs https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
$gcs https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git
$gcs https://github.com/mcmonkeyprojects/sd-dynamic-thresholding.git
$gcs https://github.com/storyicon/comfyui_segment_anything.git
$gcs https://github.com/twri/sdxl_prompt_styler.git

# More
$gcs https://github.com/cubiq/ComfyUI_FaceAnalysis.git
$gcs https://github.com/MrForExample/ComfyUI-3D-Pack.git
$gcs https://github.com/WASasquatch/was-node-suite-comfyui.git


cd "$workdir"
mv  python_embeded  ComfyUI_Windows_portable/python_embeded

cd "$workdir"/ComfyUI_Windows_portable
mkdir update
cp -r ComfyUI/.ci/update_windows/* ./update/
cp -r ComfyUI/.ci/windows_base_files/* ./

# Setup Python embeded, part 3/3
sed -i '1irem .\\python_embeded\\python.exe -s ComfyUI\\main.py --windows-standalone-build --disable-auto-launch' ./run_nvidia_gpu.bat
sed -i '1irem set PYTHONPYCACHEPREFIX=.\\pycache' ./run_nvidia_gpu.bat
sed -i '1irem set HTTPS_PROXY=http://localhost:1081' ./run_nvidia_gpu.bat
sed -i '1irem set HTTP_PROXY=http://localhost:1081' ./run_nvidia_gpu.bat
sed -i '1irem set PATH=%PATH%;C:\\EDIT_THIS_TO_PATH_TO_YOUR_\\python_embeded\\Scripts\\' ./run_nvidia_gpu.bat

du -hd1 "$workdir"

# Download models for ReActor
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/models
curl -L https://github.com/sczhou/CodeFormer/releases/download/v0.1.0/codeformer.pth \
    --create-dirs -o facerestore_models/codeformer-v0.1.0.pth
curl -L https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth \
    --create-dirs -o facerestore_models/GFPGANv1.4.pth
curl -L https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128_fp16.onnx \
    --create-dirs -o insightface/inswapper_128_fp16.onnx

# Run test, also let custom nodes download some models
cd "$workdir"/ComfyUI_Windows_portable
./python_embeded/python.exe -s -B ComfyUI/main.py --quick-test-for-ci --cpu

# Clean up
rm "$workdir"/ComfyUI_Windows_portable/*.log
# DO NOT clean pymatting cache, they are nbi/nbc files for Numba, and won't be regenerated.
#rm -rf "$workdir"/ComfyUI_Windows_portable/python_embeded/Lib/site-packages/pymatting

cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes
rm ./was-node-suite-comfyui/was_suite_config.json
rm ./ComfyUI-Manager/config.ini
rm ./ComfyUI-Impact-Pack/impact-pack.ini
rm ./ComfyUI-Custom-Scripts/pysssss.json

cd "$workdir"

ls -lahF
