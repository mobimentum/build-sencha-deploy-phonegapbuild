#!/bin/bash

# 8p8@Mobimentum 2013-09-04 Publish app to PhoneGapBuild

### Config ###

# PhoneGap Build basic auth (include ":" at the end with no password)
PGB_AUTH_USER="your.user@mobimentum.it:"

# PhoneGap Build auth token 
PGB_AUTH_TOKEN="THIS-IS-YOUR-TOKEN"

# JSON.sh, cfr. https://github.com/dominictarr/JSON.sh
JSON_SH="$(dirname $0)/JSON.sh"

# XMLLint is in package libxml2-utils (Debian)
XMLLINT="$(which xmllint)"

### Script ###

status=0

# Zip content
app="www"
cd "www"
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
if [[ $status -eq 0 ]]; then status=$?; fi

exit $status
