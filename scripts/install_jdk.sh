#!/bin/bash

echo "$PWD" > /var/log/install_jdk.out 2>&1

set -e

SERIES=${1:-8}

if [ "$EUID" -ne 0 ]; then
  echo "Run this script as root"
  exit 1
fi

HERE=$(dirname "$(readlink -f "$0")")
. "$HERE/config$SERIES"

function install-bin()
{
	NAME=$1
	DIR=$2
	if [ -f "$BASE/$ALIAS/man/man1/$NAME.1" ]; then
		update-alternatives --quiet \
			--install "/usr/bin/$NAME" "$NAME" "$BASE/$ALIAS/$DIR/$NAME" 100 \
			--slave "/usr/share/man/man1/$NAME.1" "$NAME.1" "$BASE/$ALIAS/man/man1/$NAME.1"
	else
		update-alternatives --quiet \
			--install "/usr/bin/$NAME" "$NAME" "$BASE/$ALIAS/$DIR/$NAME" 100
	fi
}

function install-lib()
{
	NAME=$1
	SRC=$2
	LOCATION=$3
	update-alternatives --quiet \
		--install "$LOCATION" "$NAME" "$BASE/$ALIAS/jre/lib/amd64/$SRC" 100
}

if [ ! -d "$BASE/$DIR" ]; then
	cd /tmp

	# Download
	echo "start downloading..."
	if [ ! -f "$ARCHIVE.tar.gz" ]; then
		wget --no-check-certificate --continue \
			--header "Cookie: oraclelicense=accept-securebackup-cookie" \
			"http://download.oracle.com/otn-pub/java/jdk/$SITE/$ARCHIVE.tar.gz"
	fi

	# Extract
	echo "start extracting..."
	cd /tmp
	tar xzvf "$ARCHIVE.tar.gz"

	# Move
	echo "move!!!"
	mkdir -p "$BASE"
	mv "$DIR" "$BASE"
	chown -R root:root "$BASE/$DIR"

	# Write to the file path
	echo "write to the file path"
	echo 'export PATH=$PATH:/$BASE/$DIR/bin' >>  ~/.bashrc
	#echo 'export PATH=$PATH:/$BASE/$DIR/bin' >> ~/.bash_profile
fi

# Alias
rm -f "$BASE/$ALIAS"
cd "$BASE"
ln -sf "$DIR" "$ALIAS"

# Generate jinfo

JINFO="$BASE/.$ALIAS.jinfo"
rm -f "$JINFO"

# Header
echo "name=$ALIAS" >> "$JINFO"
echo "priority=1000" >> "$JINFO"
echo "section=main" >> "$JINFO"
echo "" >> "$JINFO"

# JRE items
if [ -d "$BASE/$ALIAS/jre" ]; then
	for NAME in "$BASE/$ALIAS/jre/bin/"*; do
		BASENAME=$(basename "$NAME")
		echo "jre $BASENAME $NAME" >> "$JINFO"
	done

	# An extra JRE item in lib
	echo "jre jexec /usr/lib/jvm/$ALIAS/jre/lib/jexec" >> "$JINFO"

	# Plugin items
	echo "plugin mozilla-javaplugin.so /usr/lib/jvm/$ALIAS/jre/lib/amd64/libnpjp2.so" >> "$JINFO"

	install-bin jexec jre/lib

	for NAME in "$BASE/$ALIAS/jre/bin/"*; do
		install-bin $(basename "$NAME") jre/bin
	done

	if [ -d /usr/lib/xulrunner-addons/plugins ]; then
		install-lib xulrunner-1.9-javaplugin.so libnpjp2.so /usr/lib/xulrunner-addons/plugins/libjavaplugin.so
	fi
	if [ -d /usr/lib/mozilla/plugins ]; then
		install-lib mozilla-javaplugin.so libnpjp2.so /usr/lib/mozilla/plugins/libjavaplugin.so
	fi
fi

# JDK items
for NAME in "$BASE/$ALIAS/bin/"*; do
	BASENAME=$(basename "$NAME")
	# Make sure it is not already listed as a JRE item
	if [ ! -f "$BASE/$ALIAS/jre/bin/$BASENAME" ]; then
		echo "jdk $BASENAME $NAME" >> "$JINFO"
	fi
done

for NAME in "$BASE/$ALIAS/bin/"*; do
	install-bin $(basename "$NAME") bin
done

update-java-alternatives -s "$ALIAS"

echo "Done!"
