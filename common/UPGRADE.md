# Upgrading $SBOX/common

This document describes the process for upgrading a project's version of fpga-common.

## Determine Current Version Used

```sh
cd $SBOX/common
git describe --tags
```

## Upgrade

1. Review all changes in the [CHANGELOG][1] from the current version used to
   the new version to be used.

2. Upgrade fpga-common.

   ```sh
   cd $SBOX/common
   git checkout master
   git pull
   git checkout <latest-tag>
   ```

3. Perform any necessary changes per upgrade instructions as specified in the
   CHANGELOG.

4. Exit and re-enter the sandbox to reload the environment.

[1]: https://github.jpl.nasa.gov/349-fpga-support/fpga-common/blob/master/CHANGELOG.md

## Test

Test out the changes:

* Run project regression
* Run lint
* Run synthesis

## Commit

1. Commit any changes to the project required for the upgrade
2. Commit `common`

   ```sh
   cd $SBOX
   git add common
   git commit
   ```

