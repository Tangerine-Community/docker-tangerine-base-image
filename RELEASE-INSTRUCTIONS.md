# Instruction for releasing a new version of docker-tangerine-base-image

## Making a release-candidate:
1. Make sure your local master branch is up to date and clean. `git fetch origin && git checkout master && git merge origin/master && git status`.
2. Complete an entry in `CHANGELOG.md` for the release.
0. Go to the New Release Page on github (https://github.com/Tangerine-Community/Tangerine/releases/new).
1. Set "Target" to the release branch branch.
2. Set the "Tag version" to the version this release candidate is targeting with `-rc-` and the number appended. For example, if this was the third release candidate for v3.11.0, the tag would be `v3.11.0-rc-3`.
3. Leave the "Release title" blank.
4. Check the "This is a pre-release" checkbox.
5. Click "Publish release".

## Making a stable release:
0. Checkout the release candidate tag and tag that commit with a stable version. ie. `git checkout v3.7.2-rc-2 && git tag v3.7.2 && git push origin v3.7.2`
0. Pull the RC image, rename it, and push it. ie. `docker pull tangerine/docker-tangerine-base-image:v3.7.2-rc-2 && docker tag tangerine/docker-tangerine-base-image:v3.7.2-rc-2 tangerine/docker-tangerine-base-image:v3.7.2 && docker push tangerine/docker-tangerine-base-image:v3.7.2`
0. Make release on Github using the same tag pushed up to Github.
1. Make sure to cancel the workflow in GH Actions, since you manually pushed the rc out in the previous step.

## Optional - Manual steps for building and pushing an image
1. Build your image: `docker build -t tangerine/docker-tangerine-base-image:TAGNAME .`
2. Push the new image: `docker push tangerine/docker-tangerine-base-image:v3.7.2-rc-1`
