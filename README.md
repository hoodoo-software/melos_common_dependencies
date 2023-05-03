## Melos common dependencies

A package to help manage common dependencies in [Melos](https://github.com/invertase/melos) projects.

This is an adaptation of [fncap](https://github.com/fncap)'s script, which he posted at https://github.com/invertase/melos/issues/94#issuecomment-1458081801. Thank you fncap!

The issue to implement this functionality natively in Melos is https://github.com/invertase/melos/issues/94.
If it ends up being implemented there, this package will not be useful anymore.

### Installation and usage

Update your root `pubspec.yaml` with the following:

```yaml
dev_dependencies:
  melos_common_dependencies:
    git:
      url: https://github.com/hoodoo-software/melos_common_dependencies.git
```

Install the package:

```shell
dart pub get
```

Create a `common_dependencies.yaml` file with the following structure:

```yaml
dirs:
  - apps
  - packages
  - my_other_directory

dependencies:
  my_favourite_package: ^1.0.1
  my_second_favourite_package: ^1.0.2

dev_dependencies:
  my_third_favourite_package: ^1.0.3
```

You can now run the script:

```shell
dart run melos_common_dependencies
```

If you want the script to be run before `melos bootstrap`, you can add it as a hook in your `melos.yaml` file:

```yaml
command:
  bootstrap:
    hooks:
      pre: dart run melos_common_dependencies
```
