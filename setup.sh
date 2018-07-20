#! /bin/bash

set -x
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$SCRIPT_DIR" >/dev/null

#Parse command line arguments
downloadHighPolySuv=true
if [[ $1 == "--no-full-poly-car" ]]; then
    downloadHighPolySuv=false
fi


#download cmake - we need v3.9+ which is not out of box in Ubuntu 16.04
if [[ ! -d "cmake_build/bin" ]]; then
    echo "Downloading cmake..."
    wget https://cmake.org/files/v3.10/cmake-3.10.2.tar.gz \
        -O cmake.tar.gz
    tar -xzf cmake.tar.gz
    rm cmake.tar.gz
    rm -rf ./cmake_build
    mv ./cmake-3.10.2 ./cmake_build
    pushd cmake_build
    ./bootstrap
    make
    popd
fi

if [ "$(uname)" == "Darwin" ]; then
    CMAKE="$(greadlink -f cmake_build/bin/cmake)"
else
    CMAKE="$(readlink -f cmake_build/bin/cmake)"
fi

# Download rpclib
if [ ! -d "external/rpclib/rpclib-2.2.1" ]; then
    echo "*********************************************************************************************"
    echo "Downloading rpclib..."
    echo "*********************************************************************************************"

    wget  https://github.com/rpclib/rpclib/archive/v2.2.1.zip

    # remove previous versions
    rm -rf "external/rpclib"

    mkdir -p "external/rpclib"
    unzip v2.2.1.zip -d external/rpclib
    rm v2.2.1.zip
fi

# Download high-polycount SUV model
if [ ! -d "Unreal/Plugins/AirSim/Content/VehicleAdv" ]; then
    mkdir -p "Unreal/Plugins/AirSim/Content/VehicleAdv"
fi
if [ ! -d "Unreal/Plugins/AirSim/Content/VehicleAdv/SUV/v1.2.0" ]; then
    if $downloadHighPolySuv; then
        echo "*********************************************************************************************"
        echo "Downloading high-poly car assets.... The download is ~37MB and can take some time."
        echo "To install without this assets, re-run setup.sh with the argument --no-full-poly-car"
        echo "*********************************************************************************************"

        if [ -d "suv_download_tmp" ]; then
            rm -rf "suv_download_tmp"
        fi
        mkdir -p "suv_download_tmp"
        cd suv_download_tmp
        wget  https://github.com/Microsoft/AirSim/releases/download/v1.2.0/car_assets.zip
        if [ -d "../Unreal/Plugins/AirSim/Content/VehicleAdv/SUV" ]; then
            rm -rf "../Unreal/Plugins/AirSim/Content/VehicleAdv/SUV"
        fi
        unzip car_assets.zip -d ../Unreal/Plugins/AirSim/Content/VehicleAdv
        cd ..
        rm -rf "suv_download_tmp"
    else
        echo "Not downloading high-poly car asset. The default unreal vehicle will be used."
    fi
fi

#install EIGEN library

if [ "$(uname)" == "Darwin" ]; then
    rm -rf ./AirLib/deps/eigen3/Eigen
else
    rm -rf ./AirLib/deps/eigen3/Eigen
fi
echo "downloading eigen..."
wget http://bitbucket.org/eigen/eigen/get/3.3.2.zip
unzip 3.3.2.zip -d temp_eigen
mkdir -p AirLib/deps/eigen3
mv temp_eigen/eigen*/Eigen AirLib/deps/eigen3
rm -rf temp_eigen
rm 3.3.2.zip

popd >/dev/null

set +x
echo ""
echo "************************************"
echo "AirSim setup completed successfully!"
echo "************************************"
