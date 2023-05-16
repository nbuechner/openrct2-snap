#!/bin/bash
URL=$(curl -s https://api.github.com/repos/OpenRCT2/OpenRCT2/releases/latest | jq '.assets[] | select(.name|endswith("-linux-jammy-x86_64.tar.gz")) | .browser_download_url' | tr -d '"')
VERSION=$(echo $URL|cut -d'/' -f8|tr -d '-'|cut -c2-)
LOCAL_VERSION=$(cat snapcraft.yaml|grep "version: "|cut -d" " -f2)
if [[ "$VERSION" != "$LOCAL_VERSION" ]]; then
   echo "local and remove versions differ"
   echo "old version: $LOCAL_VERSION"
   echo "new version: $VERSION"
   sed -i "/^\([[:space:]]*version: \).*/s//\1$VERSION/" snapcraft.yaml
   echo "git commit -a -m 'version update: $VERSION'"
   echo "git push"
else
   echo "no update available. current version is $VERSION"
fi
#SNAPCRAFT_BUILD_ENVIRONMENT=host snapcraft --target-arch amd64