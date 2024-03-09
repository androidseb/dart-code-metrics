part of 'prefer_async_future_functions_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    if (!isOverride(node.metadata) && _isFutureFunctionWithMissingAsync(node.body, node.returnType?.type)) {
      _nodes.add(node);
    }
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    super.visitFunctionExpression(node);

    if (_isFutureFunctionWithMissingAsync(node.body, node.declaredElement?.returnType)) {
      _nodes.add(node);
    }
  }

  bool _isFutureFunctionWithMissingAsync(FunctionBody body, DartType? returnType) {
    if (returnType == null) {
      // If there is no function type, there is no missing async to report
      return false;
    }
    if (body.keyword?.type == Keyword.ASYNC) {
      // If there is an async keyword already, there is no missing async to report
      return false;
    }

    // If the function returns a Future or FutureOr type, then the missing async keyword is a problem
    return returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr;
  }
}
