#! /bin/bash
########################################################################
# batch optimise images
# written by George Liu (eva2000) centminmod.com
# docs
# https://www.imagemagick.org/Usage/thumbnails/
# https://www.imagemagick.org/Usage/files/#read_mods
# https://www.imagemagick.org/Usage/advanced/
# https://www.imagemagick.org/Usage/basics/#mogrify
# https://www.imagemagick.org/script/command-line-options.php#define
# https://www.imagemagick.org/Usage/files/#write
# https://www.imagemagick.org/Usage/api/#scripts
# https://www.imagemagick.org/Usage/files/#massive
# https://www.imagemagick.org/script/architecture.php
# https://www.imagemagick.org/script/compare.php
# http://www.imagemagick.org/Usage/compare/#statistics
#
# webp
# http://caniuse.com/#feat=webp
# https://developers.google.com/speed/webp/
# https://www.imagemagick.org/script/webp.php
#
# guetzli
# https://github.com/google/guetzli/
# https://github.com/google/guetzli/issues/195
#
# mozjpeg
# https://github.com/mozilla/mozjpeg
#
# test images
# https://testimages.org/
# https://css-ig.net/png-test-corpus
# https://github.com/nwtn/image-resize-tests/blob/master/asset-sources.txt
# https://github.com/FLIF-hub/benchmarks
#
# butteraugli
# https://github.com/google/butteraugli
#
# GraphicsMagick
# http://www.graphicsmagick.org/convert.html
# http://www.graphicsmagick.org/identify.html
#
# lazy load gallery images
# http://dinbror.dk/blog/blazy/?ref=demo-page
########################################################################
DT=$(date +"%d%m%y-%H%M%S")
VER='4.7'
DEBUG='n'

# Used for optimise-age mod, set FIND_IMGAGE in minutes. So to only
# optimise images 
# older than 1 hour set FIND_IMGAGE='60'
# older than 1 day set FIND_IMGAGE='1440'
# older than 1 week set FIND_IMGAGE='10080'
# older than 1 month set FIND_IMGAGE='43200'
FIND_IMGAGE=''

# Optional add comment to optimised images "optimised" to allow
# subsequent re-runs of script to detect the comment and skip
# re-optimising of the previously optimised image
ADD_COMMENT='y'

# System resource management for cpu and disk utilisation
NICE='/bin/nice'
# Nicenesses range from -20 (most favorable scheduling) 
# to 19 (least favorable)
NICEOPT='-n 10'
IONICE='/usr/bin/ionice'
# -c class
# The scheduling class. 0 for none, 1 for real time, 2 for best-effort, 3 for idle.
# -n classdata
# The scheduling class data. This defines the class data, if the class accepts an 
# argument. For real time and best-effort, 0-7 is valid data and the priority 
# i.e. -c2 -n0 would be best effort with highest priority
IONICEOPT='-c2 -n7'

# Optimisation routine settings
# UNATTENDED_OPTIMISE controls whether optimise command will prompt 
# user to ask if they have backed up the image directory before runs
# setting UNATTENDED_OPTIMISE='y' will skip that question prompt
# suited more for script runs i.e. a for or while loop of a batch of
# subdirectories within a parent directory to automate optimise-images.sh
# optimise runs against each subdirectory.
UNATTENDED_OPTIMISE='y'

# control sample image downloads
# allows you to control how many sample images to work with/download
# guetzli testing is very resource and time consuming so working with
# a smaller sample image set would be better
TESTFILES_MINIMAL='y'
TESTFILES_PNGONLY='n'
TESTFILES_JPEGONLY='n'
TESTFILES_WITHSPACES='n'

# max width and height
MAXRES='2048'

# Max directory depth to look for images
# currently only works at maxdepth=1 so 
# do not edit yet
MAXDEPTH='1'

# ImageMagick Settings
IMAGICK_RESIZE='y'
IMAGICK_JPEGHINT='y'
IMAGICK_QUALITY='82'
IMAGICK_WEBP='y'
IMAGICK_WEBPQUALITY='75'
IMAGICK_WEBPQUALITYALPHA='100'
IMAGICK_WEBPMETHOD='4'
IMAGICK_WEBPLOSSLESS='n'
IMAGICK_WEBPTHREADS='1'
# Quantum depth 8 or 16 for ImageMagick 7
# Source installs
IMAGICK_QUANTUMDEPTH='8'
IMAGICK_SEVEN='n'
IMAGICK_SEVENHDRI='n'
IMAGICK_TMPDIR='/home/imagicktmp'
IMAGICK_JPGOPTS=' -filter triangle -define filter:support=2 -define jpeg:fancy-upsampling=off -unsharp 0.25x0.08+8.3+0.045'
IMAGICK_PNGOPTS=' -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=2'
IMAGICK_WEBPOPTS=" -define webp:method=${IMAGICK_WEBPMETHOD} -define webp:alpha-quality=${IMAGICK_WEBPQUALITYALPHA} -define webp:lossless=false -quality ${IMAGICK_WEBPQUALITY}"

# GraphicsMagick Settings
GM_USE='n'

# strip meta-data
STRIP='y'

# additional image optimisations after imagemagick
# resizing
# choose one of the 3 JPEGOPTIM, GUETZLI or MOZJPEG
JPEGOPTIM='y'
GUETZLI='n'
MOZJPEG='n'
# choose either OPTIPNG or ZOPFLIPNG
OPTIPNG='y'
ZOPFLIPNG='n'

# Speed control
# default is -o2 set 2
OPTIPNG_COMPRESSION='2'

# Guetzli Options
# GUETZLI_JPEGONLY will only optimise original jpeg/jpg
# images and NOT convert png to Guetzli optimised jpgs
# set to = 'n' to convert png as well
GUETZLI_JPEGONLY='y'
GUETZLI_QUALITY='85'
GUETZLI_OPTS='--verbose'

