// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';

import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/severity.dart';
import '../../models/common_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

/// Because unawaited_futures doesn't work when method/function is not marked async:
/// https://github.com/dart-lang/linter/issues/836
/// a workaround is to ensure all functions returning a future are annotated with 'async'.
/// This rules helps ensure those annotations aren't missing.
class PreferAsyncFutureFunctionsRule extends CommonRule {
  static const String ruleId = 'prefer-async-future-functions';

  static const _warningMessage = "Future functions should declare the 'async' keyword.";

  PreferAsyncFutureFunctionsRule([Map<String, Object> config = const {}])
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.warning),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor();

    source.unit.visitChildren(visitor);

    return visitor.nodes
        .map(
          (node) => createIssue(
            rule: this,
            location: nodeLocation(node: node, source: source),
            message: _warningMessage,
          ),
        )
        .toList(growable: false);
  }
}
