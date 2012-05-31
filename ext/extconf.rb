require 'mkmf'

abort 'need stdio.h' unless have_header("stdio.h")

dir_config('ansible')
create_makefile('ansible')
