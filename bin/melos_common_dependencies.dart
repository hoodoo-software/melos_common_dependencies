import 'dart:async';
import 'dart:io' show Directory, File;

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

Future<List<Directory>> getSubfolders(Directory dir) {
  final folders = <Directory>[];
  final completer = Completer<List<Directory>>();

  dir.list().listen(
    (fsEntity) {
      if (fsEntity is! Directory) return;
      folders.add(fsEntity);
    },
    onDone: () => completer.complete(folders),
  );

  return completer.future;
}

Future<void> update(
  YamlMap commonDependencies,
  List<Directory> folders,
  String targetNode,
) async {
  for (final folder in folders) {
    final pubspecPath = File(path.joinAll([folder.path, 'pubspec.yaml']));
    final yamlStr = await pubspecPath.readAsString();
    final yaml = loadYaml(yamlStr);
    if (yaml is! YamlMap) {
      throw Exception(
        'Malformed `pubspec.yaml` in $folder: file cannot be parsed',
      );
    }

    final editable = YamlEditor(yamlStr);
    final dependencies = yaml.nodes[targetNode];
    if (dependencies is! YamlMap) {
      throw Exception(
        'Malformed `pubspec.yaml` in $folder: "dependencies" cannot be parsed',
      );
    }

    var shouldUpdate = false;

    for (final dep in commonDependencies.entries) {
      if (!dependencies.containsKey(dep.key)) {
        continue;
      }
      editable.update([targetNode, dep.key], dep.value);
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      await pubspecPath.writeAsString(editable.toString());
    }
  }
}

Future<void> main() async {
  final commonPackagesYamlPath = path.joinAll([
    Directory.current.path,
    'common_packages.yaml',
  ]);
  final commonPackagesYaml = File(commonPackagesYamlPath);
  final commonPackages =
      loadYaml(commonPackagesYaml.readAsStringSync()) as YamlMap;
  final dirs = commonPackages.nodes['dirs'];
  if (dirs is! YamlList) {
    throw Exception(
      'Malformed `common_packages.yaml`: "dirs" should be a YamlList',
    );
  }

  final paths = <Directory>[];

  for (final dir in dirs.value) {
    final dirPath = path.joinAll([Directory.current.path, dir.toString()]);
    final subFolders = await getSubfolders(Directory(dirPath));
    paths.addAll(subFolders);
  }

  for (final target in ['dependencies', 'dev_dependencies']) {
    final commonDependencies = commonPackages.nodes[target];
    if (commonDependencies is! YamlMap) {
      throw Exception(
        'Malformed `common_packages.yaml`: $target should be a YamlMap',
      );
    }
    await update(commonDependencies, paths, target);
  }
}
