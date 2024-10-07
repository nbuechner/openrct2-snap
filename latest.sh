#!/bin/bash
URL=$(curl -s https://api.github.com/repos/OpenRCT2/OpenRCT2/releases/latest | jq '.assets[] | select(.name|endswith("-Linux-noble-x86_64.tar.gz")) | .browser_download_url' | tr -d '"')
VERSION=$(echo $URL|cut -d'/' -f8|tr -d '-'|cut -c2-)
if [[ "$VERSION" == "" ]]; then
   echo "ERROR: could not fetch latest version"
   exit 1
fi
LOCAL_VERSION=$(cat snapcraft.yaml|grep "version: "|cut -d" " -f2)
if [[ "$VERSION" != "$LOCAL_VERSION" ]]; then
   echo "local and remove versions differ"
   echo "old version: $LOCAL_VERSION"
   echo "new version: $VERSION"
   sed -i "/^\([[:space:]]*version: \).*/s//\1$VERSION/" snapcraft.yaml
   echo "git commit -a -m 'version update: $VERSION'"
   echo "git push"
   git commit -a -m 'version update: $VERSION'
   git push
   output=$(snapcraft)

   # Use grep to find the line containing the created file name, then use awk to extract the file name
   filename=$(echo "$output" | grep 'Created snap package' | awk '{print $4}')

   # Check if filename was extracted
   if [ -n "$filename" ]; then
       echo "Created file: $filename"
       snapcraft upload --release=stable $filename && rm -f $filename
   else
       echo "Failed to extract file name from snapcraft output."
   fi
else
   echo "no update available. current version is $VERSION"
fi
