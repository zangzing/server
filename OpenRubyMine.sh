export ZANG_ZING_HOME="$PWD"


export MAGICK_HOME="$ZANG_ZING_HOME/../agent/lib/osx/imagemagick/ImageMagick-6.6.1"
export DYLD_LIBRARY_PATH="$MAGICK_HOME/lib:$DYLD_LIBRARY_PATH"
export PATH="$MAGICK_HOME/bin:$PATH"
if [ -z "${IMAGEMAGICK_PATH}" ]; then export IMAGEMAGICK_PATH="$MAGICK_HOME"; fi

open "/Applications/RubyMine 3.1.app"