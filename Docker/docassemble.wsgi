import os, site
import docassemble.webapp.config
docassemble.webapp.config.load(filename="/usr/share/docassemble/config.yml")
os.environ["PYTHONUSERBASE"] = docassemble.webapp.config.daconfig.get('packages', "/usr/share/docassemble/local")
os.environ["XDG_CACHE_HOME"] = docassemble.webapp.config.daconfig.get('packagecache', "/var/www/.cache")
site.addusersitepackages("") 
from docassemble.webapp.server import app as application
