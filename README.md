# BOSH Release for MongoDB

Working In Progress

Meaning don't use it in production (or anywhere really). But hey, you can help!

## WTF?

I am trying to make a BOSH release of MongoDB with working replication
Why don't I use some existing release tested and hardened by the BOSH community? Because I couldn't find one.

## Usage

```
git clone https://github.com/comxtohr/mongo-bosh-release.git
cd mongo-bosh-release
./mongo_bosh_release_dev blobs
bosh upload blobs
bosh upload release releases/fcf-mongo/fcf-mongo-1.yml
```

Edit `templates/stub.yml` and `templates/infrastucture-vsphere.yml`, generate a deployment manifest and deploy:

```
./mongo_bosh_release_dev manifest vsphere
bosh deploy
```

After the first deployment and after each addition or removal of nodes you also need to run

```
bosh run errand replset
```

To register the broker to Cloud Foundry you need yo run

```
bosh run errand broker-registrar
```

### Development

As a developer of this release, create new releases and upload them:

```
./mongo_bosh_release_dev prepare
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
