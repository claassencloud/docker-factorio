# docker-factorio
A Factorio headless Docker image

## Build
The build script requires 4 parameters, AWS account, AWS region, AWS ECR repo name, and Factorio version. The build script assumes the image is being pushed to AWS ECR. 

```bash
./build.sh --aws-account <account> --aws-region <region> --aws-ecr-repo <repo> --factorio-version <version>
```

## Usage
Example Docker run command:
```bash
docker run \
  -it \
  -d \
  --restart no \
  -p 34197:34197/udp \
  --name factorio \
  -v factorio-saves:/factorio/saves \
  -v factorio-write-data:/factorio/write-data \
  -e FACTORIO_GAME_PASSWORD="supersecretpassowrd" \
  factorio:latest
```
* `-it -d` leaves the interactive shell in a detatched state, it can be attached with `docker attach` to use the server console, like ``screen` or `tmux`
* The factorio-saves volume contains the saved map
  * If you want to use a local save, copy the zip file into this volume as save.zip
  * If save.zip does not exist the entrypoint script runs the command to create one before starting the server
* The factorio-write-data contains anything else that the Factorio binary writes like player daya and achievements
* It is recommended to set a game password, it is empty by default, you should also consider restricting traffic destined for the port to known source IPs
* `server-settings.json` is copied top the write-data directory before the server starts by the entrypoint script
  * Edit `server-settings.json in the volume to further customize the server
* LAN and Public sever modes are both disabled by default, this configuration is strictcly for private servers for you and your friends

## TODO
* CI
* Versioning meachanism
* Support for scenarios that use other Docker registries besides ECR
