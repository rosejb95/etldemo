ARG UBUNTU_VERSION=22.04

FROM ubuntu:$UBUNTU_VERSION

# Need to reuse UBUNTU_VERSION so we still have access for the SQL Server tool install later.
ARG UBUNTU_VERSION
ARG PYTHON_VERSION=3.10
ARG NB_USER=dev
# TODO: use Azure CLI with key vault to set the pass to something actually private.
ARG PASSWORD=pass
ARG NB_UID="1000"
ARG NB_GID="100"


RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - bzip2 is necessary to extract the micromamba executable.
    bzip2 \
    ca-certificates \
    fonts-liberation \
    locales \
    # - pandoc is used to convert notebooks to html files
    #   it's not present in aarch64 ubuntu image, so we install it here
    pandoc \
    # - run-one - a wrapper script that runs no more
    #   than one unique  instance  of  some  command with a unique set of arguments,
    #   we use `run-one-constantly` to support `RESTARTABLE` option
    openssh-server \
    sudo \
    gnupg \
    git \
    sudo \
    curl \
    openssh-server \
    apt-transport-https \
    lsb-release \
    libicu-dev \
    build-essential \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen


# # Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#   Install appropriate release based on ubuntu version
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools18

# install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


# install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm ./get_helm.sh

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Use this to fix the user path later.
ENV PATH="${CONDA_DIR}/bin:${PATH}:/opt/mssql-tools18/bin" \
    HOME="/home/${NB_USER}"


# TODO: remove
# Copy a script that we will use to correct permissions after running certain commands
# COPY fix-permissions /usr/local/bin/fix-permissions
# RUN chmod a+rx /usr/local/bin/fix-permissions

# Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -l -m -s /bin/bash -N -u "${NB_UID}" "${NB_USER}" -g root -G sudo && \
    mkdir -p "${CONDA_DIR}" && \
    chown "${NB_USER}:${NB_GID}" "${CONDA_DIR}"

# TODO: remove this after we get SSH key auth working consistently.
RUN  echo "$NB_USER:$PASSWORD" | chpasswd

USER ${NB_UID}



# setup initial condarc
COPY --chown="${NB_UID}:${NB_GID}" initial-condarc "${CONDA_DIR}/.condarc"

# Adding sql tools and conda to the user path.
RUN echo export PATH=$PATH >> ${HOME}/.bashrc

WORKDIR /tmp

# specify most installs
COPY environment.yml /tmp/environment.yml

RUN set -x && \
arch=$(uname -m) && \
if [ "${arch}" = "x86_64" ]; then \
    # Should be simpler, see <https://github.com/mamba-org/mamba/issues/1437>
    arch="64"; \
fi && \
wget -qO /tmp/micromamba.tar.bz2 \
    "https://micromamba.snakepit.net/api/micromamba/linux-${arch}/latest" && \
tar -xvjf /tmp/micromamba.tar.bz2 --strip-components=1 bin/micromamba && \
rm /tmp/micromamba.tar.bz2 && \
PYTHON_SPECIFIER="python=${PYTHON_VERSION}" && \
if [[ "${PYTHON_VERSION}" == "default" ]]; then PYTHON_SPECIFIER="python"; fi && \
#     # Install the packages. 
./micromamba install \
    --root-prefix="${CONDA_DIR}" \
    --prefix="${CONDA_DIR}" \
    --yes \
    --file environment.yml 
# Might not need this cleanup.
    # && \
# rm micromamba && \
# # Pin major.minor version of python
# mamba list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
# jupyter notebook --generate-config && \
# mamba clean --all -f -y && \
# npm cache clean --force && \
# jupyter lab clean && \
# rm -rf "/home/${NB_USER}/.cache/yarn"pip

RUN pip install dbt-core dbt-sqlserver
RUN eval "$(conda shell.bash hook)"

WORKDIR "${HOME}"

USER root

# TODO: remove this RUN cmd. This should be passed when spinning up containers as needed instead.
RUN service ssh start
CMD ["/usr/sbin/sshd","-D"]
# ENTRYPOINT [ "/bin/bash" ]

# May or may not want to expose port 22.
# EXPOSE 22/tcp

WORKDIR "${HOME}"