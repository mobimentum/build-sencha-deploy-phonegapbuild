#!/bin/bash

# 8p8@Mobimentum 2013-09-04 Build a Sencha app and publish repo to user PhoneGapBuild

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

### Config ###

# PhoneGap Build basic auth (include ":" at the end with no password)
PGB_AUTH_USER="youruser@yourdomain.com:"

# PhoneGap Build auth token 
PGB_AUTH_TOKEN=""

# JSON.sh, cfr. https://github.com/dominictarr/JSON.sh
JSON_SH="$(dirname $0)/JSON.sh"

# XMLLint is in package libxml2-utils (Debian)
XMLLINT="$(which xmllint)"

# Sencha CMD
SENCHA_CMD="/opt/sencha-cmd"

### Script ###

# Compile
$SENCHA_CMD app build package
status=$?

# Add config.xml and zip content
app=$(grep -P '^\s*app.name=' .sencha/app/sencha.cfg | awk -F'=' '{print $2}')
cp config.xml "build/package/$app/"
cd "build/package/$app"
zip -r "${app}.zip" *

# Check if app is already uploaded to PG:B
# cfr. https://build.phonegap.com/docs/read_api
app_pkg="$($XMLLINT --xpath "/*[local-name()='widget']/@id" config.xml | sed 's/\(^ id=\"\|\"$\)//g')"
app_id=$(curl -u "$PGB_AUTH_USER" "https://build.phonegap.com/api/v1/apps?auth_token=$PGB_AUTH_TOKEN" \
	| $JSON_SH -b | grep -E '\["apps",([0-9]+),"(package|id)"\]' \
	| grep -A 1 "$app_pkg" | tail -n 1 | awk -F'\t' '{print $2}')

# Upload app
# cfr. https://build.phonegap.com/docs/write_api
if [[ ! -z "$app_id" ]]
then
	# App already uploaded
	curl -u "$PGB_AUTH_USER" -X PUT -F "file=@${app}.zip" \
		"https://build.phonegap.com/api/v1/apps/$app_id?auth_token=$PGB_AUTH_TOKEN"
else
	# New app
	# Upload to PG:B
	curl -u "$PGB_AUTH_USER" -F "file=@${app}.zip" -F "data={\"title\":\"$app\",\"create_method\":\"file\"}" \
		"https://build.phonegap.com/api/v1/apps?auth_token=$PGB_AUTH_TOKEN"
fi

# TODO: improve status detection
exit $status
