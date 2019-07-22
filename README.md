# docker-tangerine-base-image

This is the base image for the Tangerine project. There are different branches for different types of sort; for example, the v2_node8 branch offers node8 support for v2.

This branch adds the "edit-config" attribute to config.xml to enable network-related permissions.

It also uses openjdk instead of the Oracle version and points to a specific phantomjs repo.

## Building

```
docker build -t v3-node-base-with-wrapper-perms .
```