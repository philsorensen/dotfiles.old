# maintained by dotfiles - changes will be overwritten
#
# Change sys.path from python based on https://gist.github.com/817737
#
# For a method based on the way activate_this.py and mod_wsgi virtual section
# see:
# http://igotgenes.blogspot.com/2010/01/interactive-sandboxes-using-ipython.html
#

import sys
import subprocess
from os import environ
 
if 'VIRTUAL_ENV' in environ:
    # This is kludgy but it works;
    # grab the right sys.path from the virtualenv python install:
    path = subprocess.Popen(['python', '-c','import sys;print(repr(sys.path))'],
                            stdout=subprocess.PIPE).communicate()[0]
    sys.path = eval(path)
    del path

    print("\nVIRTUAL_ENV -> " + environ.get('VIRTUAL_ENV'))

del sys, subprocess, environ


## Activate virtual environment in iPython using activate_this.py created by
## virtualenv
##
#
#from os import environ
#from os.path import join
#
#if 'VIRTUAL_ENV' in environ:
#    activate_file = join(environ.get('VIRTUAL_ENV'), 'bin', 'activate_this.py')
#
#    execfile(activate_file,dict(__file__=activate_file))
#    print("\nVIRTUAL_ENV -> '" + environ.get('VIRTUAL_ENV') + "'")
#
#del environ, join