# MozJPEG Options
# MOZJPEG_JPEGONLY will only optimise original jpeg/jpg
# images and NOT convert png to MozJPEG optimised jpgs
# set to = 'n' to convert png as well
MOZJPEG_JPEGONLY='y'
MOZJPEG_JPEGTRAN='y'
MOZJPEG_CJPEG='n'
MOZJPEG_QUALITY='-quality 82'
MOZJPEG_OPTS='-verbose'

# ZopfliPNG Settings
# Always create ZopfliPNG version even if original is
# smaller for benchmarking. 
ZOPFLIPNG_ALWAYS='y'
# Default iterations is 15 for small files 
# 5 for large files. Set to Auto for defaults
ZOPFLIPNG_ITERATIONS='auto'
# --lossy_8bit --lossy_transparent
ZOPFLIPNG_LOSSY='n'

# profile option display fields for transparency color and background color
# disabled by default to speed up profile processing
PROFILE_EXTEND='n'

# comparison mode when enabled will when resizing and optimising images
# write to a separate optimised image within the same directory as the
# original images but with a suffix attached to the end of original image
# file name i.e. image.png vs image_optimal.png
COMPARE_MODE='n'
COMPARE_SUFFIX='_optimal'

# optionally create thumbnails in separate directory
# within image directory and thumbnail width x height
# and thumbnail image format default = .jpg
THUMBNAILS='n'
THUMBNAILS_QUALITY='70'
THUMBNAILS_WIDTH='160'
THUMBNAILS_HEIGHT='160'
THUMBNAILS_FORMAT='jpg'
THUMBNAILS_DIRNAME='thumbnails'

LOGDIR='/home/optimise-logs'
LOGNAME_PROFILE="profile-log-${DT}.log"
LOG_PROFILE="${LOGDIR}/${LOGNAME_PROFILE}"
BENCHDIR='/home/optimise-benchmarks'

GUETZLI_BIN='/opt/guetzli/bin/Release/guetzli'
BUTTERAUGLI_BIN='/usr/bin/butteraugli'
GM_BIN='/usr/bin/gm'
########################################################################
# DO NOT EDIT BELOW THIS POINT

CENTOSVER=$(cat /etc/redhat-release | awk '{ print $3 }')

if [ "$CENTOSVER" == 'release' ]; then
    CENTOSVER=$(cat /etc/redhat-release | awk '{ print $4 }' | cut -d . -f1,2)
    if [[ "$(cat /etc/redhat-release | awk '{ print $4 }' | cut -d . -f1)" = '7' ]]; then
        CENTOS_SEVEN='7'
    fi
fi

if [[ "$(cat /etc/redhat-release | awk '{ print $3 }' | cut -d . -f1)" = '6' ]]; then
    CENTOS_SIX='6'
fi

if [ ! -f /etc/yum.repos.d/epel.repo ]; then
  yum -q -y install epel-release
fi

if [[ "$MOZJPEG_JPEGTRAN" = [yY] ]]; then
  MOZJPEG_BIN='/opt/mozjpeg/bin/jpegtran'
  MOZJPEG_QUALITY=""
else
  MOZJPEG_BIN='/opt/mozjpeg/bin/cjpeg'
fi

# Binary paths
if [[ "$GM_USE" = [yY] && -f /usr/bin/gm ]]; then
  IDENTIFY_BIN='/usr/bin/gm identify'
  CONVERT_BIN='/usr/bin/gm convert'
elif [[ "$IMAGICK_SEVEN" = [yY] && -f /opt/imagemagick7/bin/identify ]]; then
  IDENTIFY_BIN='/opt/imagemagick7/bin/identify'
  CONVERT_BIN='/opt/imagemagick7/bin/convert'
else
  IDENTIFY_BIN='/usr/bin/identify'
  CONVERT_BIN='/usr/bin/convert'
fi

if [ -f /proc/user_beancounters ]; then
    CPUS=$(cat "/proc/cpuinfo" | grep "processor"|wc -l)
else
    # speed up make
    CPUS=$(cat "/proc/cpuinfo" | grep "processor"|wc -l)
fi

if [[ "$CPUS" -ge ' 4' ]]; then
  IMAGICK_THREADLIMIT=$(($CPUS/2))
  export MAGICK_THREAD_LIMIT="$IMAGICK_THREADLIMIT"
  IMAGICK_WEBPTHREADSOPTS=" -define webp:thread-level=${IMAGICK_WEBPTHREADS}"
else
  IMAGICK_WEBPTHREADSOPTS=""
fi

if [ ! -f /bin/nice ]; then
  yum -q -y install coreutils
fi

if [ ! -f /usr/bin/ionice ]; then
  if [[ "$CENTOS_SIX" = '6' ]]; then
    yum -q -y install util-linux-ng
  else
    yum -q -y install util-linux
  fi
fi

if [ ! -f /usr/bin/sar ]; then
  yum -y -q install sysstat
  if [[ "$(uname -m)" = 'x86_64' ]]; then
    SARCALL='/usr/lib64/sa/sa1'
  else
    SARCALL='/usr/lib/sa/sa1'
  fi
else
  if [[ "$(uname -m)" = 'x86_64' ]]; then
    SARCALL='/usr/lib64/sa/sa1'
  else
    SARCALL='/usr/lib/sa/sa1'
  fi
fi

if [ ! -f /usr/bin/bc ]; then
  yum -q -y install bc
fi

if [ ! -f /usr/bin/optipng ]; then
  yum -q -y install optipng
fi

if [ ! -f /usr/bin/jpegoptim ]; then
  yum -q -y install jpegoptim
fi

if [ ! -f /usr/bin/gm ]; then
  yum -q -y install GraphicsMagick
fi

if [[ "$ZOPFLIPNG" = [yY] && ! -f /usr/bin/zopflipng ]]; then
  echo "installing zopflipng"
  mkdir -p /opt/zopfli
  cd /opt/zopfli
  git clone https://github.com/google/zopfli
  cd zopfli/
  make -s -j2
  make -s zopflipng
  make -s libzopfli
  \cp -f zopflipng /usr/bin/zopflipng
  # OPTIPNG='n'
  echo "installed zopflipng"
