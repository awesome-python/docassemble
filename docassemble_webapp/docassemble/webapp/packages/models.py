from docassemble.webapp.app_and_db import db
from docassemble.webapp.config import daconfig, dbtableprefix

class Package(db.Model):
    __tablename__ = dbtableprefix + 'package'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    type = db.Column(db.Text()) #github, zip, pip
    giturl = db.Column(db.String(255), nullable=True)
    gitsubdir = db.Column(db.Text(), nullable=True)
    upload = db.Column(db.Integer(), db.ForeignKey(dbtableprefix + 'uploads.indexno', ondelete='CASCADE'))
    package_auth = db.relationship('PackageAuth', uselist=False, primaryjoin="PackageAuth.package_id==Package.id")
    version = db.Column(db.Integer(), server_default='1')
    packageversion = db.Column(db.Text())
    limitation = db.Column(db.Text())
    dependency = db.Column(db.Boolean(), nullable=False, server_default='0')
    core = db.Column(db.Boolean(), nullable=False, server_default='0')
    active = db.Column(db.Boolean(), nullable=False, server_default='1')

class PackageAuth(db.Model):
    __tablename__ = dbtableprefix + 'package_auth'
    id = db.Column(db.Integer, primary_key=True)
    package_id = db.Column(db.Integer(), db.ForeignKey(dbtableprefix + 'package.id', ondelete='CASCADE'))
    user_id = db.Column(db.Integer(), db.ForeignKey(dbtableprefix + 'user.id', ondelete='CASCADE'))
    authtype = db.Column(db.String(255), server_default='owner')

class Install(db.Model):
    __tablename__ = dbtableprefix + "install"
    id = db.Column(db.Integer(), primary_key=True)
    hostname = db.Column(db.Text())
    version = db.Column(db.Integer())
    packageversion = db.Column(db.Text())
    package_id = db.Column(db.Integer(), db.ForeignKey(dbtableprefix + 'package.id', ondelete='CASCADE'))
