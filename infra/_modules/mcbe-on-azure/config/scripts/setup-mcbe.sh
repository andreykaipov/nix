#!/bin/sh

set -eu

: "${server_name?}"
: "${level_name?}"
: "${backup_dir?}"
: "${bedrock_bridge_token:=}"

if ! [ -d /opt/MCscripts ]; then
        echo "Setting up MCscripts..."
        rm -rf /tmp/MCscripts-master
        curl -sLo /tmp/master.tgz https://github.com/TapeWerm/MCscripts/archive/refs/heads/master.tar.gz
        tar xfvz /tmp/master.tgz -C /tmp
        /tmp/MCscripts-master/src/install.sh >/dev/null 2>&1
fi

# use our mounted managed disk as the backup dir to persist backups
# we run a backup any time
echo "Using $backup_dir as backup directory"
ln -snf "$backup_dir" /opt/MCscripts/backup_dir

echo "Setting up server..."
echo y | su mc -s /bin/bash -c '/opt/MCscripts/bin/mcbe_getzip.py'
if ! [ -d ~mc/bedrock/server ]; then
        /opt/MCscripts/bin/mcbe_setup.py server 2>&1
fi

echo "Replacing default server files"
cp -r /tmp/config/server/* ~mc/bedrock/server
sed -i -E "
        s/^(server-name=).+$/\1$server_name/;
        s/^(level-name=).+$/\1$level_name/;
" ~mc/bedrock/server/server.properties

if [ -n "$bedrock_bridge_token" ]; then
        echo "Setting up bedrock bridge"
        sed -i -E "s/0000/$bedrock_bridge_token/" ~mc/bedrock/server/config/default/secrets.json
fi

# if this is a new server with no worlds, try to find the latest backup for our
# specified world from our mounted managed disk and restore it if it exists
if [ -d ~mc/bedrock/server/worlds ]; then
        echo "Worlds directory already exists, skipping restore"
else
        echo "Restoring world $level_name from backup"
        world_zip=$(
                find "$backup_dir" -type f -path "*$level_name*" -exec stat --format '%Y :%y %n' "{}" \; |
                        sort -nr |
                        awk '{print $NF}' |
                        head -n1
        )
        if [ -r "$world_zip" ]; then
                # the server should not be running
                echo "Found backup $world_zip, restoring..."
                echo y | /opt/MCscripts/bin/mcbe_restore.py ~mc/bedrock/server "$world_zip" 2>&1
        fi
fi

echo "Starting services"
systemctl enable mcbe@server.socket mcbe@server.service mcbe-backup@server.timer --now
systemctl enable mcbe-getzip.timer mcbe-autoupdate@server.service --now
systemctl enable mcbe-rmbackup@server.service --now

# restarting here is only necessary for subsequent tf applies
echo "Restarting server"
systemctl restart mcbe@server.service
