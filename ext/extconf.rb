require 'mkmf'

abort 'need stdio.h' unless have_header("stdio.h")

$CFLAGS = "-Wall -O3"

dir_config('ansible')
create_makefile('ansible')
