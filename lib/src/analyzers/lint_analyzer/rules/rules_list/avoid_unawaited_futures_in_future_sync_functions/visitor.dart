part of 'avoid_unawaited_futures_in_future_sync_functions.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    _checkFunctionBody(
      node.body,
      node.returnType?.type,
      isAbstract: node.isAbstract,
    );
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    super.visitFunctionExpression(node);

    _checkFunctionBody(
      node.body,
      node.declaredElement?.returnType,
      isAbstract: false,
    );
  }

  void _checkFunctionBody(
    FunctionBody body,
    DartType? returnType, {
    required bool isAbstract,
  }) {
    if (isAbstract) {
      // If the function is abstract, no need for a check
      return;
    }
    if (returnType == null) {
      // If there is no function type, the return type is not Future, no need for a check
      return;
    }
    if (body.isAsynchronous) {
      // If the function has the 'async' keyword already, no need for a check
      return;
    }

    if (!returnType.isDartAsyncFuture && !returnType.isDartAsyncFutureOr) {
      // If the function does not return a Future/FutureOr type, no need for a check
      return;
    }

    if (body is ExpressionFunctionBody) {
      // If the function is an arrow function '() => functionReturningFuture()'
      // then the Future is directly returned so there is no need for a check
      return;
    }

    // Running the visitor on the function body to check for unwrapped Future function calls
    body.visitChildren(_FutureFunctionCallVisitor(_nodes, body));
  }
}

class _FutureFunctionCallVisitor extends RecursiveAstVisitor<void> {
  final List<AstNode> _nodes;
  final FunctionBody body;

  _FutureFunctionCallVisitor(this._nodes, this.body);

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    super.visitFunctionExpressionInvocation(node);
    _visitFunctionInvocation(node.staticType, node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    _visitFunctionInvocation(node.staticType, node);
  }

  void _visitFunctionInvocation(DartType? returnType, Expression expression) {
    if (returnType == null) {
      // If the return type is not known, then it is not a Future, no need to check further
      return;
    }
    if (!returnType.isDartAsyncFuture && !returnType.isDartAsyncFutureOr) {
      // If the return type is not a Future, no need to check further
      return;
    }

    // At this point we know that we have a Future function call inside a Future-returning sync function

    if (_isInsideReturnStatement(expression)) {
      // If the function call is inside a return statement, then it is safe
      return;
    }
    if (_isWrappedInsideOtherFunctionCall(expression)) {
      // If the function called is wrapped inside another function call, then it is safe
      return;
    }
    // Otherwise, this is a problem, we add the function call to the list of problematic nodes
    _nodes.add(expression);
  }

  bool _isInsideReturnStatement(Expression expression) {
    final parent = expression.thisOrAncestorMatching(
      (parent) => parent == body || parent is ReturnStatement,
    );

    return parent is ReturnStatement;
  }

  bool _isWrappedInsideOtherFunctionCall(Expression expression) {
    final parent = expression.thisOrAncestorMatching(
      (item) => item != expression && (item == body || item is InvocationExpression),
    );

    return parent is InvocationExpression;
  }
}
