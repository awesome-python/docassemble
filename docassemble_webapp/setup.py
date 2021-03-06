#!/usr/bin/env python

import os
from setuptools import setup, find_packages

setup(name='docassemble.webapp',
      version='0.1',
      description=('The standard web application for the docassemble system.'),
      author='Jonathan Pyle',
      author_email='jhpyle@gmail.com',
      license='MIT',
      url='http://docassemble.org',
      packages=find_packages(),
      namespace_packages = ['docassemble'],
      install_requires = ['docassemble', 'docassemble.base', 'docassemble.demo', 'beautifulsoup4', 'boto', 'celery[redis]', 'flask', 'flask-kvsession', 'flask-login', 'flask-mail', 'flask-sqlalchemy', 'flask-user', 'flask-wtf', 'pip', 'pip-utils', 'psycopg2', 'python-dateutil', 'rauth', 'requests', 'wtforms', 'setuptools', 'sqlalchemy', 'tailer', 'werkzeug', 'simplekv', 'gcs-oauth2-boto-plugin'],
      zip_safe = False,
      package_data={'docassemble.webapp': ['templates/base_templates/*.html', 'templates/flask_user/*.html', 'templates/pages/*.html', 'templates/users/*.html', 'static/app/*.*', 'static/examples/*.*', 'static/bootstrap-fileinput/img/*', 'static/bootstrap-fileinput/css/*.css', 'static/bootstrap-fileinput/js/*.js', 'static/bootstrap-fileinput/*.md', 'static/jquery-labelauty/source/*.*', 'static/jquery-labelauty/source/images/*.*', 'static/audiojs/audiojs/*.*', 'static/codemirror/lib/*.*', 'static/codemirror/mode/yaml/*.*', 'static/codemirror/mode/markdown/*.*', 'static/codemirror/mode/javascript/*.*', 'static/codemirror/mode/python/*.*', 'static/areyousure/*.js']},
     )
