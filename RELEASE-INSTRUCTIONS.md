# Instruction for releasing a new version of docker-tangerine-base-image

## Making a release-candidate:
1. Make sure your local master branch is up to date and clean. `git fetch origin && git checkout master && git merge origin/master && git status`.
1. If you haven't done it already, build your image: `docker build -t tangerine/docker-tangerine-base-image:TAGNAME .`
2. Complete an entry in `CHANGELOG.md` for the release.
3. Git commit with a git commit message of the same release number.
4. Git tag with the same name as the release number - for example, v3.7.2-rc-1.
5. Git push the master branch, git push the tag.
6. Draft a new release on Github of the same tag name using that tag. Use the CHANGELOG notes.
7. Push the new image: `docker push tangerine/docker-tangerine-base-image:v3.7.2-rc-1`

## Making a stable release:
0. Checkout the release candidate tag and tag that commit with a stable version. ie. `git checkout v3.7.2-rc-2 && git tag v3.7.2 && git push origin v3.7.2`
0. Pull the RC image, rename it, and push it. ie. `docker pull tangerine/docker-tangerine-base-image:v3.7.2-rc-2 && docker tag tangerine/docker-tangerine-base-image:v3.7.2-rc-2 tangerine/docker-tangerine-base-image:v3.7.2 && docker push tangerine/docker-tangerine-base-image:v3.7.2`
0. Make release on Github using the same tag pushed up to Github.
