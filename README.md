# my-awesome

Git-based bookmarking tool powered by GitHub actions, integrated with Telegram, built with Hugo and hosted on GitHub pages

* [Demo](https://my-awesome.github.io/my-awesome-template)
* [myawesome.dev](https://myawesome.dev)

> why ???

* Ask HN: [Do you curate links/bookmarks?](https://news.ycombinator.com/item?id=22158218)
* Ask HN: [How do you manage your bookmarks?](https://news.ycombinator.com/item?id=22105561)
* Ask HN: [Does anybody still use bookmarking services?](https://news.ycombinator.com/item?id=31848210)
* See [Web Archiving Community](https://github.com/ArchiveBox/ArchiveBox/wiki/Web-Archiving-Community) for alternatives

## How it works

> TODO for now you must have your own bot

Rules:
* every multi-line text is evaluated independently
* the order of the content doesn't matter
* a message must contains a valid **url** or it will be ignored i.e. a word that starts with `http`
* if a line contains a word starting with *ampersand* it will be used as **source** e.g. `&hackernews`
    - optional, default path is `unknown`
    - you can define one source: only the first one is used
* if a line contains a word starting with *underscore* it will be used as **path** e.g. `_folder_subfolder`
    - optional, default path is `/random`
    - you can define one path: only the first one is used
* if a line contains a word starting with *hash* it will be used as **tag** e.g. `#mytag`
    - optional, default is empty
    - you can define multiple tags

## Setup

> TODO

1. [Use this template](https://github.com/my-awesome/my-awesome-template/generate)
2. create telegram bot
3. save env (show how to retrieve user_id)
4. diagram

## Development

See [my-awesome/actions](https://github.com/my-awesome/actions)

### Hugo

Resources
* [Hugo](https://gohugo.io/documentation)
* [20 Minute Hugo](https://www.youtube.com/playlist?list=PLbWvcwWtuDm1OpcbohZTOwwzmc8SMmlBD) (video)
* [Hugo GitHub Action](https://github.com/marketplace/actions/hugo-setup)

```bash
sudo snap install hugo --channel=extended

# generate hugo skeleton
hugo new site . --force

# run locally
# http://localhost:1313
hugo server -D
```
