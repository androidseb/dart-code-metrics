// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
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

/// Because the unawaited_futures lint doesn't work when the containing method/function is not marked async:
/// https://github.com/dart-lang/linter/issues/836
/// this rule aims to cover this case: if a Future function call is made from a function/method returning a Future
/// and that is not marked 'async', and the function call is not directly wrapped under another
/// function call (e.g. 'unawaited()'), then this rule will trigger.
class AvoidUnawaitedFuturesInFutureSyncFunctions extends CommonRule {
  static const String ruleId = 'avoid-unawaited-futures-in-future-sync-functions';

  static const _warningMessage =
      "Future function call from a sync function returning a Future: wrap this Future function call inside 'unawaited()', or annotate the parent function 'async'";

  AvoidUnawaitedFuturesInFutureSyncFunctions([Map<String, Object> config = const {}])
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
