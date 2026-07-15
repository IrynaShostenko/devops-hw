#!/usr/bin/env bash

# Зупинити скрипт, якщо:
# - команда завершилася помилкою
# - використана неоголошена змінна
# - сталася помилка в pipeline
set -euo pipefail

DJANGO_VENV="$HOME/.venvs/dev-tools"

echo "===== Installing DevOps tools ====="


# ---------- Docker ----------

echo
echo "Checking Docker..."

if docker --version >/dev/null 2>&1
then
    echo "Docker is already installed."
    docker --version
else
    echo "Installing Docker..."

    . /etc/os-release

    DISTRO_ID="${ID:-}"
    DOCKER_CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"

    if [[ "$DISTRO_ID" != "ubuntu" && "$DISTRO_ID" != "debian" ]]
    then
        echo "This script supports only Ubuntu and Debian."
        exit 1
    fi

    if [[ -z "$DOCKER_CODENAME" ]]
    then
        echo "Cannot detect distribution codename."
        exit 1
    fi

    sudo apt update
    sudo apt install -y ca-certificates curl

    sudo install -m 0755 -d /etc/apt/keyrings

    sudo curl -fsSL "https://download.docker.com/linux/$DISTRO_ID/gpg" \
        -o /etc/apt/keyrings/docker.asc

    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/$DISTRO_ID
Suites: $DOCKER_CODENAME
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt update

    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    echo "Docker has been installed."
    docker --version
fi


# ---------- Docker Compose ----------

echo
echo "Checking Docker Compose..."

if docker compose version >/dev/null 2>&1
then
    echo "Docker Compose is already installed."
    docker compose version
else
    echo "Installing Docker Compose..."

    sudo apt update
    sudo apt install -y docker-compose-plugin

    docker compose version
fi


# ---------- Python ----------

echo
echo "Checking Python..."

if command -v python3 >/dev/null 2>&1
then
    if python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 9) else 1)' >/dev/null 2>&1
    then
        echo "Python 3.9 or newer is already installed."
        python3 --version
    else
        echo "Python version is lower than 3.9. Installing Python..."
        sudo apt update
        sudo apt install -y python3 python3-pip python3-venv
        python3 --version
    fi
else
    echo "Installing Python..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv
    python3 --version
fi


# ---------- pip ----------

echo
echo "Checking pip..."

if python3 -m pip --version >/dev/null 2>&1
then
    echo "pip is already installed."
    python3 -m pip --version
else
    echo "Installing pip..."
    sudo apt update
    sudo apt install -y python3-pip
    python3 -m pip --version
fi


# ---------- venv ----------

echo
echo "Checking venv..."

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

if dpkg -s "python${PYTHON_VERSION}-venv" >/dev/null 2>&1
then
    echo "venv is already installed."
else
    echo "Installing venv..."
    sudo apt update
    sudo apt install -y "python${PYTHON_VERSION}-venv"
fi


# ---------- Django ----------

echo
echo "Checking Django..."

if [[ -x "$DJANGO_VENV/bin/python" ]] && \
   "$DJANGO_VENV/bin/python" -m django --version >/dev/null 2>&1
then
    echo "Django is already installed."
    "$DJANGO_VENV/bin/python" -m django --version
else
    echo "Installing Django in virtual environment..."

    if [[ ! -x "$DJANGO_VENV/bin/python" ]] || \
       ! "$DJANGO_VENV/bin/python" -m pip --version >/dev/null 2>&1
    then
        rm -rf "$DJANGO_VENV"
        mkdir -p "$(dirname "$DJANGO_VENV")"
        python3 -m venv "$DJANGO_VENV"
    fi

    "$DJANGO_VENV/bin/python" -m pip install --upgrade pip
    "$DJANGO_VENV/bin/python" -m pip install Django

    "$DJANGO_VENV/bin/python" -m django --version
fi


# ---------- Summary ----------

echo
echo "===== Installation finished ====="

docker --version
docker compose version
python3 --version
python3 -m pip --version

echo -n "Django "
"$DJANGO_VENV/bin/python" -m django --version

echo
echo "Django virtual environment:"
echo "$DJANGO_VENV"