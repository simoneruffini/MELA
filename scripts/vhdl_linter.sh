#! /bin/sh

COMMAND="vsg"

if ! which $COMMAND >/dev/null ; then
  echo "Error: vsg not found";
  exit 1
fi

VSG_CNFG_PATH=$(dirname $(realpath $0))
VSG_CNFG="$VSG_CNFG_PATH/vsg-cnfg.json"

echo "Vsg config path \n\t$VSG_CNFG"

if [ ! -f $VSG_CNFG ]; then
  echo "Error: missing vsg config";
  exit 1
fi

if [ $# -lt 1 ]; then
  echo "Error: not enough parameters"
  exit 1
fi

FIX=""
PARAMETERS="--style jcl --configuration '$VSG_CNFG' --jobs 6 --filename"

if [ $# -eq 2 ]; then
  if [ $2 = "fix" ]; then
    FIX="--fix" 
  else
    echo "Error: second parameter not valid"
    exit 1
  fi
fi

if [ ! -f $1 ]; then
  echo "File not existing"
  exit 1
fi

FILE_PATH=$1

EXEC="$COMMAND $PARAMETERS '$FILE_PATH' $FIX"
echo "Executing: \n\t$EXEC"

eval $EXEC
