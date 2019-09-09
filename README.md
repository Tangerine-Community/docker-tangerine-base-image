# docker-tangerine-base-image

This is the base image for the Tangerine project. There are different branches for different types of sort; for example, the v2_node8 branch offers node8 support for v2.

## This branch, v3-node-base-with-wrapper-perms

Using node:10.16.0-stretch as base image.

This branch adds the "edit-config" attribute to config.xml to enable network-related permissions.

It also uses openjdk instead of the Oracle version and points to a specific phantomjs repo.

## Building

```
docker build -t tangerine/docker-tangerine-base-image:v3-node-base-with-wrapper-perms .
```