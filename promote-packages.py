#!/usr/bin/python
from optparse import OptionParser
import sys
import os
import commands

uid = os.getuid()

if uid != 0:
  print "This program must be run with root privs"
  sys.exit(1)

parser = OptionParser()
parser.add_option("-s", "--source", dest="source",
                  help="Source distribution to promote from; Example: precise")
parser.add_option("-d", "--dest", dest="dest",
                  help="Destination repository to promote to; Example: eucalyptus", default="eucalyptus")
parser.add_option("-r", "--release", dest="release",
                  help="Destination release to promote to; Example: 3.1")
parser.add_option("-f", "--srepo", dest="srepo",
                  help="Repository to promote from; Example: ubuntu", default="ubuntu")
parser.add_option("-t", "--drepo", dest="drepo",
                  help="Repository to promote to; Example: ubuntu", default="ubuntu")
parser.add_option("-z", "--ddist", dest="ddist",
                  help="Distribution to promote to; Example: precise")
parser.add_option("-p", "--promote", dest="promote", action="store_true",
                  help="As opposed to just listing a candidate, promote it", default=False)
parser.add_option("-b", "--binary", dest="binary", action="store_true",
                  help="Only promote binaries and not the source code", default=False)
parser.add_option("-n", "--package", dest="package",
                  help="Which source package you would like to list or promote", default="eucalyptus")
parser.add_option("-v", "--version", dest="version",
                  help="Which source package version you would like to promote")
(options, args) = parser.parse_args()

#Check for required arguments
if not options.source:
  print "You must provide a distribution to promote from. (-s)"
  sys.exit(0)
if options.promote and not options.release:
  print "You must provide a release to promote to. (-r)"
  sys.exit(0)
if options.promote and not options.ddist:
  print "You must provide a distribution to promote to. (-z)"
  sys.exit(0)

#Set build repo information
srepo_prefix = "/srv/build-repo/repository/release/"
srepo_suffix = options.srepo
srepo = srepo_prefix + srepo_suffix

#Change dir to build repo
if not os.path.isdir(srepo):
  print "You have specified an invalid source repository. (-f)"
  sys.exit(1)
os.chdir(srepo)

#If we are not promoting,  just list the latest version available for promotion
if not options.promote:
  output = commands.getoutput("reprepro list " + options.source + " " + options.package)
  print output
  sys.exit(0)

#Set promotion repo information
drepo_prefix = "/srv/software/releases/"
drepo_suffix = options.dest + "/" + options.release + "/" + options.drepo
drepo = drepo_prefix + drepo_suffix

#If no version is specified, use the latest
version = options.version
if not version:
  status,output = commands.getstatusoutput("reprepro list " + options.source + " " + options.package)
  if status != 0:
    print output
    sys.exit(1)
  version = output.split(" ")[-1]

#If a package name begins with lib, lib + the first letter of the package name
#is used to store it.  Otherwise, just the first letter of the package name is
pool_prefix = ""
if options.package.startswith("lib"):
  pool_prefix = options.package[0:4]
else:
  pool_prefix = options.package[0:1]

#Get the debs needed for promotion
files = []
pool_dir = srepo + "/pool/main/" + pool_prefix + "/" + options.package + "/"
#Check to see if the specified version exists
dsc_file = pool_dir + options.package + "_" + version + ".dsc"
if not os.path.isfile(dsc_file):
  print "You have specified a version for which no source package exists"
  sys.exit(1)
data = os.listdir(pool_dir)
for fname in data:
  if fname.endswith(".deb") and (fname.count(version) == 1):
    files.append(fname)

os.chdir(drepo)

#promote the binary packages
for fname in files:
  retval = os.system("reprepro includedeb " + options.ddist + " " + pool_dir + fname)
  if retval != 0:
    print "There was a problem promoting " + fname + " - ABORTING!"
    sys.exit(1)

#promote the source package as well
if not options.binary:
  retval = os.system("reprepro includedsc " + options.ddist + " " + dsc_file)
  if retval != 0:
    print "An error with the source package promotion has occurred!"
  else:
    print dsc_file + " has been promoted successfully"
