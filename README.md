# Lichess Docker Container

Docker setup for Lichess automated build and deployment. Based on [Benediktwerner's](https://github.com/benediktwerner/lichess-docker) continuation of [BrandonE's original Lichess Docker setup](https://github.com/BrandonE/lichocker).  This is intended to be a "deploy and play" implementation, rather than a development environment.  This is targeted at self-hosting your own Lichess deployment, rather than a place to tweak and test code.

## Usage

1. Clone or download this repo and `cd` into it
2. Build the image: `docker build --tag lichess .`
3. Create and start the container:

On Linux or WSL, either run `./docker-run.sh` or the following command:
```
docker run \
    --mount type=bind,source=$HOME/dev/lichess,target=/home/lichess/projects \
    --publish 9663:9663 \
    --publish 9664:9664 \
    --publish 8212:8212 \
    --name lichess \
    --interactive \
    --tty \
    lichess
```

## Useful commands

* Stop the Docker container: `docker stop lichess`
* Restart the Docker container and attach to it: `docker start lichess --attach --interactive`
* Open a second shell in the running container: `docker exec -it lichess bash`
* Remove the Docker container (e.g. to mount a different volume): `docker rm lichess`

## License

- All code is in the public domain.
