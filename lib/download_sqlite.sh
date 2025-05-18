#!/usr/bin/env sh

SQLITE_VERSION="3.49.2"

# Download Sqlite c amalgamation
wget -O sqlite.zip \
    https://www.sqlite.org/2025/sqlite-amalgamation-3490200.zip

# Extract 
unzip sqlite.zip
mv -f sqlite-amalgamation*/ sqlite-amalgamation/
mv -f sqlite-amalgamation/sqlite3.c sqlite-amalgamation/sqlite3.h .
rm -r sqlite-amalgamation/
rm -r sqlite.zip
