[[ -d /tmp/lhlunch ]] || mkdir -p /tmp/lhlunch
docker run -d --name lhlunch -v /tmp/lhlunch:/tmp -p 3000:3000 oddlid/lhlunch 60m
