# Dockerfile for binder
# Reference: https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html

# Pull the Sage docker image
FROM ghcr.io/sagemath/sage/sage-ubuntu-focal-standard-with-targets:10.6

USER root

# These lines are here to remove warnings
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"

# Install jupyterlab to the system
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y python3-pip
RUN python3 -m pip install --no-warn-script-location jupyterlab

# Disable annoying pupup for Jupyter news
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

# Create user "alice" whose uid is 1000
ARG NB_USER=alice
ARG NB_UID=1000
ENV NB_USER alice
ENV NB_UID 1000
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

# Make sure the contents of the notebooks directory are in ${HOME}
COPY notebooks/* ${HOME}/
RUN chown -R ${NB_UID} ${HOME}

# Install jupyterlab to Sage
RUN /sage/sage -pip install --no-warn-script-location jupyterlab

# Install Sage package
# RUN /sage/sage -i <spkg-name>

# Switch to the user
USER ${NB_USER}

# This is where kernels are installed
RUN mkdir -p $(jupyter --data-dir)/kernels

# Install sagemath kernel
RUN ln -s /sage/venv/share/jupyter/kernels/sagemath $(jupyter --data-dir)/kernels

# Start in the home directory of the user
WORKDIR /home/${NB_USER}
