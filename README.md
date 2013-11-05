build-sencha-deploy-phonegapbuild
=================================

Build an app with Sencha Cmd and deploy to PhoneGap Build.

This is a build script originally written for Gitlab CI but should be fine for whatever CI server you're using.

The script does the following:

- compile the app with sencha cmd ("app build package")
- push the "build" subdirectory to PhoneGap Build using REST APIs

If you just need the first or second part you can comment out in the script the section you don't need, it should be pretty straightforward.

HOWTO
-----

- (one-time) configure the script editing it and filling in the "### Config ###' section
- chdir to your sencha app root
- execute the script

Dependancies
------------

- JSON.sh from https://github.com/dominictarr/JSON.sh
- XMLLint from http://xmlsoft.org/xmllint.html (or libxml2-utils on Debian-based distros)
