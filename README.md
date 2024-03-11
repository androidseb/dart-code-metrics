# DCM - MIT fork

This is a third-party fork from version 5.7.4 of dart_code_metrics, the MIT-licensed version of the dart_code_metrics project.

The version of this fork was initially changed to 6.0.0 to clearly indicate a breaking change, and future development will split from the original [dart_code_metrics](https://pub.dev/packages/dart_code_metrics/versions).

This fork is not maintained by the original authors of dart_code_metrics, and the only planned development for this third-party copy is to:

* make library dependencies maintenance fixes
* implement new rules that I personnally need for my project, such as:
    * `prefer-async-future-functions`

This is not part of the official dart code metrics project, if you want to look at the official dart code metrics project, see their website here: [https://dcm.dev/](https://dcm.dev/).

## Short guide to creating a new rule

* Create a new folder in `lib/src/analyzers/lint_analyzer/rules/rules_list`
* Add the new rule declaration in `lib/src/analyzers/lint_analyzer/rules/rules_factory.dart`
* Debug locally by specifying local path dependencies inside `tools/analyzer_plugin/pubspec.yaml` and `pubspec.yaml`
* If debugging locally and the analyser is not taking your changes into account, delete the folder under `~/.dartServer/.plugin_manager`
