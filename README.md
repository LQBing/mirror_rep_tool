# mirror_rep_tool

## pushimage.sh

What to do: Pull image, retag, push to tmp rep. Run in the server could pull image

Set env var `DOCKER_MIRROR_REP` into `~/.bashrc`

- `DOCKER_MIRROR_REP` The transfer registry image name. If the transfer registry need login, do not forget `docker login` (https://docs.docker.com/reference/cli/docker/login/)

```shell
echo "export DOCKER_MIRROR_REP=<transfer registry>/<namespace>/<imagename>" >> ~/.bashrc
source ~/.bashrc
```

Install pushimage

```shell
sudo curl -Lo /usr/local/bin/pushimage https://raw.githubusercontent.com/LQBing/mirror_rep_tool/main/pushimage.sh
sudo chmod +x /usr/local/bin/pushimage
```

or 

```shell
git clone https://github.com/LQBing/mirror_rep_tool.git
cd mirror_rep_tool
cp pushimage.sh /usr/local/bin/pushimage
sudo chmod +x /usr/local/bin/pushimage
```

Push image to mirror repo

```shell
pushimage mongo:5.0
```

## pullimage.sh

What to do: pull image from tmp rep, retag. Run in the server could not pull image

Set env var `DOCKER_MIRROR_REP` into `~/.bashrc`

- `DOCKER_MIRROR_REP` The transfer registry image name. If the transfer registry need login, do not forget `docker login` (https://docs.docker.com/reference/cli/docker/login/)

- `DOCKER_TRANSPORT_SERVER_HOST` If not set, will not try to push image in transport server. Do not forget set rsa key for access it. (https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)

```shell
echo "export DOCKER_MIRROR_REP=<transfer registry>/<namespace>/<imagename>" >> ~/.bashrc
echo "export DOCKER_TRANSPORT_SERVER_HOST=<your transport server host>" >> ~/.bashrc
source ~/.bashrc
```

Install pullimage

```shell
sudo curl -Lo /usr/local/bin/pullimage https://raw.githubusercontent.com/LQBing/mirror_rep_tool/main/pullimage.sh
sudo chmod +x /usr/local/bin/pullimage
```

or 

```shell
git clone https://github.com/LQBing/mirror_rep_tool.git
cd mirror_rep_tool
cp pullimage.sh /usr/local/bin/pullimage
sudo chmod +x /usr/local/bin/pullimage
```

Pull image

```shell
bash pullimage.sh mongo:5.0
```

## Clean images

Your server disk is limited, sometime you need clean it.

remove images

```shell
docker rmi mongo:5.0
docker rmi <yourrep>/<namespace>/<imagename>:library_mongo_5.0
```

or just clean all

```shell
docker system prune -af
```
