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

## Deployment

Please follow the [Release Instructions](RELEASE-INSTRUCTIONS.md) for deployments. 


