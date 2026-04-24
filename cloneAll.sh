curl -s "https://api.github.com/users/jlschaap/repos?per_page=200" \
| grep clone_url \
| cut -d '"' -f 4 \
| xargs -L1 git clone