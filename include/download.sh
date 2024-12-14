# sqlite version: 3.47.2
wget -O sqlite.zip \
    https://www.sqlite.org/2024/sqlite-amalgamation-3470200.zip
unzip sqlite.zip
mv -f sqlite-amalgamation*/ sqlite-amalgamation/
mv -f sqlite-amalgamation/sqlite3.c sqlite-amalgamation/sqlite3.h .
rm -r sqlite-amalgamation/
rm -r sqlite.zip
