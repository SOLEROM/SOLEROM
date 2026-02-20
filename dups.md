# compare

* local:
```
grep -oP 'https://github\.com/SOLEROM/\K[^[:space:]]+' readme.md \
| cut -d')' -f1 \
| grep -vE '^(snippet/tree/master)$' \
| tr '[:upper:]' '[:lower:]' \
| sort -u >> /tmp/repos1

```

* web:

```
./listRepos.sh >> /tmp/repos2
```