# Instruction for releasing a new version of docker-tangerine-base-image

1. Make sure your local master branch is up to date and clean. `git fetch origin && git checkout master && git merge origin/master && git status`.
2. Complete an entry in `CHANGELOG.md` for the release.
3. Git commit with a git commit message of the same release number.
4. Git tag with the same name as the release number.
5. Git push the master branch, git push the tag.
6. Draft a new release on Github of the same tag name using that tag. Use the CHANGELOG notes.
7. The Docker repository is configured to generate builds whenever a new tag is pushed. Check the logs on Docker Hub to make sure there are no build errors.
