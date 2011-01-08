export ZANG_ZING_HOME="$PWD"


export MAGICK_HOME="$ZANG_ZING_HOME/../agent/lib/osx/imagemagick/ImageMagick-6.6.1"
export DYLD_LIBRARY_PATH="$MAGICK_HOME/lib:$DYLD_LIBRARY_PATH"
export PATH="$MAGICK_HOME/bin:$PATH"
export IMAGEMAGICK_PATH="$MAGICK_HOME"

open "/Applications/RubyMine 3.0.1.app"