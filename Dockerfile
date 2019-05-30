ARG CPU_OR_GPU
ARG AWS_REGION
FROM 520713654638.dkr.ecr.${AWS_REGION}.amazonaws.com/sagemaker-rl-tensorflow:ray0.5.3-${CPU_OR_GPU}-py3

WORKDIR /opt/ml

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3.6-dev \
    && ln -s -f /usr/bin/python3.6 /usr/bin/python \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN curl -fSsL -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip install --upgrade \
    pip \
    setuptools

RUN pip install sagemaker-containers --upgrade

# JSBSIM

RUN curl -L https://github.com/JSBSim-Team/jsbsim/archive/JSBSim-trusty-v2018a.tar.gz && \
    tar xz JSBSim-trusty-v2018a.tar.gz && \
    cd jsbsim-JSBSim-trusty-v2018a && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_CXX_FLAGS_RELEASE="-O3 -march=native -mtune=native" -DCMAKE_C_FLAGS_RELEASE="-O3 -march=native -mtune=native" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DINSTALL_PYTHON_MODULE=ON && \
    make install

RUN git config --global http.sslverify false
RUN pip3 install git+https://github.com/galleon/gym-jsbsim.git@v0.4.2

ENV PYTHONUNBUFFERED 1

############################################
# Test Installation
############################################
# Test to verify if all required dependencies installed successfully or not.
RUN python -c "import gym; import sagemaker_containers.cli.train; import roboschool; import ray; from sagemaker_containers.cli.train import main"

# Make things a bit easier to debug
WORKDIR /opt/ml/code
