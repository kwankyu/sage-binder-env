# Dockerfile for binder
# Reference: https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html

# Pull the Sage docker image
FROM ghcr.io/sagemath/sage/sage-ubuntu-focal-standard-with-targets:dev AS target

# Resolve symbolic links to recreate them later
RUN readlink /sage/prefix >> /sage/prefix_link
RUN readlink /sage/venv >> /sage/venv_link

FROM ghcr.io/sagemath/sage/sage-ubuntu-focal-standard-with-system-packages:dev

USER root

# These lines are here to remove warnings
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"

# Install jupyterlab to the system
RUN apt-get install -y python3-pip
RUN python3 -m pip install --no-warn-script-location jupyterlab
RUN python3 -m pip install --no-warn-script-location ipywidgets

# Disable annoying pupup for Jupyter news
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

# Install /sage
COPY --from=target /sage/src/bin /sage/src/bin
COPY --from=target /sage/src/sage /sage/src/sage
COPY --from=target /sage/local /sage/local
COPY --from=target /sage/sage /sage/sage
COPY --from=target /sage/pkgs/sage-conf /sage/pkgs/sage-conf

# Recreate symbolic links
COPY --from=target /sage/prefix_link /sage/prefix_link
COPY --from=target /sage/venv_link /sage/venv_link
RUN ln -s $(cat /sage/prefix_link) /sage/prefix && rm /sage/prefix_link
RUN ln -s $(cat /sage/venv_link) /sage/venv && rm /sage/venv_link

# Remove built doc
RUN rm -R /sage/local/share/doc

# Configure Sage library
RUN /sage/sage -pip install --root-user-action=ignore /sage/pkgs/sage-conf

# Remove problematic two lines!
RUN sed -i '/^__requires__/d' /sage/venv/bin/sage-venv-config
RUN sed -i '/^__import__/d' /sage/venv/bin/sage-venv-config

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
