# my-awesome

Git-based bookmarking tool powered by GitHub actions, integrated with Telegram, built with Hugo and hosted on GitHub pages.

> why ???

* Ask HN: [Do you curate links/bookmarks?](https://news.ycombinator.com/item?id=22158218)
* Ask HN: [How do you manage your bookmarks?](https://news.ycombinator.com/item?id=22105561)
* See [Web Archiving Community](https://github.com/ArchiveBox/ArchiveBox/wiki/Web-Archiving-Community) for alternatives.

## Development

Resources

* [GitHub Actions](https://docs.github.com/en/actions)
* [Starter Workflows](https://github.com/actions/starter-workflows)
* [GitHub CLI](https://cli.github.com/manual)
* [Telegram Bot API](https://core.telegram.org/bots/api#getupdates)
* [Hugo](https://gohugo.io/documentation)
* [20 Minute Hugo](https://www.youtube.com/playlist?list=PLbWvcwWtuDm1OpcbohZTOwwzmc8SMmlBD) (video)
* [Hugo GitHub Action](https://github.com/marketplace/actions/hugo-setup)

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

Hugo

```bash
# generate hugo skeleton
hugo new site . --force

# run locally
# http://localhost:1313
hugo server -D
```
