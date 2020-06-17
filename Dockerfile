# Based on Eiffl's nersc-python-mpi docker image
#    https://hub.docker.com/r/eiffl/nersc-python-mpi/dockerfile

FROM ubuntu
MAINTAINER dhna

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        git make gcc g++ gfortran pkg-config \
        python3-pip python3-setuptools python3-dev python3-pkgconfig python3-six && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Make sure we are runnning python3 and pip3
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

# Install python packages
RUN pip --no-cache-dir install pandas scipy numpy

# Install MPICH
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        mpich libmpich-dev && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Build mpi4py
RUN pip --no-cache-dir install mpi4py

# Build HDF5
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        libhdf5-mpich-dev && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Build H5PY
RUN export CC=mpicc      ; \
    export HDF5_MPI="ON" ; \
    pip install --no-cache-dir --no-binary=h5py h5py

RUN /sbin/ldconfig

