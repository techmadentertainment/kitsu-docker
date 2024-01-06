# Kitsu Docker Compose

This is a Docker Compose version of [Kitsu Docker](https://github.com/cgwire/kitsu-docker).

This Compose will use e separate container for the PostregDB in order to be installed on Synology DSM 7.2


### First Installation
Some ENV variabile should be provided in order to work. Best apporach is to rename the `sample.env` to `.env` and fill the variabiles.  

```bash
$ docker compose build
```

In order to init the the ZOU DB you should run the following command:


```bash
$ docker compose run zou bash /opt/zou/init_zou.sh
```

And finally to run Kitsu:

```bash
$ docker compose up --detach
```

### Usage

URL:

Kitsu: [http://127.0.0.1:5080/](http://127.0.0.1:5080/)

Internal webmail: [http://127.0.0.1:1080/](http://127.0.0.1:1080/)

Kitsu credentials:

* login: admin@example.com
* password: mysecretpassword (or whatever you put in the `.env` file)

### Update

In order to upgrade to the latest version of Kitsu and Zoe, you need to set the Tag in the `Dockerfile` and then rebuild the image using the command:

```bash
$ docker compose build --no-cache
```

**ATTENTION!** The DB should NOT be init again, so after rebuilding the image you just have to bring up the docker compose

```bash
$ docker compose up --detach
```

finally you need to upgrade the DB usign the command:

```bash
$ docker exec -ti <zou-container-name> sh -c "/opt/zou/env/bin/zou upgrade-db"
```

where `zou-container-name` is the name of the zou cointainer (something like: *kitsu-docker-zou-1*)

### About authors

The Dockerfile is written by CGWire, a company based in France. We help 
animation and VFX studios to collaborate better through efficient tooling.

More than 100 studios around the world use Kitsu for their projects.

Visit [cg-wire.com](https://cg-wire.com) for more information.

[![CGWire Logo](https://zou.cg-wire.com/cgwire.png)](https://cgwire.com)

Docker Compose file is written by [MAD Entertainment](https://www.madentertainment.it), a studio based in Napoli. We help people having fun.