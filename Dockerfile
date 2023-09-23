# Dockerfile for binder
# Reference: https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html

# Pull the Sage docker image
FROM ghcr.io/sagemath/sage-binder-env:master

USER root

# Create user "alice" whose uid is 1000
ARG NB_USER=alice
ARG NB_UID=1000
ENV NB_USER alice
ENV NB_UID 1000
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

# Make sure the contents of the notebooks directory are in ${HOME}
COPY notebooks/* ${HOME}/
RUN chown -R ${NB_USER}:${NB_USER} ${HOME}

# Install Sage package
# RUN /sage/sage -i <spkg-name>

# Switch to the user
USER ${NB_USER}

# Install sagemath kernel
RUN mkdir -p $(jupyter --data-dir)/kernels
RUN ln -s /sage/venv/share/jupyter/kernels/sagemath $(jupyter --data-dir)/kernels

# Start in the home directory of the user
WORKDIR /home/${NB_USER}
