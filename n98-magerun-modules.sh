#!/bin/bash

mkdir -p ~/.n98-magerun/modules/
if [ ! -d ~/.n98-magerun/modules/yireo ] ; then
  git clone https://github.com/yireo/magerun-addons ~/.n98-magerun/modules/yireo
fi
if [ ! -d ~/.n98-magerun/modules/mpmd ] ; then
  git clone https://github.com/aoepeople/mpmd ~/.n98-magerun/modules/mpmd
fi
if [ ! -d ~/.n98-magerun/modules/magerun-commands ] ; then
  git clone https://github.com/degdigital/magerun-commands ~/.n98-magerun/modules/magerun-commands
fi
if [ ! -d ~/.n98-magerun/modules/magerun-addons ] ; then
  git clone https://github.com/peterjaap/magerun-addons ~/.n98-magerun/modules/magerun-addons
fi
if [ ! -d ~/.n98-magerun/modules/magerun-creatuity ] ; then
  git clone https://github.com/creatuity/magerun-creatuity ~/.n98-magerun/modules/magerun-creatuity
fi
if [ ! -d ~/.n98-magerun/modules/magerun-module-cache-benchmark ] ; then
  git clone https://github.com/cmuench/magerun-module-cache-benchmark ~/.n98-magerun/modules/magerun-module-cache-benchmark
fi
if [ ! -d ~/.n98-magerun/modules/cmuench-magerun-addons ] ; then
  git clone https://github.com/cmuench/cmuench-magerun-addons ~/.n98-magerun/modules/cmuench-magerun-addons
fi
if [ ! -d ~/.n98-magerun/modules/kalenjordan-magerun-addons ] ; then
  git clone https://github.com/kalenjordan/magerun-addons ~/.n98-magerun/modules/kalenjordan-magerun-addons
fi
if [ ! -d ~/.n98-magerun/modules/Webgriffe_Golive ] ; then
  git clone https://github.com/aleron75/Webgriffe_Golive ~/.n98-magerun/modules/Webgriffe_Golive
fi
if [ ! -d ~/.n98-magerun/modules/ffuenf-download-remote-media ] ; then
  git clone https://github.com/ffuenf/download-remote-media ~/.n98-magerun/modules/ffuenf-download-remote-media
fi
if [ ! -d ~/.n98-magerun/modules/sxmlsv ] ; then
  git clone https://github.com/KamilBalwierz/sxmlsv ~/.n98-magerun/modules/sxmlsv
fi
if [ ! -d ~/.n98-magerun/modules/magerun-dataprofile ] ; then
  git clone https://github.com/marcoandreini/magerun-dataprofile ~/.n98-magerun/modules/magerun-dataprofile
fi
if [ ! -d ~/.n98-magerun/modules/Magerun-DBClean ] ; then
  git clone https://github.com/steverobbins/Magerun-DBClean ~/.n98-magerun/modules/Magerun-DBClean
fi
if [ ! -d ~/.n98-magerun/modules/magerun-modman ] ; then
  git clone https://github.com/fruitcakestudio/magerun-modman ~/.n98-magerun/modules/magerun-modman
fi
if [ ! -d ~/.n98-magerun/modules/EAVCleaner ] ; then
  git clone https://github.com/magento-hackathon/EAVCleaner ~/.n98-magerun/modules/EAVCleaner
fi
if [ ! -d ~/.n98-magerun/modules/magescan ] ; then
  git clone https://github.com/steverobbins/magescan ~/.n98-magerun/modules/magescan
fi
if [ ! -d ~/.n98-magerun/modules/hypernode-magerun ] ; then
  git clone https://github.com/Hypernode/hypernode-magerun ~/.n98-magerun/modules/hypernode-magerun
fi
