#!/bin/bash

# from https://raw.githubusercontent.com/frealmyr/marlin-build/master/build-marlin.sh

# Ask if wish to update MarlinFirmware to the latest release
if [[ -z $UPDATE_SKIP ]] && [[ -z $USE_TAG ]] && [[ -z $USE_BRANCH ]]; then
  if [[ -z $UPDATE_FORCE ]]; then
    printf "\nYou are currently using MarlinFirmware release:\e[01;33m $(cd Marlin/ && git tag --points-at HEAD)\e[0m\n"
    read -r -p "Do you want to update MarlinFirmware to latest release? [y/N] " response
  else
    response=y
  fi
      case "$response" in
          [yY][eE][sS]|[yY])
              cd Marlin/
              git fetch origin
              git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
              echo "" && cd ..
              ;;
          *)
              echo ""
              ;;
      esac
fi

# Override MarlinFirmware version using branch or tag
if [[ $USE_TAG ]]; then
  cd Marlin/
  git fetch origin
  git checkout $USE_TAG
  printf "\nYou are now using git tag:\e[01;33m $(git tag --points-at HEAD)\e[0m\n\n"
  cd ..
elif [[ $USE_BRANCH ]]; then
  cd Marlin/
  git fetch origin
  git checkout $USE_BRANCH
  printf "\nYou are now using the latest commit in branch:\e[01;33m $(git branch | sed -n '/\* /s///p')\e[0m\n\n"
  cd ..
fi

# Check if custom configuration files exists within the docker container
CONFIG_CHECK=$(ls -1 /home/platformio/CustomConfiguration/*.h 2>/dev/null | wc -l)
if [ $CONFIG_CHECK = 0 ]
then
  printf "\n\e[1;31mNo custom configuration files detected! \e[0maborting..\n"
  exit 1
fi

# Copy custom configuration files to Marlin folder
while IFS= read -r line; do
  cp /home/platformio/CustomConfiguration/${line}.h /home/platformio/Marlin/Marlin/${line}.h
done <<< $(find /home/platformio/CustomConfiguration/ -name '*.h' -exec basename {} .h \;)

# Change the default board with value in environment variable
sed -i "s/default_envs = .*/default_envs = ${BOARD}/g" /home/platformio/Marlin/platformio.ini

# Build Marlin firmware
printf "\e[1;35mCompiling Marlin firmware..\e[0m\n\n"
platformio run -d Marlin/

success=$?

if [[ ${success} -eq 0 ]]; then
  OUTPUT_DIR=/home/platformio/build/${BOARD}
  mkdir -p ${OUTPUT_DIR}

  printf "\nCopying compiled firmware to output folder..\n"
  cd /home/platformio/Marlin/.pio/build/${BOARD}
  mv *.hex "${OUTPUT_DIR}/marlin-${USE_TAG}_${BOARD}_$(date +%Y-%m-%d_%H%M).hex"

else
  printf "\n\e[1;31mBuild failed! \e[0mCheck the output above for errors\n"
  exit 1
fi