elif [[ "$ZOPFLIPNG" = [yY] && -f /usr/bin/zopflipng ]]; then
  # OPTIPNG='n'
  echo
fi

if [[ "$STRIP" = [Yy] ]]; then
  STRIP_OPT=' -strip'
else
  STRIP_OPT=""
fi

if [[ "$ADD_COMMENT" = [Yy] ]]; then
  ADDCOMMENT_OPT=' -set comment optimised'
  PNGSTRIP_OPT=""
else
  ADDCOMMENT_OPT=""
  PNGSTRIP_OPT="$STRIP_OPT"
fi

if [[ "$IMAGICK_JPEGHINT" = [yY] ]]; then
  JPEGHINT_WIDTH=$(($MAXRES*2))
  JPEGHINT_HEIGHT=$(($MAXRES*2))
  JPEGHINT_OPT=" -define jpeg:size=${JPEGHINT_WIDTH}x${JPEGHINT_HEIGHT}"
else
  JPEGHINT_OPT=""
fi

if [[ "$IMAGICK_WEBP" = [yY] ]]; then
  FIND_WEBP=' -o -name "*.webp"'
else
  FIND_WEBP=""
fi

if [[ "$IMAGICK_WEBPLOSSLESS" = [yY] ]]; then
  IMAGICK_WEBPOPTS=" -define webp:method=${IMAGICK_WEBPMETHOD} -define webp:lossless=true"
fi

if [[ "$ZOPFLIPNG_ALWAYS" = [yY] ]]; then
  ZOPFLIPNG_OPTSALWAYS=' --always_zopflify'
else
  ZOPFLIPNG_OPTSALWAYS=''
fi

if [[ "$ZOPFLIPNG_LOSSY" = [yY] ]]; then
  ZOPFLIPNG_OPTSLOSSY=' --lossy_8bit --lossy_transparent'
else
  ZOPFLIPNG_OPTSLOSSY=''
fi

if [[ "$ZOPFLIPNG_ITERATIONS" = 'auto' ]]; then
  # other options
  # --filters=01234mepb
  ZOPFLIPNG_OPTS=" -y${ZOPFLIPNG_OPTSALWAYS}${ZOPFLIPNG_OPTSLOSSY}"
else
  ZOPFLIPNG_OPTS=" -y --iterations=${ZOPFLIPNG_ITERATIONS}${ZOPFLIPNG_OPTSALWAYS}${ZOPFLIPNG_OPTSLOSSY}"
fi

if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
  # imagemagick resizes and does image optimisation passing it to jpegotim
  # for further optimisations but if you set IMAGEICK_RESIZE='n' and also
  # set JPEGOPTIM='n' then jpg images won't have any optimisation done 
  # so when IMAGEICK_RESIZE='n' set force JPEGOPTIM='y' automatically
  JPEGOPTIM='y'
fi

if [ ! -d "$IMAGICK_TMPDIR" ]; then
  mkdir -p "$IMAGICK_TMPDIR"
  chmod 1777 "$IMAGICK_TMPDIR"
elif [ -d "$IMAGICK_TMPDIR" ]; then
  chmod 1777 "$IMAGICK_TMPDIR"
fi

if [ ! -d  "$LOGDIR" ]; then
  mkdir -p "$LOGDIR"
fi

if [ ! -d  "$BENCHDIR" ]; then
  mkdir -p "$BENCHDIR"
fi

IMAGICK_VERSION=$($CONVERT_BIN -version | head -n1 | awk '/^Version:/ {print $2,$3,$4,$5,$6}')
##########################################################################
# function

if [[ "$GM_USE" = [yY] ]]; then
  IMAGICK_TMPDIR='/home/imagicktmp'
  IMAGICK_JPGOPTS=' -filter triangle -unsharp 0.25x0.08+8.3+0.045'
  IMAGICK_PNGOPTS=''
  IMAGICK_WEBPOPTS=" -quality ${IMAGICK_WEBPQUALITY}"
  JPEGHINT_WIDTH=$(($MAXRES*2))
  JPEGHINT_HEIGHT=$(($MAXRES*2))
  JPEGHINT_OPT=" -size ${JPEGHINT_WIDTH}x${JPEGHINT_HEIGHT}"
  DEFINE_TMP=''
else
  DEFINE_TMP=" -define registry:temporary-path="${IMAGICK_TMPDIR}""
fi

mozjpeg_install() {
  if [ ! -f /usr/bin/nasm ]; then
    yum -q -y install nasm
  fi
  echo "installing mozjpeg"
  cd /usr/src
  wget https://github.com/mozilla/mozjpeg/releases/download/v3.2-pre/mozjpeg-3.2-release-source.tar.gz
  tar xzf mozjpeg-3.2-release-source.tar.gz
  cd mozjpeg
  ./configure
  make -s
  make -s install
  MOZJPEG_BIN='/opt/mozjpeg/bin/jpegtran'
  echo "installed mozjpeg" 
}

butteraugli_install() {
  echo "installing butteraugli"
  cd /opt
  rm -rf butteraugli
  git clone https://github.com/google/butteraugli
  cd butteraugli/butteraugli
  make
  \cp -af butteraugli /usr/bin/butteraugli
  BUTTERAUGLI_BIN='/usr/bin/butteraugli'
  echo "installed butteraugli" 
}

guetzli_install() {
  echo "installing guetzli"
  cd /opt
  rm -rf guetzli
  git clone https://github.com/google/guetzli
  cd guetzli
  make
  GUETZLI_BIN='/opt/guetzli/bin/Release/guetzli'
  echo "installed guetzli"
}

if [[ "$GUETZLI" = [yY] && ! -f /usr/bin/libpng-config && ! -f "$GUETZLI_BIN" ]]; then
  yum -q -y install libpng-devel
  guetzli_install
