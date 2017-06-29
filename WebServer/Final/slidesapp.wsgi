#!/usr/bin/python
import sys
import logging
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0,"/var/www/slidesapp/")

from slidesapp import app as application
application.secret_key = 'secret_key'
