# docker-tangerine-base-image

This is the base image for the Tangerine project. There are different branches for different types of instances; for example, the v2_node8 branch offers node8 support for v2.

This branch is for Tangerine v3 deployments.

See CHANGELOG.md for more information.

## Configuration

Be aware that the use of `edit-config` property in config.xml hard-codes application attributes that are inserted into the AndroidManifest.xml. 
If you have plugins that modify the application property, you may wish to change the `edit-config` attributes.

## Building

```
docker build -t tangerine/docker-tangerine-base-image:TAGNAME .
```

If you're trying to build on an M1-based Mac, use the following command:

```
docker build --platform linux/amd64 -t tangerine/docker-tangerine-base-image:TAGNAME .
```

## Running

```
docker run --name=base -td tangerine/docker-tangerine-base-image:TAGNAME 
docker exec -it base bash
```

If you're trying to run on an M1-based Mac, use the following command:

```
docker run --platform linux/amd64 --name=base -td tangerine/docker-tangerine-base-image:TAGNAME 
docker exec -it base bash
```


## Deployment

Please follow the [Release Instructions](RELEASE-INSTRUCTIONS.md) for deployments. 


