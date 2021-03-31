#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'


function instalar_python3 (){
  echo -e "${BLUE}[-]${NC} Verificando instalación de python3"
  `python3 --version  &>/dev/null`
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}OK${NC}"
    echo
  else
    echo -e "${BLUE}[-]${NC} Instalando python 3"
    $CMD_PYTHON_INSTALL

    if [ $? -ne 0 ]; then
      echo -e "${RED}Hubo un error..${NC}"
      exit 1
    else 
      echo -e "${GREEN}OK${NC}"
      echo
    fi
  fi
}

function crear_symlinks (){
  echo -e "${BLUE}[-]${NC} Creando symlinks"

  if [ ! -f $BIN_PATH/python ]; then
    $CMD_PYTHON_SYMLINK

    if [ $? -ne 0 ]; then
      echo -e "${RED}Hubo un error..${NC}"
      exit 1
    else 
      echo -e "${GREEN}OK${NC}"
      echo
    fi
  fi

  if [ ! -f $BIN_PATH/pip ]; then
    $CMD_PIP_SYMLINK

    if [ $? -ne 0 ]; then
      echo -e "${RED}Hubo un error..${NC}"
      exit 1
    else 
      echo -e "${GREEN}OK${NC}"
      echo
    fi
  fi

  
}

function instalar_codecommit_helper (){
  echo -e "${BLUE}[-]${NC} Instalando Git codecommit Helper"
  $CMD_PIP_CODECOMMIT_HELPER
  if [ $? -ne 0 ]; then
    echo -e "${RED}Hubo un error..${NC}"
    exit 1
  else 
    echo -e "${GREEN}OK${NC}"
    echo
  fi


  echo -e "${BLUE}[-]${NC} Instalando AWS CLI"
  $CMD_PIP_AWSCLI
  if [ $? -ne 0 ]; then
    echo -e "${RED}Hubo un error..${NC}"
    exit 1
  else 
    echo -e "${GREEN}OK${NC}"
    echo
  fi
}

`apt &>/dev/null`
APT_STATUS=$?
`yum &>/dev/null`
YUM_STATUS=$?

BIN_PATH="/usr/local/bin"

if [ $APT_STATUS -eq 0 ];then
  # Ubuntu and related distros
  echo -e "${BLUE}[-]${NC} Ubuntu/Debian o distro derivada detectada"

  CMD_PYTHON_INSTALL="sudo apt update && sudo apt install -y python3"
  CMD_PYTHON_SYMLINK="sudo ln -s $PYTHON_PATH/python3 $BIN_PATH/python"
  CMD_PIP_SYMLINK="sudo ln -s $PIP_PATH/pip3 $BIN_PATH/pip"
  CMD_PIP_CODECOMMIT_HELPER="sudo pip3 install git-remote-codecommit"
  CMD_PIP_AWSCLI="sudo pip3 install awscli"

  instalar_python3;
  PYTHON_PATH=`which python3 | sed 's/python3//g'`
  PIP_PATH=`which pip3 | sed 's/pip3//g'`
  crear_symlinks;
  instalar_codecommit_helper;

elif [ $YUM_STATUS -eq 0 ]; then
  # Redhat and related distros
  echo -e "${BLUE}[-]${NC} Redhat o distro derivada detectada"

  CMD_PYTHON_INSTALL="sudo yum install -y python3"
  CMD_PYTHON_SYMLINK="sudo ln -s $PYTHON_PATH/python3 $BIN_PATH/python"
  CMD_PIP_SYMLINK="sudo ln -s $PIP_PATH/pip3 $BIN_PATH/pip"
  CMD_PIP_CODECOMMIT_HELPER="sudo pip3 install git-remote-codecommit"
  CMD_PIP_AWSCLI="sudo pip3 install awscli"

  instalar_python3;
  PYTHON_PATH=`which python3 | sed 's/python3//g'`
  PIP_PATH=`which pip3 | sed 's/pip3//g'`

  crear_symlinks;
  instalar_codecommit_helper;

elif [ `uname` == "Darwin" ]; then
  # macos
  echo -e "${BLUE}[-]${NC} MacOS detectado"

  CMD_PYTHON_INSTALL="brew install -f python@3.9"
  CMD_PYTHON_SYMLINK="ln -s $PYTHON_PATH/python3 $BIN_PATH/python"
  CMD_PIP_SYMLINK="ln -s $PIP_PATH/pip3 $BIN_PATH/pip"
  CMD_PIP_CODECOMMIT_HELPER="pip3 install git-remote-codecommit"
  CMD_PIP_AWSCLI="pip3 install awscli"

  echo -e "${BLUE}[-]${NC} Verificando instalación de homebrew"
  `brew --version  &>/dev/null`
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}OK${NC}"
    echo
  else
    echo -e "${BLUE}[-]${NC} Comenzando instalación de hombrew.."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then
      echo -e "${RED}Hubo un error..${NC}"
      exit 1
    else 
      echo -e "${GREEN}OK${NC}"
      echo
    fi
  fi

  instalar_python3;
  PYTHON_PATH=`which python3 | sed 's/python3//g'`
  PIP_PATH=`which pip3 | sed 's/pip3//g'`

  crear_symlinks;
  instalar_codecommit_helper;

fi

echo
echo
echo "Finalizado!"
echo "Reinicia la terminal para ver los cambios.."
