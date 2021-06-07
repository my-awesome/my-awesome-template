# my-awesome

## Resources

* [Hugo](https://gohugo.io/documentation)
* [20 Minute Hugo](https://www.youtube.com/playlist?list=PLbWvcwWtuDm1OpcbohZTOwwzmc8SMmlBD) (video)
* [GitHub Actions](https://docs.github.com/en/actions)
* [Starter Workflows](https://github.com/actions/starter-workflows)
* [GitHub CLI](https://cli.github.com/manual)
* [Telegram Bot API](https://core.telegram.org/bots/api#getupdates)

## Development

Hugo
```bash
# generate hugo skeleton
hugo new site . --force

# run locally
# http://localhost:1313
hugo server -D
```

Telegram
```bash
# an update is considered confirmed as soon as getUpdates
# is called with an offset higher than the latest update_id
http https://api.telegram.org/bot<TELEGRAM_API_TOKEN>/getUpdates?offset=<TELEGRAM_OFFSET>

# invoke manully (uncomment "source")
.github/scripts/telegram.sh
# requires
cat telegram.secrets 
#DATA_PATH="./data/telegram.json"
#TIMESTAMP=$(date +%Y%m%d-%H%M%S)
#TELEGRAM_API_TOKEN=
#TELEGRAM_FROM_ID=
```
