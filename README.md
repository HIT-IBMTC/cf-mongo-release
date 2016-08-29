# BOSH Release for MongoDB
Work In Progress

Meaning don't use it in production (or anywhere).
Also, this repository is my first experience with BOSH and GitHub.

## WTF?
I am trying to make BOSH release of MongoDB with working replication (later maybe even sharding).
Why don't I use some MongoDB release tested and hardened by the BOSH community? Because I couldn't find one.

This repository is a fork of https://github.com/ANATAS/mongo-boshrelease.

## Usage
```
git clone https://github.com/slowbackspace/mongo-boshrelease.git
cd mongo-boshrelease
./sm_mongo_boshrelease_dev.bash release
```

Edit templates/stub.yml and generate a deployment manifest:
```
cd templates
./make_manifest openstack stub.yml > my-mongodb-manifest.yml
bosh deployment my-mongodb-manifest.yml
bosh deploy
```

### Development

As a developer of this release, create new releases and upload them:

```
bosh create release --force && bosh -n upload release
```

### Final releases

To share final releases:

```
bosh create release --final
```

By default the version number will be bumped to the next major number. You can specify alternate versions:


```
bosh create release --final --version 2.1
```

After the first release you need to contact [Dmitriy Kalinin](mailto://dkalinin@pivotal.io) to request your project is added to https://bosh.io/releases (as mentioned in README above).
