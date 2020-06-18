# Based on Eiffl's nersc-python-mpi docker image
#    https://hub.docker.com/r/eiffl/nersc-python-mpi/dockerfile

FROM ubuntu as base
MAINTAINER dhna

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        git python3 python3-pip python3-setuptools && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Make sure we are runnning python3 and pip3
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip


################################################################################
# Builder image - build python modules
################################################################################
FROM base as builder

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        make gcc g++ gfortran pkg-config python3-dev python3-pkgconfig && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Install MPICH and HDF5 development libraries
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        libmpich-dev libhdf5-mpich-dev && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Build mpi4py
RUN pip install --no-cache-dir mpi4py

# Build H5PY
RUN export CC=mpicc      ; \
    export HDF5_MPI="ON" ; \
    pip install --no-cache-dir --no-binary=h5py h5py

# Install other python modules
RUN pip install --no-cache-dir pandas six scipy numpy


################################################################################
# Final image - runtime libraries only
################################################################################
FROM base

# Copy built python modules
COPY --from=builder /usr/local/lib /usr/local/lib

# Install MPICH and HDF5 runtime libraries
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        mpich libhdf5-mpich-103 && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

RUN /sbin/ldconfig