elif [[ "$GUETZLI" = [yY] && -f /usr/bin/libpng-config && ! -f "$GUETZLI_BIN" ]]; then
  guetzli_install
fi

if [[ "$CENTOS_SEVEN" -eq '7' && ! -f "$BUTTERAUGLI_BIN" ]]; then
  butteraugli_install
fi

install_source() {
  echo "------------------------------------"
  echo "install ImageMagick 7 at:"
  echo "/opt/imagemagick7/bin/identify"
  echo "/opt/imagemagick7/bin/convert"
  echo "------------------------------------"
  CPUVENDOR=$(cat /proc/cpuinfo | awk '/vendor_id/ {print $3}' | sort -u | head -n1)
  SSECHECK=$(gcc -c -Q -march=native --help=target | awk '/  -msse/ {print $2}' | head -n1)

  if [[ "$(uname -m)" = 'x86_64' && "$CPUVENDOR" = 'GenuineIntel' && "$SSECHECK" = '[enabled]' ]]; then
      CCM=64
      CRYPTOGCC_OPT="-m${CCM} -march=native"
      # if only 1 cpu thread use -O2 to keep compile times sane
      if [[ "$CPUS" = '1' ]]; then
      export CFLAGS="-O2 $CRYPTOGCC_OPT -pipe"
      else
      export CFLAGS="-O3 $CRYPTOGCC_OPT -pipe"
      fi
      export CXXFLAGS="$CFLAGS"
  fi

  if [[ "$IMAGICK_SEVENHDRI" = [yY] ]]; then
    HDRI_OPT='--enable-hdri'
  else
    HDRI_OPT='--disable-hdri'
  fi

  # built Q8 instead system Q16 for speed
  # http://www.imagemagick.org/script/advanced-unix-installation.php
  cd /usr/src
  rm -rf ImageMagick.tar.gz
  rm -rf ImageMagick-7*
  wget -cnv https://www.imagemagick.org/download/ImageMagick.tar.gz
  tar xzf ImageMagick.tar.gz
  cd ImageMagick-7*
  make clean
  ./configure CFLAGS="$CFLAGS" --prefix=/opt/imagemagick7 --with-quantum-depth="${IMAGICK_QUANTUMDEPTH}" "${HDRI_OPT}"
  make -j${CPUS}
  make install
  IDENTIFY_BIN='/opt/imagemagick7/bin/identify'
  CONVERT_BIN='/opt/imagemagick7/bin/convert'
  echo "------------------------------------"
  echo ""
  echo "------------------------------------"
}

sar_call() {
  $SARCALL 1 1
}

