#!/bin/bash
set -eux

gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

workdir=$(pwd)

# Setup Python embeded

curl https://www.python.org/ftp/python/3.11.8/python-3.11.8-embed-amd64.zip \
    -o python_embeded.zip
unzip python_embeded.zip -d "$workdir"/python_embeded

cd "$workdir"/python_embeded
echo 'import site' >> ./python311._pth
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
./python.exe get-pip.py

# PIP install
./python.exe -s -m pip install \
    --upgrade pip wheel setuptools Cython numpy

./python.exe -s -m pip install \
    xformers torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121 \
    --extra-index-url https://pypi.org/simple

./python.exe -s -m pip install \
    -r "$workdir"/requirements.txt

./python.exe -s -m pip install \
    -r "$workdir"/requirements2.txt

./python.exe -s -m pip install \
    --force-reinstall onnxruntime-gpu \
    --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/ \
    --extra-index-url https://pypi.org/simple \
&& ./python.exe -s -m pip install \
    mediapipe

# Deps for ComfyUI-3D-Pack

$gcs https://github.com/MrForExample/ComfyUI-3D-Pack.git \
    "$workdir"/ComfyUI-3D-Pack

./python.exe -s -m pip install \
    "$workdir"/ComfyUI-3D-Pack/_Pre_Builds/_Wheels_win_py311_cu121/*.whl

cp -rf \
    "$workdir"/ComfyUI-3D-Pack/_Pre_Builds/_Python311_cpp/include \
    "$workdir"/python_embeded/include

cp -rf \
    "$workdir"/ComfyUI-3D-Pack/_Pre_Builds/_Python311_cpp/libs \
    "$workdir"/python_embeded/libs

rm -rf "$workdir"/ComfyUI-3D-Pack

# Finishing
sed -i '1i../ComfyUI' ./python311._pth

cd "$workdir"

du -hd1 "$workdir"
