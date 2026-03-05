
for dir in c:/project/*/* ; do
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        if [ -n "$(git status --porcelain)" ]; then
            echo "⚠️  Uncommitted changes in $dir"
            # git status --short
        else
            echo "✔️  Clean: $dir"
        fi
        cd ..
    fi
done