optimiser() {
  WORKDIR=$1
  CONTINUE=$2
  if [[ "$AGE" = [yY] && ! -z "$FIND_IMGAGE" ]]; then
    FIND_IMGAGEOPT=" -mmin -${FIND_IMGAGE}"
    FIND_IMGAGETXT="filtered: $FIND_IMGAGE minutes old"
  else
    FIND_IMGAGEOPT=""
    FIND_IMGAGETXT=""
  fi
  if [[ "$CONTINUE" = 'yes' || "$UNATTENDED_OPTIMISE" = [yY] ]]; then
    havebackup='y'
  else
    #echo
    #echo "!!! Important !!!"
    #echo
    read -ep "Have you made a backup of images in $WORKDIR? [y/n]: " havebackup
    if [[ "$havebackup" != [yY] ]]; then
      #echo
      #echo "Please backup $WORKDIR before optimising images"
      #echo "aborting..."
      #echo
      exit
    fi
  fi
  if [[ "$havebackup" = [yY] ]]; then
echo "starting"
  starttime=$(TZ=UTC date +%s.%N)
  {

  #echo
  #echo "------------------------------------------------------------------------------"
  #echo "image optimisation start"
  #echo "------------------------------------------------------------------------------"
#  cd "$WORKDIR"
  if [[ "$THUMBNAILS" = [yY] ]]; then
    mkdir -p "$THUMBNAILS_DIRNAME"
  fi
  find "$WORKDIR" \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' \) | while read i; do 
    file=$(basename "${i}")
    extension="${file##*.}"
    filename="${file%.*}"

  if [ -d "${i}" ]; then
    cd ${i}
  else
    NEWWORKDIR=$(dirname "${i}")
    cd $NEWWORKDIR
  fi
    if [[ "$COMPARE_MODE" = [yY] && "OPTIPNG" = [yY] && "$ZOPFLIPNG" = [yY] ]]; then
      filein="${filename}${COMPARE_SUFFIX}.${extension}"
      fileout="${filename}${COMPARE_SUFFIX}.${extension}"
      gfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      jfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      gfileout="${filename}${COMPARE_SUFFIX}.${extension}"
      jfileout="${filename}${COMPARE_SUFFIX}.${extension}"
    elif [[ "$COMPARE_MODE" = [yY] && "$GUETZLI" = [nN] && "$IMAGICK_RESIZE" = [yY] ]]; then
      filein="${filename}${COMPARE_SUFFIX}.${extension}"
      fileout="${filename}${COMPARE_SUFFIX}.${extension}"
      gfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      jfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      gfileout="${filename}${COMPARE_SUFFIX}.${extension}"
      jfileout="${filename}${COMPARE_SUFFIX}.${extension}"
    elif [[ "$COMPARE_MODE" = [yY] && "$GUETZLI" = [yY] ]]; then
      filein="${filename}${COMPARE_SUFFIX}.${extension}"
      fileout="${filename}${COMPARE_SUFFIX}.${extension}"
      gfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      jfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      gfileout="${filename}${COMPARE_SUFFIX}.${extension}"
      jfileout="${filename}${COMPARE_SUFFIX}.${extension}"
    elif [[ "$COMPARE_MODE" = [yY] && "$extension" = 'jpg' && "$JPEGOPTIM" = [yY] && "$IMAGICK_RESIZE" = [nN] ]]; then
      filein="${filename}.${extension}"
      fileout="${filename}${COMPARE_SUFFIX}.noresize.${extension}"
      gfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      jfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      gfileout="${filename}${COMPARE_SUFFIX}.${extension}"
      jfileout="${filename}${COMPARE_SUFFIX}.${extension}"
    elif [[ "$COMPARE_MODE" = [nN] && "$extension" = 'jpg' && "$JPEGOPTIM" = [yY] && "$IMAGICK_RESIZE" = [nN] ]]; then
      filein="${filename}.${extension}"
      fileout="${filename}.noresize.${extension}"
      gfilein="${filename}.${extension}"
      jfilein="${filename}.${extension}"
      gfileout="${filename}.${extension}"
      jfileout="${filename}.${extension}"
    elif [[ "$COMPARE_MODE" = [yY] && "$IMAGICK_RESIZE" = [nN] ]]; then
      filein="${filename}.${extension}"
      fileout="${filename}${COMPARE_SUFFIX}.${extension}"
      gfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      jfilein="${filename}${COMPARE_SUFFIX}.${extension}"
      gfileout="${filename}${COMPARE_SUFFIX}.${extension}"
      jfileout="${filename}${COMPARE_SUFFIX}.${extension}"
    else
      filein="${filename}.${extension}"
      fileout="${filename}.${extension}"
      gfilein="${filename}.${extension}"
      jfilein="${filename}.${extension}"
      gfileout="${filename}.${extension}"
      jfileout="${filename}.${extension}"
    fi
    # -format '%c' doesn't work on png files to obtain comment in script only on jpgs
    # so use -format '%z:%c' and awk to filter and print 2nd field value
    IS_OPTIMISED=$($IDENTIFY_BIN -format '%z:%c' "${file}" | awk -F ':' '{print $2}')
    if [[ "$IS_OPTIMISED" != 'optimised' ]]; then
      echo "### $file ($extension) ###"
    else
      echo "### $file ($extension) skip already optimised ###"
    fi
    IS_INTERLACED=$($IDENTIFY_BIN -verbose "${file}" | awk '/Interlace/ {print $2}')
    IS_TRANSPARENT=$($IDENTIFY_BIN -format "%A" "${file}")
    IS_TRANSPARENTCOLOR=$($IDENTIFY_BIN -verbose "${file}" | awk '/Transparent color/ {print $3}')
    if [[ "$GM_USE" != [yY] ]]; then
      IS_BACKGROUNDCOLOR=$($IDENTIFY_BIN -verbose "${file}" | awk '/Background Color: / {print $3}')
    else
      IS_BACKGROUNDCOLOR=$($IDENTIFY_BIN -verbose "${file}" | awk '/Background color: / {print $3}')
    fi
    # GraphicsMagick returns No vs ImageMagick returns None
    if [[ "$IS_INTERLACED" = 'None' || "$IS_INTERLACED" = 'No' ]]; then
      INTERLACE_OPT=' -interlace none'
      JPEGOPTIM_PROGRESSIVE=''
    elif [[ "$IS_INTERLACED" = 'JPEG' || "$IS_INTERLACED" = 'PNG' ]]; then
      INTERLACE_OPT=' -interlace plane'
      JPEGOPTIM_PROGRESSIVE=' --all-progressive'
    else
      INTERLACE_OPT=""
      JPEGOPTIM_PROGRESSIVE=''
    fi
    if [[ "$IS_OPTIMISED" != 'optimised' ]]; then
      # start optimisation routines
      if [[ "$extension" = 'jpg' && "$IMAGICK_RESIZE" = [yY] && "$JPEGOPTIM" = [yY] ]] || [[ "$extension" = 'jpeg' && "$IMAGICK_RESIZE" = [yY] && "$JPEGOPTIM" = [yY] ]]; then
      if [[ "$THUMBNAILS" = [yY] ]]; then
        if [[ "$GM_USE" != [yY] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${JPEGHINT_OPT}${IMAGICK_JPGOPTS}${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} \
          -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
          "mpr:$filename" -thumbnail '150x150>' -unsharp 0x.5 "${THUMBNAILS_DIRNAME}/${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${JPEGHINT_OPT}${IMAGICK_JPGOPTS}${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} \
          -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
          "mpr:$filename" -thumbnail '150x150>' -unsharp 0x.5 "${THUMBNAILS_DIRNAME}/${filename}.${THUMBNAILS_FORMAT}"
        fi
      else
        if [[ "$IMAGICK_WEBP" = [yY] ]]; then
          if [[ "$GM_USE" != [yY] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${JPEGHINT_OPT}${IMAGICK_JPGOPTS}${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} \
            -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
            "mpr:$filename"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS} -resize ${MAXRES}x${MAXRES}\> "${filename}.${extension}.webp""
            $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${JPEGHINT_OPT}${IMAGICK_JPGOPTS}${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} \
            -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
            "mpr:$filename"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS} -resize ${MAXRES}x${MAXRES}\> "${filename}.${extension}.webp"
          fi
        else
          echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${JPEGHINT_OPT}${IMAGICK_JPGOPTS}${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -resize ${MAXRES}x${MAXRES}\> "${fileout}""
          $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${JPEGHINT_OPT}${IMAGICK_JPGOPTS}${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -resize ${MAXRES}x${MAXRES}\> "${fileout}"
        fi
      sar_call
      fi
      elif [[ "$extension" = 'jpg' && "$IMAGICK_RESIZE" = [nN] && "$JPEGOPTIM" = [yY] ]] || [[ "$extension" = 'jpeg' && "$IMAGICK_RESIZE" = [nN] && "$JPEGOPTIM" = [yY] ]]; then
        if [[ "$IMAGICK_WEBP" = [yY] ]]; then
          if [[ "$GM_USE" != [yY] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS}${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} "${filename}.${extension}.webp""
            $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS}${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} "${filename}.${extension}.webp"
          fi
        sar_call
        fi
      elif [[ "$extension" = 'png' && "$IMAGICK_RESIZE" = [yY] ]]; then
      if [[ "$THUMBNAILS" = [yY] ]]; then
        if [[ "$GM_USE" != [yY] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${PNGSTRIP_OPT}${ADDCOMMENT_OPT}${IMAGICK_PNGOPTS} \
          -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
          "mpr:$filename" -thumbnail '150x150>' -unsharp 0x.5 "${THUMBNAILS_DIRNAME}/${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${PNGSTRIP_OPT}${ADDCOMMENT_OPT}${IMAGICK_PNGOPTS} \
          -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
          "mpr:$filename" -thumbnail '150x150>' -unsharp 0x.5 "${THUMBNAILS_DIRNAME}/${filename}.${THUMBNAILS_FORMAT}"
        fi
      else
        if [[ "$IMAGICK_WEBP" = [yY] ]]; then
          if [[ "$GM_USE" != [yY] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${PNGSTRIP_OPT}${ADDCOMMENT_OPT}${IMAGICK_PNGOPTS} \
            -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
            "mpr:$filename"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS} -resize ${MAXRES}x${MAXRES}\> "${filename}.${extension}.webp""
            $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${PNGSTRIP_OPT}${ADDCOMMENT_OPT}${IMAGICK_PNGOPTS} \
            -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
            "mpr:$filename"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS} -resize ${MAXRES}x${MAXRES}\> "${filename}.${extension}.webp"
          fi
        else
          echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${PNGSTRIP_OPT}${ADDCOMMENT_OPT}${IMAGICK_PNGOPTS} -resize ${MAXRES}x${MAXRES}\> "${fileout}""
          $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${PNGSTRIP_OPT}${ADDCOMMENT_OPT}${IMAGICK_PNGOPTS} -resize ${MAXRES}x${MAXRES}\> "${fileout}"
        fi
      sar_call
      fi
      elif [[ "$extension" = 'png' && "$IMAGICK_RESIZE" = [nN] ]]; then
        if [[ "$IMAGICK_WEBP" = [yY] ]]; then
          if [[ "$GM_USE" != [yY] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS}${INTERLACE_OPT}${PNGSTRIP_OPT}${ADDCOMMENT_OPT}${IMAGICK_PNGOPTS} "${filename}.${extension}.webp""
            $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS}${INTERLACE_OPT}${PNGSTRIP_OPT}${ADDCOMMENT_OPT}${IMAGICK_PNGOPTS} "${filename}.${extension}.webp"
          fi
        sar_call
        fi
      elif [[ "$IMAGICK_RESIZE" = [yY] ]]; then
      if [[ "$THUMBNAILS" = [yY] ]]; then
        if [[ "$GM_USE" != [yY] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -quality "$IMAGICK_QUALITY" \
          -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
          "mpr:$filename" -thumbnail '150x150>' -unsharp 0x.5 "${THUMBNAILS_DIRNAME}/${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -quality "$IMAGICK_QUALITY" \
          -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
          "mpr:$filename" -thumbnail '150x150>' -unsharp 0x.5 "${THUMBNAILS_DIRNAME}/${filename}.${THUMBNAILS_FORMAT}"
        fi
      else
        if [[ "$IMAGICK_WEBP" = [yY] ]]; then
          if [[ "$GM_USE" != [yY] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -quality "$IMAGICK_QUALITY" \
            -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
            "mpr:$filename"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS} -resize ${MAXRES}x${MAXRES}\> "${filename}.${extension}.webp""
            $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -quality "$IMAGICK_QUALITY" \
            -write "mpr:$filename" -resize ${MAXRES}x${MAXRES}\> -write "${fileout}" +delete \
            "mpr:$filename"${IMAGICK_WEBPTHREADSOPTS}${IMAGICK_WEBPOPTS} -resize ${MAXRES}x${MAXRES}\> "${filename}.${extension}.webp"
          fi
        else
          echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -quality "$IMAGICK_QUALITY" -resize ${MAXRES}x${MAXRES}\> "${fileout}""
          $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -quality "$IMAGICK_QUALITY" -resize ${MAXRES}x${MAXRES}\> "${fileout}"
        fi
      sar_call
      fi
      elif [[ "$IMAGICK_RESIZE" = [nN] ]]; then
        if [[ "$IMAGICK_WEBP" = [yY] ]]; then
          if [[ "$GM_USE" != [yY] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -quality "$IMAGICK_QUALITY" "${filename}.${extension}.webp""
            $NICE $NICEOPT $IONICE $IONICEOPT ${CONVERT_BIN}${DEFINE_TMP} "${file}"${INTERLACE_OPT}${STRIP_OPT}${ADDCOMMENT_OPT} -quality "$IMAGICK_QUALITY" "${filename}.${extension}.webp"
          fi
        sar_call
        fi
      fi
      if [[ "$extension" = 'png' ]]; then
      if [[ "$OPTIPNG" = [yY] && "$ZOPFLIPNG" = [yY] ]]; then
        echo "$NICE $NICEOPT $IONICE $IONICEOPT optipng -o${OPTIPNG_COMPRESSION} "${filein}" -preserve -out "${filename}.optipng.png""
        $NICE $NICEOPT $IONICE $IONICEOPT optipng -o${OPTIPNG_COMPRESSION} "${filein}" -preserve -out "${filename}.optipng.png" 2>&1 | grep '^Output' 
        sar_call

        echo "$NICE $NICEOPT $IONICE $IONICEOPT zopflipng${ZOPFLIPNG_OPTS} "${filein}" "${filename}.zopflipng.png""
        $NICE $NICEOPT $IONICE $IONICEOPT zopflipng${ZOPFLIPNG_OPTS} "${filein}" "${filename}.zopflipng.png"
        sar_call
      elif [[ "$OPTIPNG" = [yY] && "$ZOPFLIPNG" = [nN] ]]; then
        echo "$NICE $NICEOPT $IONICE $IONICEOPT optipng -o${OPTIPNG_COMPRESSION} "${filein}" -preserve -out "${fileout}""
        $NICE $NICEOPT $IONICE $IONICEOPT optipng -o${OPTIPNG_COMPRESSION} "${filein}" -preserve -out "${fileout}" 2>&1 | grep '^Output' 
        sar_call
      elif [[ "$ZOPFLIPNG" = [yY] && "$OPTIPNG" = [nN] ]]; then
        echo "$NICE $NICEOPT $IONICE $IONICEOPT zopflipng${ZOPFLIPNG_OPTS} "${filein}" "${fileout}""
        $NICE $NICEOPT $IONICE $IONICEOPT zopflipng${ZOPFLIPNG_OPTS} "${filein}" "${fileout}"
        sar_call
      fi
      elif [[ "$extension" = 'jpg' || "$extension" = 'jpeg' ]]; then
      # if set JPEGOPTIM='y' and GUETZLI='y' simultaneously, save Guetzli copy to separate file
      # to be able to compare with JPEGOPTIM optimised files
      if [[ "$MOZJPEG" = [yY] && "$JPEGOPTIM" = [yY] && "$GUETZLI" = [yY] ]]; then
        if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" --stdout "${filein}" > "${fileout}""
          $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" --stdout "${filein}" > "${fileout}"
          sar_call
          # copy and overwrite filename as jpegoptim errors out if you with stdout method
          mv -f "${fileout}" "${jfilein}"
          sar_call
        else
          echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" "${filein}""
          $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" "${filein}"
          sar_call
        fi

        echo "$NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filein}" "${filename}.guetzli.jpg""
        $NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filein}" "${filename}.guetzli.jpg"
        sar_call

        echo "$NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.mozjpeg.jpg" "${filein}""
        $NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.mozjpeg.jpg" "${filein}"
        sar_call
      elif [[ "$MOZJPEG" = [yY] && "$JPEGOPTIM" = [yY] && "$GUETZLI" = [nN] ]]; then
        if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" --stdout "${filein}" > "${fileout}""
          $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" --stdout "${filein}" > "${fileout}"
          sar_call
          # copy and overwrite filename as jpegoptim errors out if you with stdout method
          mv -f "${fileout}" "${jfilein}"
          sar_call
        else
          echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" "${filein}""
          $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" "${filein}"
          sar_call
        fi

        echo "$NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.mozjpeg.jpg" "${filein}""
        $NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.mozjpeg.jpg" "${filein}"
        sar_call
      elif [[ "$MOZJPEG" = [yY] && "$JPEGOPTIM" = [nN] && "$GUETZLI" = [nN] ]]; then
        echo "$NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${fileout}" "${fileout}""
        $NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${fileout}" "${fileout}"
        sar_call
      elif [[ "$MOZJPEG" = [nN] && "$JPEGOPTIM" = [yY] && "$GUETZLI" = [yY] ]]; then
        if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" --stdout "${filein}" > "${fileout}""
          $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" --stdout "${filein}" > "${fileout}"
          sar_call
          # copy and overwrite filename as jpegoptim errors out if you with stdout method
          mv -f "${fileout}" "${jfilein}"
          sar_call
        else
          echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" "${filein}""
          $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" "${filein}"
          sar_call
        fi

        echo "$NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filein}" "${filename}.guetzli.jpg""
        $NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filein}" "${filename}.guetzli.jpg"
        sar_call
      elif [[ "$MOZJPEG" = [nN] && "$JPEGOPTIM" = [yY] && "$GUETZLI" = [nN] ]]; then
        if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" --stdout "${filein}" > "${fileout}""
          $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" --stdout "${filein}" > "${fileout}"
          sar_call
          # copy and overwrite filename as jpegoptim errors out if you with stdout method
          mv -f "${fileout}" "${jfilein}"
          sar_call
        else
          echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" "${filein}""
          $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$IMAGICK_QUALITY" "${filein}"
          sar_call
        fi
      elif [[ "$MOZJPEG" = [nN] && "$GUETZLI" = [yY] && "$JPEGOPTIM" = [nN] ]]; then
        echo "$NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filein}" "${fileout}""
        $NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filein}" "${fileout}"
        sar_call
      fi
      fi

      # check thumbnail image info
      tn_file=$(basename "${THUMBNAILS_DIRNAME}/${filename}.${THUMBNAILS_FORMAT}")
      tn_extension="${tn_file##*.}"
      tn_filename="${tn_file%.*}"
      if [[ "$THUMBNAILS" = [yY] ]]; then
      echo "pushd ${THUMBNAILS_DIRNAME}"
      pushd ${THUMBNAILS_DIRNAME}
      if [[ "$tn_extension" = 'png' ]]; then
        if [[ "$OPTIPNG" = [yY] && "$ZOPFLIPNG" = [yY] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT optipng -o${OPTIPNG_COMPRESSION} "${filename}.${THUMBNAILS_FORMAT}" -preserve -out "${filename}.optipng.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT optipng -o${OPTIPNG_COMPRESSION} "${filename}.${THUMBNAILS_FORMAT}" -preserve -out "${filename}.optipng.${THUMBNAILS_FORMAT}" 2>&1 | grep '^Output' 
          sar_call

          echo "$NICE $NICEOPT $IONICE $IONICEOPT zopflipng${ZOPFLIPNG_OPTS} "${filename}.${THUMBNAILS_FORMAT}" "${filename}.zopflipng.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT zopflipng${ZOPFLIPNG_OPTS} "${filename}.${THUMBNAILS_FORMAT}" "${filename}.zopflipng.${THUMBNAILS_FORMAT}"
          sar_call
        elif [[ "$OPTIPNG" = [yY] && "$ZOPFLIPNG" = [nN] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT optipng -o${OPTIPNG_COMPRESSION} "${filename}.${THUMBNAILS_FORMAT}" -preserve -out "${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT optipng -o${OPTIPNG_COMPRESSION} "${filename}.${THUMBNAILS_FORMAT}" -preserve -out "${filename}.${THUMBNAILS_FORMAT}" 2>&1 | grep '^Output' 
          sar_call
        elif [[ "$ZOPFLIPNG" = [yY] && "$OPTIPNG" = [nN] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT zopflipng${ZOPFLIPNG_OPTS} "${filename}.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT zopflipng${ZOPFLIPNG_OPTS} "${filename}.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}"
          sar_call
        fi
      elif [[ "$tn_extension" = 'jpg' || "$tn_extension" = 'jpeg' ]]; then
        # if set JPEGOPTIM='y' and GUETZLI='y' simultaneously, save Guetzli copy to separate file
        # to be able to compare with JPEGOPTIM optimised files
        if [[ "$MOZJPEG" = [yY] && "$JPEGOPTIM" = [yY] && "$GUETZLI" = [yY] ]]; then
          if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" --stdout "${filename}.${THUMBNAILS_FORMAT}" > "${filename}.${THUMBNAILS_FORMAT}""
            $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" --stdout "${filename}.${THUMBNAILS_FORMAT}" > "${filename}.${THUMBNAILS_FORMAT}"
            sar_call
          else
            echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" "${filename}.${THUMBNAILS_FORMAT}""
            $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" "${filename}.${THUMBNAILS_FORMAT}"
            sar_call
          fi

          echo "$NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filename}.${THUMBNAILS_FORMAT}" "${filename}.guetzli.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filename}.${THUMBNAILS_FORMAT}" "${filename}.guetzli.${THUMBNAILS_FORMAT}"
          sar_call

          echo "$NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.mozjpeg.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.mozjpeg.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}"
          sar_call
        elif [[ "$MOZJPEG" = [yY] && "$JPEGOPTIM" = [yY] && "$GUETZLI" = [nN] ]]; then
          if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" --stdout "${filename}.${THUMBNAILS_FORMAT}" > "${filename}.${THUMBNAILS_FORMAT}""
            $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" --stdout "${filename}.${THUMBNAILS_FORMAT}" > "${filename}.${THUMBNAILS_FORMAT}"
            sar_call
          else
            echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" "${filename}.${THUMBNAILS_FORMAT}""
            $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" "${filename}.${THUMBNAILS_FORMAT}"
            sar_call
          fi

          echo "$NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.mozjpeg.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.mozjpeg.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}"
          sar_call
        elif [[ "$MOZJPEG" = [yY] && "$JPEGOPTIM" = [nN] && "$GUETZLI" = [nN] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT $MOZJPEG_BIN"${MOZJPEG_QUALITY}" "$MOZJPEG_OPTS" -outfile "${filename}.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}"
          sar_call
        elif [[ "$MOZJPEG" = [nN] && "$JPEGOPTIM" = [yY] && "$GUETZLI" = [yY] ]]; then
          if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" --stdout "${filename}.${THUMBNAILS_FORMAT}" > "${filename}.${THUMBNAILS_FORMAT}""
            $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" --stdout "${filename}.${THUMBNAILS_FORMAT}" > "${filename}.${THUMBNAILS_FORMAT}"
            sar_call
          else
            echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" "${filename}.${THUMBNAILS_FORMAT}""
            $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" "${filename}.${THUMBNAILS_FORMAT}"
            sar_call
          fi

          echo "$NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filename}.${THUMBNAILS_FORMAT}" "${filename}.guetzli.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filename}.${THUMBNAILS_FORMAT}" "${filename}.guetzli.${THUMBNAILS_FORMAT}"
          sar_call       
        elif [[ "$MOZJPEG" = [nN] && "$JPEGOPTIM" = [yY] && "$GUETZLI" = [nN] ]]; then
          if [[ "$IMAGICK_RESIZE" = [nN] ]]; then
            echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" --stdout "${filename}.${THUMBNAILS_FORMAT}" > "${filename}.${THUMBNAILS_FORMAT}""
            $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" --stdout "${filename}.${THUMBNAILS_FORMAT}" > "${filename}.${THUMBNAILS_FORMAT}"
            sar_call
          else
            echo "$NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" "${filename}.${THUMBNAILS_FORMAT}""
            $NICE $NICEOPT $IONICE $IONICEOPT jpegoptim${JPEGOPTIM_PROGRESSIVE} -p --max="$THUMBNAILS_QUALITY" "${filename}.${THUMBNAILS_FORMAT}"
            sar_call
          fi
        elif [[ "$MOZJPEG" = [nN] && "$GUETZLI" = [yY] && "$JPEGOPTIM" = [nN] ]]; then
          echo "$NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filename}.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}""
          $NICE $NICEOPT $IONICE $IONICEOPT $GUETZLI_BIN --quality "$GUETZLI_QUALITY" "$GUETZLI_OPTS" "${filename}.${THUMBNAILS_FORMAT}" "${filename}.${THUMBNAILS_FORMAT}"
          sar_call
        fi
      fi
      popd
      fi
      # end optimisation routines
    fi # IS_OPTIMISED != optimised
  done
  echo "------------------------------------------------------------------------------"
  }
  endtime=$(TZ=UTC date +%s.%N)
  processtime=$(echo "scale=2;$endtime - $starttime"|bc)
  #echo "Completion Time: $(printf "%0.2f\n" $processtime) seconds"
  #echo "------------------------------------------------------------------------------"
  fi
}

###############
case "$1" in
  optimise)
    DIR=$2
    if [ -d "$DIR" ] || [ -f "$DIR" ]; then
      optimiser "$DIR"      
    fi
    ;;
  install)
    install_source
    guetzli_install
    mozjpeg_install
    butteraugli_install
    ;;
    *)
    echo "$0 {optimise} /PATH/TO/DIRECTORY/WITH/IMAGES"
    echo "$0 {install} /PATH/TO/DIRECTORY/WITH/IMAGES"
    ;;
esac

exit
