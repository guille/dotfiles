# My dotfiles

System installation script and dotfiles symlinks.

## USAGE

```sh
git clone https://github.com/guille/dotfiles.git
cd dotfiles
./install [-s|--select]
```

## Docker

```sh
# password needs to be a classic PAT with write:packages scope
# https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
docker login ghcr.io -u guille

docker build . -t ghcr.io/guille/dotfiles:latest
docker push ghcr.io/guille/dotfiles:latest
```
