# Multi-stage Dockerfile for slim Sage
# https://docs.docker.com/build/building/multi-stage

FROM ghcr.io/sagemath/sage/sage-ubuntu-focal-standard-with-targets:latest AS target

# Resolve symbolic links to recreate them later
RUN readlink /sage/prefix >> /sage/prefix_link
RUN readlink /sage/venv >> /sage/venv_link

# To exclude doc directory in the next stage
RUN rm -rf /sage/local/share/doc

FROM ghcr.io/sagemath/sage/sage-ubuntu-focal-standard-with-system-packages:latest

USER root

# Remove warnings
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"

# Install JupyterLab to the system
RUN apt-get update
RUN apt-get install -y python3-pip
RUN python3 -m pip install --no-warn-script-location notebook jupyterlab ipywidgets

# Disable annoying pupup for Jupyter news
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

# Install /sage from target
COPY --from=target /sage/src/bin /sage/src/bin
COPY --from=target /sage/src/sage /sage/src/sage
COPY --from=target /sage/local/bin /sage/local/bin
COPY --from=target /sage/local/etc /sage/local/etc
COPY --from=target /sage/local/include /sage/local/include
COPY --from=target /sage/local/lib /sage/local/lib
COPY --from=target /sage/local/libexec /sage/local/libexec
COPY --from=target /sage/local/share /sage/local/share
COPY --from=target /sage/local/var /sage/local/var
RUN cd /sage/local && ln -s lib lib64
COPY --from=target /sage/sage /sage/sage
COPY --from=target /sage/pkgs/sage-conf /sage/pkgs/sage-conf

# Recreate symbolic links
COPY --from=target /sage/prefix_link /sage/prefix_link
COPY --from=target /sage/venv_link /sage/venv_link
RUN ln -s $(cat /sage/prefix_link) /sage/prefix && rm /sage/prefix_link
RUN ln -s $(cat /sage/venv_link) /sage/venv && rm /sage/venv_link

# Configure Sage library
RUN /sage/sage -pip install --root-user-action=ignore /sage/pkgs/sage-conf

# Remove problematic lines!
RUN sed -i '/^__requires__/d' /sage/venv/bin/sage-venv-config
RUN sed -i '/^__import__/d' /sage/venv/bin/sage-venv-config
