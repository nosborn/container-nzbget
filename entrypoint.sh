#!/bin/bash
ln -s /app/dist/scripts/* /app/scripts/
exec /app/nzbget --configfile=/app/nzbget.conf --option=OutputMode=log --option=WriteLog=none --server "$@"
