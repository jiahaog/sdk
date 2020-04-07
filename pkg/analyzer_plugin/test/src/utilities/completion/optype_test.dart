// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/src/utilities/completion/completion_target.dart';
import 'package:analyzer_plugin/src/utilities/completion/optype.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../support/abstract_context.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(OpTypeTest);
  });
}

/// Common test methods to Dart1/Dart2 versions of OpType tests.
abstract class AbstractOpTypeTest extends AbstractContextTest {
  String testPath;
  int completionOffset;
  OpType visitor;

  void addTestSource(String content) {
    completionOffset = content.indexOf('^');
    expect(completionOffset, isNot(equals(-1)), reason: 'missing ^');
    var nextOffset = content.indexOf('^', completionOffset + 1);
    expect(nextOffset, equals(-1), reason: 'too many ^');
    content = content.substring(0, completionOffset) +
        content.substring(completionOffset + 1);
    super.addSource(testPath, content);
  }

  Future<void> assertOpType(
      {bool caseLabel = false,
      bool constructors = false,
      bool namedArgs = false,
      bool prefixed = false,
      bool returnValue = false,
      bool statementLabel = false,
      bool staticMethodBody = false,
      bool typeNames = false,
      bool varNames = false,
      bool voidReturn = false,
      CompletionSuggestionKind kind =
          CompletionSuggestionKind.INVOCATION}) async {
    var resolvedUnit = await driver.getResult(testPath);

    var completionTarget =
        CompletionTarget.forOffset(resolvedUnit.unit, completionOffset);
    visitor = OpType.forCompletion(completionTarget, completionOffset);

    expect(visitor.includeCaseLabelSuggestions, caseLabel, reason: 'caseLabel');
    expect(visitor.includeConstructorSuggestions, constructors,
        reason: 'constructors');
    expect(visitor.includeNamedArgumentSuggestions, namedArgs,
        reason: 'namedArgs');
    expect(visitor.includeReturnValueSuggestions, returnValue,
        reason: 'returnValue');
    expect(visitor.includeStatementLabelSuggestions, statementLabel,
        reason: 'statementLabel');
    expect(visitor.includeTypeNameSuggestions, typeNames, reason: 'typeNames');
    expect(visitor.includeVarNameSuggestions, varNames, reason: 'varNames');
    expect(visitor.includeVoidReturnSuggestions, voidReturn,
        reason: 'voidReturn');
    expect(visitor.inStaticMethodBody, staticMethodBody,
        reason: 'staticMethodBody');
    expect(visitor.isPrefixed, prefixed, reason: 'prefixed');
    expect(visitor.suggestKind, kind, reason: 'suggestion kind');
  }

  @override
  void setUp() {
    super.setUp();
    testPath = convertPath('/completionTest.dart');
  }
}

@reflectiveTest
class OpTypeTest extends AbstractOpTypeTest {
  @failingTest
  Future<void> test_annotation_notBeforeDeclaration() async {
    // SimpleIdentifier  Annotation  MethodDeclaration  ClassDeclaration
    addTestSource('class C { @A^ }');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
    // TODO(danrubel): This test fails because the @A is dropped from the AST.
    // Ideally we generate a synthetic field and associate the annotation
    // with that field, but doing so breaks test_constructorAndMethodNameCollision.
    // See https://dart-review.googlesource.com/c/sdk/+/65760/3/pkg/analyzer/lib/src/fasta/ast_builder.dart#2395
  }

  Future<void> test_argumentList_constructor_named_resolved_1_0() async {
    // ArgumentList  InstanceCreationExpression  ExpressionStatement Block
    addTestSource(
      'main() { new A.b(^); }'
      'class A{ A.b({one, two}) {} }',
    );
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_constructor_named_resolved_1_1() async {
    // ArgumentList  InstanceCreationExpression  ExpressionStatement  Block
    addTestSource(
      'main() { new A.b(o^); }'
      'class A { A.b({one, two}) {} }',
    );
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_constructor_resolved_1_0() async {
    // ArgumentList  InstanceCreationExpression  ExpressionStatement Block
    addTestSource(
      'main() { new A(^); }'
      'class A{ A({one, two}) {} }',
    );
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_constructor_resolved_1_1() async {
    // ArgumentList  InstanceCreationExpression  ExpressionStatement  Block
    addTestSource(
      'main() { new A(o^); }'
      'class A { A({one, two}) {} }',
    );
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_factory_named_resolved_1_0() async {
    // ArgumentList  InstanceCreationExpression  ExpressionStatement Block
    addTestSource(
      'main() { new A.b(^); }'
      'class A{ factory A.b({one, two}) {} }',
    );
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_factory_named_resolved_1_1() async {
    // ArgumentList  InstanceCreationExpression  ExpressionStatement  Block
    addTestSource(
      'main() { new A.b(o^); }'
      'class A { factory A.b({one, two}) {} }',
    );
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_factory_resolved_1_0() async {
    // ArgumentList  InstanceCreationExpression  ExpressionStatement Block
    addTestSource(
      'main() { new A(^); }'
      'class A{ factory A({one, two}) {} }',
    );
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_factory_resolved_1_1() async {
    // ArgumentList  InstanceCreationExpression  ExpressionStatement  Block
    addTestSource(
      'main() { new A(o^); }'
      'class A { factory A({one, two}) {} }',
    );
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_method_resolved_1_0() async {
    // ArgumentList  MethodInvocation  ExpressionStatement  Block
    addTestSource('main() { foo(^);} foo({one, two}) {}');
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_method_resolved_1_1() async {
    // ArgumentList  MethodInvocation  ExpressionStatement  Block
    addTestSource('main() { foo(o^);} foo({one, two}) {}');
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_namedParam() async {
    // SimpleIdentifier  NamedExpression  ArgumentList  MethodInvocation
    // ExpressionStatement
    addTestSource('void main() {expect(foo: ^)}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_argumentList_prefixedIdentifier() async {
    // SimpleIdentifier  PrefixedIdentifier  ArgumentList
    addTestSource('void main() {expect(aa.^)}');
    await assertOpType(
        constructors: true, returnValue: true, typeNames: true, prefixed: true);
  }

  Future<void> test_argumentList_resolved() async {
    // ArgumentList  MethodInvocation  ExpressionStatement  Block
    addTestSource('void main() {int.parse(^)}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_argumentList_resolved_2_0() async {
    // ArgumentList  MethodInvocation  ExpressionStatement  Block
    addTestSource('void main() {int.parse("16", ^)}');
    await assertOpType(namedArgs: true);
  }

  Future<void> test_argumentList_unresolved() async {
    // ArgumentList  MethodInvocation  ExpressionStatement  Block
    addTestSource('void main() {expect(^)}');
    // If "expect()" were resolved, then either namedArgs would be true
    // or returnValue and typeNames would be true.
    await assertOpType(
        constructors: true,
        namedArgs: true,
        returnValue: true,
        typeNames: true);
  }

  Future<void> test_asExpression_rightHandSide() async {
    // SimpleIdentifier  TypeName  AsExpression
    addTestSource('class A {var b; X _c; foo() {var a; (a as ^).foo();}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_assert_firstArgument() async {
    addTestSource('main() {assert(^)}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_assertInitializer_firstArgument() async {
    addTestSource('class C { C() : assert(^); }');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_assignmentExpression_name() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('class A {} main() {int a; int ^b = 1;}');
    await assertOpType(varNames: true);
  }

  Future<void> test_assignmentExpression_RHS() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('class A {} main() {int a; int b = ^}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_assignmentExpression_type() async {
    // SimpleIdentifier  TypeName  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('''
      main() {
        int a;
        ^ b = 1;}''');
    // TODO (danrubel) When entering 1st of 2 identifiers on assignment LHS
    // the user may be either (1) entering a type for the assignment
    // or (2) starting a new statement.
    // Consider suggesting only types
    // if only spaces separates the 1st and 2nd identifiers.
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_assignmentExpression_type_newline() async {
    // SimpleIdentifier  TypeName  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('''
      main() {
        int a;
        ^
        b = 1;}''');
    // Allow non-types preceding an identifier on LHS of assignment
    // if newline follows first identifier
    // because user is probably starting a new statement
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_assignmentExpression_type_partial() async {
    // SimpleIdentifier  TypeName  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('''
      main() {
        int a;
        int^ b = 1;}''');
    // TODO (danrubel) When entering 1st of 2 identifiers on assignment LHS
    // the user may be either (1) entering a type for the assignment
    // or (2) starting a new statement.
    // Consider suggesting only types
    // if only spaces separates the 1st and 2nd identifiers.
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_assignmentExpression_type_partial_newline() async {
    // SimpleIdentifier  TypeName  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('''
      main() {
        int a;
        i^
        b = 1;}''');
    // Allow non-types preceding an identifier on LHS of assignment
    // if newline follows first identifier
    // because user is probably starting a new statement
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_awaitExpression_assignment() async {
    addTestSource('main() async {A a; int x = await ^}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_awaitExpression_assignment2() async {
    addTestSource('main() async {A a; int x = await ^ await foo;}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_awaitExpression_assignment3() async {
    addTestSource('main() async {A a; int x = await v^ int y = await foo;}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_awaitExpression_statement() async {
    // SimpleIdentifier  AwaitExpression  ExpressionStatement
    addTestSource('main() async {A a; await ^}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_awaitExpression_statement2() async {
    addTestSource('main() async {A a; await c^ await}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_awaitExpression_statement3() async {
    addTestSource('main() async {A a; await ^ await foo;}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_awaitExpression_statement4() async {
    addTestSource('main() async {A a; await ^ await bar();}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_binaryExpression_LHS() async {
    // SimpleIdentifier  BinaryExpression  VariableDeclaration
    // VariableDeclarationList  VariableDeclarationStatement
    addTestSource('main() {int a = 1, b = ^ + 2;}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_binaryExpression_RHS() async {
    // SimpleIdentifier  BinaryExpression  VariableDeclaration
    // VariableDeclarationList  VariableDeclarationStatement
    addTestSource('main() {int a = 1, b = 2 + ^;}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_binaryExpression_RHS2() async {
    // SimpleIdentifier  BinaryExpression
    addTestSource('main() {if (c < ^)}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_block_empty() async {
    // Block  BlockFunctionBody  MethodDeclaration  ClassDeclaration
    addTestSource('class A extends E implements I with M {a() {^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_block_final() async {
    addTestSource('main() {final ^}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_block_final2() async {
    addTestSource('main() {final S^ v;}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_block_final3() async {
    addTestSource('main() {final ^ v;}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_block_final_final() async {
    addTestSource('main() {final ^ final S x;}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_block_final_final2() async {
    addTestSource('main() {final S^ final S x;}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_block_identifier_partial() async {
    addTestSource('class X {a() {var f; {var x;} D^ var r;} void b() { }}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_block_inConstructor() async {
    addTestSource('class A {A() {^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_block_inFunction() async {
    addTestSource('foo() {^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_block_inMethod() async {
    addTestSource('class A {foo() {^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_block_keyword() async {
    addTestSource('class C { static C get instance => null; } main() {C.in^}');
    await assertOpType(
        constructors: true,
        prefixed: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_block_startOfStatement() async {
    // Block  BlockFunctionBody  MethodDeclaration
    addTestSource('''
      class X {
        a() {
          var f;
          localF(int arg1) { }
          {var x;}
          ^ var r;
        }
      }''');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_block_static() async {
    addTestSource('class A {static foo() {^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        staticMethodBody: true,
        voidReturn: true);
  }

  Future<void> test_break_afterLabel() async {
    addTestSource('main() { foo: while (true) { break foo ^ ; } }');
    await assertOpType(/* No valid completions */);
  }

  Future<void> test_break_beforeLabel() async {
    addTestSource('main() { foo: while (true) { break ^ foo; } }');
    await assertOpType(statementLabel: true);
  }

  Future<void> test_break_noLabel() async {
    addTestSource('main() { foo: while (true) { break ^; } }');
    await assertOpType(statementLabel: true);
  }

  Future<void> test_builtInIdentifier_as() async {
    addTestSource('class A {var asdf; foo() {as^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_builtInIdentifier_as2() async {
    addTestSource('class A {var asdf; foo() {A as^}');
    await assertOpType();
  }

  Future<void> test_cascadeExpression_selector1() async {
    // PropertyAccess  CascadeExpression  ExpressionStatement  Block
    addTestSource('''
      // looks like a cascade to the parser
      // but the user is trying to get completions for a non-cascade
      main() {A a; a.^.z}''');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_cascadeExpression_selector2() async {
    // SimpleIdentifier  PropertyAccess  CascadeExpression  ExpressionStatement
    addTestSource('main() {A a; a..^z}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_cascadeExpression_selector2_withTrailingReturn() async {
    // PropertyAccess  CascadeExpression  ExpressionStatement  Block
    addTestSource('main() {A a; a..^ return}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_cascadeExpression_target() async {
    // SimpleIdentifier  CascadeExpression  ExpressionStatement
    addTestSource('main() {A a; a^..b}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_classDeclaration_body() async {
    // ClassDeclaration  CompilationUnit
    addTestSource('@deprecated class A {^}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_classDeclaration_body2() async {
    // SimpleIdentifier  MethodDeclaration  ClassDeclaration
    addTestSource('@deprecated class A {^mth() {}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_combinator_hide() async {
    // SimpleIdentifier  HideCombinator  ImportDirective
    addTestSource('''
      import "/testAB.dart" hide ^;
      class X {}''');
    await assertOpType();
  }

  Future<void> test_combinator_show() async {
    // SimpleIdentifier  HideCombinator  ImportDirective
    addTestSource('''
      import "/testAB.dart" show ^;
      import "/testCD.dart";
      class X {}''');
    await assertOpType();
  }

  Future<void> test_commentReference() async {
    // SimpleIdentifier  CommentReference  Comment  MethodDeclaration
    addTestSource('class A {/** [^] */ mth() {}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true,
        kind: CompletionSuggestionKind.IDENTIFIER);
  }

  Future<void> test_conditionalExpression_elseExpression() async {
    // SimpleIdentifier  ConditionalExpression  ReturnStatement
    addTestSource('class C {foo(){var f; {var x;} return a ? T1 : T^}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_conditionalExpression_elseExpression_empty() async {
    // SimpleIdentifier  ConditionalExpression  ReturnStatement
    addTestSource('class C {foo(){var f; {var x;} return a ? T1 : ^}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_conditionalExpression_partial_thenExpression() async {
    // SimpleIdentifier  ConditionalExpression  ReturnStatement
    addTestSource('class C {foo(){var f; {var x;} return a ? T^}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_conditionalExpression_partial_thenExpression_empty() async {
    // SimpleIdentifier  ConditionalExpression  ReturnStatement
    addTestSource('class C {foo(){var f; {var x;} return a ? ^}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_conditionalExpression_thenExpression() async {
    // SimpleIdentifier  ConditionalExpression  ReturnStatement
    addTestSource('class C {foo(){var f; {var x;} return a ? T^ : c}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_constructorDeclaration_const() async {
    // ConstructorDeclaration
    // The additional syntax with assert is to ensure that the target node is
    // a ConstructorDeclaration, instead of a MethodDeclaration.
    addTestSource('''
      class ABC {
        int i;
        const A^(this.i) : assert(i != 0);
      }''');
    await assertOpType(typeNames: true);
  }

  Future<void> test_constructorDeclaration_const_named() async {
    // ConstructorDeclaration
    // The additional syntax with assert is to ensure that the target node is
    // a ConstructorDeclaration, instead of a MethodDeclaration.
    addTestSource('''
      class ABC {
        int i;
        const A^.b(this.i) : assert(i != 0);
      }''');
    await assertOpType(typeNames: true);
  }

  Future<void> test_constructorDeclaration_const_named2() async {
    // ConstructorDeclaration
    // The additional syntax with assert is to ensure that the target node is
    // a ConstructorDeclaration, instead of a MethodDeclaration.
    // A negative test that type names aren't expected to be the name of a named
    // constructor.
    addTestSource('''
      class ABC {
        int i;
        const A.^b(this.i) : assert(i != 0);
      }''');
    await assertOpType(typeNames: false);
  }

  Future<void> test_constructorDeclaration_factory() async {
    // ConstructorDeclaration
    addTestSource(
      'class A { factory A^() {} }',
    );
    await assertOpType(typeNames: true);
  }

  Future<void> test_constructorDeclaration_factory_named() async {
    // ConstructorDeclaration
    addTestSource(
      'class A { factory A^.b() {} }',
    );
    await assertOpType(typeNames: true);
  }

  Future<void> test_constructorDeclaration_factory_named2() async {
    // ConstructorDeclaration
    // A negative test that type names aren't expected to be the name of a named
    // constructor.
    addTestSource(
      'class A { factory A.^b() {} }',
    );
    await assertOpType(typeNames: false);
  }

  Future<void> test_constructorDeclaration_inClassName() async {
    // ClassDeclaration
    // This ConstructorDeclaration case is handled by the ClassDeclaration
    // visitor.
    addTestSource('''
      class ABC {
        int i;
        A^(this.i) : assert(i != 0);
      }''');
    await assertOpType(typeNames: true);
  }

  Future<void> test_constructorFieldInitializer_name() async {
    addTestSource(r'''
class C {
  final int foo;
  
  C() : ^
}
''');
    await assertOpType();
  }

  Future<void> test_constructorFieldInitializer_value() async {
    addTestSource(r'''
class C {
  final int foo;
  
  C() : foo = ^
}
''');
    await assertOpType(
      constructors: true,
      returnValue: true,
      typeNames: true,
    );
  }

  Future<void> test_constructorName_name() async {
    // SimpleIdentifier  PrefixedIdentifier  TypeName  ConstructorName
    // InstanceCreationExpression
    addTestSource('main() {new X.^}');
    await assertOpType(constructors: true, prefixed: true);
  }

  Future<void> test_constructorName_name_resolved() async {
    // SimpleIdentifier  PrefixedIdentifier  TypeName  ConstructorName
    // InstanceCreationExpression
    addTestSource('main() {new Str^ing.fromCharCodes([]);}');
    await assertOpType(constructors: true);
  }

  Future<void> test_constructorName_nameAndPrefix_resolved() async {
    // SimpleIdentifier  PrefixedIdentifier  TypeName  ConstructorName
    // InstanceCreationExpression
    addTestSource('''
import 'dart:core' as core;
main() {new core.String.from^CharCodes([]);}
''');
    await assertOpType(constructors: true, prefixed: true);
  }

  Future<void> test_constructorName_resolved() async {
    // SimpleIdentifier  PrefixedIdentifier  TypeName  ConstructorName
    // InstanceCreationExpression
    addTestSource('main() {new String.fr^omCharCodes([]);}');
    await assertOpType(constructors: true, prefixed: true);
  }

  Future<void> test_constructorName_unresolved() async {
    // SimpleIdentifier  PrefixedIdentifier  TypeName  ConstructorName
    // InstanceCreationExpression
    addTestSource('main() {new String.fr^omCharCodes([]);}');
    await assertOpType(constructors: true, prefixed: true);
  }

  Future<void> test_continue_afterLabel() async {
    addTestSource('main() { foo: while (true) { continue foo ^ ; } }');
    await assertOpType(/* No valid completions */);
  }

  Future<void> test_continue_beforeLabel() async {
    addTestSource('main() { foo: while (true) { continue ^ foo; } }');
    await assertOpType(statementLabel: true, caseLabel: true);
  }

  Future<void> test_continue_noLabel() async {
    addTestSource('main() { foo: while (true) { continue ^; } }');
    await assertOpType(statementLabel: true, caseLabel: true);
  }

  Future<void> test_defaultFormalParameter_named_expression() async {
    // DefaultFormalParameter FormalParameterList MethodDeclaration
    addTestSource('class A {a(blat: ^) { }}');
    await assertOpType(
      constructors: true,
      returnValue: true,
      typeNames: true,
    );
  }

  Future<void> test_doStatement_inCondition() async {
    // SimpleIdentifier  DoStatement  Block
    addTestSource('main() {do{} while(^x);}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_doubleLiteral() async {
    addTestSource('main() { print(1.2^); }');
    await assertOpType();
  }

  Future<void> test_expressionFunctionBody_beginning() async {
    // SimpleIdentifier  ExpressionFunctionBody  FunctionExpression
    addTestSource('m(){[1].forEach((x)=>^x);}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_expressionStatement_beginning() async {
    // ExpressionStatement  Block  BlockFunctionBody
    addTestSource('n(){f(3);^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_expressionStatement_name() async {
    // ExpressionStatement  Block  BlockFunctionBody  MethodDeclaration
    addTestSource('class C {a() {C ^}}');
    await assertOpType(varNames: true);
  }

  Future<void> test_expressionStatement_name_semicolon() async {
    // ExpressionStatement  Block  BlockFunctionBody  MethodDeclaration
    addTestSource('class C {a() {C ^;}}');
    await assertOpType(varNames: true);
  }

  Future<void> test_expressionStatement_prefixed_name() async {
    // ExpressionStatement  Block  BlockFunctionBody  MethodDeclaration
    addTestSource('class C {a() {x.Y ^}}');
    await assertOpType(varNames: true);
  }

  Future<void> test_expressionStatement_prefixed_name_semicolon() async {
    // ExpressionStatement  Block  BlockFunctionBody  MethodDeclaration
    addTestSource('class C {a() {x.Y ^;}}');
    await assertOpType(varNames: true);
  }

  Future<void> test_extendsClause_beginning() async {
    // ExtendsClause  ClassDeclaration
    addTestSource('class x extends ^\n{}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_extensionDeclaration_body_atBeginning() async {
    // SimpleIdentifier  MethodDeclaration  ExtensionDeclaration
    addTestSource('extension E on int {^mth() {}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_extensionDeclaration_body_atEnd() async {
    // ExtensionDeclaration  CompilationUnit
    addTestSource('extension E on int {^}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_fieldDeclaration_name_typed() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // FieldDeclaration
    addTestSource('class C {A ^}');
    await assertOpType(varNames: true);
  }

  Future<void> test_fieldDeclaration_name_var() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // FieldDeclaration
    addTestSource('class C {var ^}');
    await assertOpType();
  }

  Future<void> test_fieldDeclaration_type() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // FieldDeclaration
    addTestSource('class C {^ foo; }');
    await assertOpType(typeNames: true);
  }

  Future<void> test_fieldDeclaration_type_no_semicolon() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // FieldDeclaration
    addTestSource('class C {^ foo }');
    await assertOpType(typeNames: true);
  }

  Future<void> test_forEachStatement_body_typed() async {
    // Block  ForEachStatement
    addTestSource('main(args) {for (int foo in bar) {^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_forEachStatement_body_untyped() async {
    // Block  ForEachStatement
    addTestSource('main(args) {for (foo in bar) {^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_forEachStatement_iterable() async {
    // SimpleIdentifier  ForEachStatement  Block
    addTestSource('main(args) {for (int foo in ^) {}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_forEachStatement_iterator() async {
    // SimpleIdentifier  ForEachStatement  Block
    addTestSource('main() {for(z in ^zs) {}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_forEachStatement_loopVariable() async {
    // SimpleIdentifier  ForEachStatement  Block
    addTestSource('main(args) {for (^ in args) {}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_forEachStatement_loopVariable_name() async {
    // DeclaredIdentifier  ForEachStatement  Block
    addTestSource('main(args) {for (String ^ in args) {}}');
    await assertOpType();
  }

  Future<void> test_forEachStatement_loopVariable_name2() async {
    // DeclaredIdentifier  ForEachStatement  Block
    addTestSource('main(args) {for (String f^ in args) {}}');
    await assertOpType();
  }

  Future<void> test_forEachStatement_loopVariable_type() async {
    // SimpleIdentifier  ForEachStatement  Block
    addTestSource('main(args) {for (^ foo in args) {}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_forEachStatement_loopVariable_type2() async {
    // DeclaredIdentifier  ForEachStatement  Block
    addTestSource('main(args) {for (S^ foo in args) {}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_forElement_body() async {
    addTestSource('main(args) {[for (var foo in [0]) ^];}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_forElement_forEachParts_iterable() async {
    addTestSource('main(args) {[for (var foo in ^) foo];}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_forElement_forEachParts_type() async {
    addTestSource('main(args) {[for (i^ foo in [0]) foo];}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_formalParameter_partialType() async {
    // FormalParameterList MethodDeclaration
    addTestSource('class A {a(b.^ f) { }}');
    await assertOpType(
      constructors: true,
      returnValue: true,
      typeNames: true,
      prefixed: true,
    );
  }

  Future<void> test_formalParameter_partialType2() async {
    // FormalParameterList MethodDeclaration
    addTestSource('class A {a(b.z^ f) { }}');
    await assertOpType(
      constructors: true,
      returnValue: true,
      typeNames: true,
      prefixed: true,
    );
  }

  Future<void> test_formalParameter_partialType3() async {
    // FormalParameterList MethodDeclaration
    addTestSource('class A {a(b.^) { }}');
    await assertOpType(
      constructors: true,
      returnValue: true,
      typeNames: true,
      prefixed: true,
    );
  }

  Future<void> test_formalParameterList_empty() async {
    // FormalParameterList MethodDeclaration
    addTestSource('class A {a(^) { }}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_forStatement_condition() async {
    // SimpleIdentifier  ForStatement
    addTestSource('main() {for (int index = 0; i^)}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

//
  Future<void> test_forStatement_initializer() async {
    // SimpleIdentifier  ForStatement
    addTestSource('main() {List a; for (^)}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_forStatement_initializer_inKeyword() async {
    addTestSource('main() { for (var v i^) }');
    await assertOpType();
  }

  Future<void> test_forStatement_initializer_type() async {
    // SimpleIdentifier  ForStatement
    addTestSource('main() {List a; for (i^ v = 0;)}');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_forStatement_initializer_variableNameEmpty_afterType() async {
    addTestSource('main() { for (String ^) }');
    await assertOpType(varNames: true);
  }

  Future<void> test_forStatement_updaters() async {
    // SimpleIdentifier  ForStatement
    addTestSource('main() {for (int index = 0; index < 10; i^)}');
    // TODO (danrubel) may want to exclude methods/functions with void return
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_forStatement_updaters_prefix_expression() async {
    // SimpleIdentifier  PrefixExpression  ForStatement
    addTestSource('main() {for (int index = 0; index < 10; ++i^)}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_functionDeclaration_inLineComment() async {
    // Comment  CompilationUnit
    addTestSource('''
      // normal comment ^
      zoo(z) { } String name;''');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inLineComment2() async {
    // Comment  CompilationUnit
    addTestSource('''
      // normal ^comment
      zoo(z) { } String name;''');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inLineComment3() async {
    // Comment  CompilationUnit
    addTestSource('''
      // normal comment ^
      // normal comment 2
      zoo(z) { } String name;''');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inLineComment4() async {
    // Comment  CompilationUnit
    addTestSource('''
      // normal comment
      // normal comment 2^
      zoo(z) { } String name;''');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inLineDocComment() async {
    // Comment  FunctionDeclaration  CompilationUnit
    addTestSource('''
      /// some dartdoc ^
      zoo(z) { } String name;''');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inLineDocComment2() async {
    // Comment  FunctionDeclaration  CompilationUnit
    addTestSource('''
      /// some ^dartdoc
      zoo(z) { } String name;''');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inStarComment() async {
    // Comment  CompilationUnit
    addTestSource('/* ^ */ zoo(z) {} String name;');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inStarComment2() async {
    // Comment  CompilationUnit
    addTestSource('/*  *^/ zoo(z) {} String name;');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inStarDocComment() async {
    // Comment  FunctionDeclaration  CompilationUnit
    addTestSource('/** ^ */ zoo(z) { } String name; ');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_inStarDocComment2() async {
    // Comment  FunctionDeclaration  CompilationUnit
    addTestSource('/**  *^/ zoo(z) { } String name;');
    await assertOpType();
  }

  Future<void> test_functionDeclaration_name1() async {
    // SimpleIdentifier  FunctionDeclaration  CompilationUnit
    addTestSource('const ^Fara();');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionDeclaration_name2() async {
    // SimpleIdentifier  FunctionDeclaration  CompilationUnit
    addTestSource('const F^ara();');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionDeclaration_returnType() async {
    // CompilationUnit
    addTestSource('^ zoo(z) { } String name;');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionDeclaration_returnType_afterLineComment() async {
    // FunctionDeclaration  CompilationUnit
    addTestSource('''
      // normal comment
      ^ zoo(z) {} String name;''');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionDeclaration_returnType_afterLineComment2() async {
    // FunctionDeclaration  CompilationUnit
    // TOD(danrubel) left align all test source
    addTestSource('''
// normal comment
^ zoo(z) {} String name;''');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionDeclaration_returnType_afterLineDocComment() async {
    // SimpleIdentifier  FunctionDeclaration  CompilationUnit
    addTestSource('''
      /// some dartdoc
      ^ zoo(z) { } String name;''');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_functionDeclaration_returnType_afterLineDocComment2() async {
    // SimpleIdentifier  FunctionDeclaration  CompilationUnit
    addTestSource('''
/// some dartdoc
^ zoo(z) { } String name;''');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionDeclaration_returnType_afterStarComment() async {
    // CompilationUnit
    addTestSource('/* */ ^ zoo(z) { } String name;');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionDeclaration_returnType_afterStarComment2() async {
    // CompilationUnit
    addTestSource('/* */^ zoo(z) { } String name;');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionDeclaration_returnType_afterStarDocComment() async {
    // FunctionDeclaration  CompilationUnit
    addTestSource('/** */ ^ zoo(z) { } String name;');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_functionDeclaration_returnType_afterStarDocComment2() async {
    // FunctionDeclaration  CompilationUnit
    addTestSource('/** */^ zoo(z) { } String name;');
    await assertOpType(typeNames: true);
  }

  Future<void> test_functionExpression_beforeBody() async {
    // BlockFunctionBody  FunctionExpression  FunctionDeclaration
    addTestSource('main()^ { int b = 2; b++; b. }');
    await assertOpType();
  }

  Future<void> test_functionExpressionInvocation_beforeArgumentList() async {
    // ArgumentList  FunctionExpressionInvocation  ExpressionStatement
    addTestSource('main() { ((x) => x + 7)^(2) }');
    await assertOpType();
  }

  Future<void> test_functionTypeAlias_name() async {
    // SimpleIdentifier  FunctionTypeAlias  CompilationUnit
    addTestSource('typedef n^ ;');
    await assertOpType(typeNames: true);
  }

  Future<void> test_ifElement_condition() async {
    addTestSource('''
main() {
  [if (^)];
}
''');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_ifElement_else() async {
    addTestSource('''
main() {
  [if (true) 0 else ^];
}
''');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_ifElement_then() async {
    addTestSource('''
main() {
  [if (true) ^];
}
''');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_ifStatement_afterCondition() async {
    // EmptyStatement  IfStatement  Block  BlockFunctionBody
    addTestSource('main(){var a; if (true) ^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_ifStatement_condition() async {
    // SimpleIdentifier  IfStatement  Block  BlockFunctionBody
    addTestSource('main(){var a; if (^)}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_ifStatement_empty() async {
    // SimpleIdentifier  PrefixIdentifier  IfStatement
    addTestSource('class A {foo() {A a; if (^) something}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_ifStatement_invocation() async {
    // SimpleIdentifier  PrefixIdentifier  IfStatement
    addTestSource('main() {var a; if (a.^) something}');
    await assertOpType(
        constructors: true, returnValue: true, typeNames: true, prefixed: true);
  }

  Future<void> test_implementsClause_beginning() async {
    // ImplementsClause  ClassDeclaration
    addTestSource('class x implements ^\n{}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_importDirective_dart() async {
    // SimpleStringLiteral  ImportDirective
    addTestSource('''
      import "dart^";
      main() {}''');
    await assertOpType();
  }

  Future<void> test_indexExpression_emptyIndex() async {
    addTestSource('class C {foo(){var f; {var x;} f[^]}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_indexExpression_nonEmptyIndex() async {
    addTestSource('class C {foo(){var f; {var x;} f[T^]}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_instanceCreationExpression_afterNew() async {
    // SimpleIdentifier  TypeName  ConstructorName  InstanceCreationExpression
    addTestSource('class C {foo(){var f; {var x;} new ^}}');
    await assertOpType(constructors: true);
  }

  Future<void> test_instanceCreationExpression_keyword() async {
    // InstanceCreationExpression  ExpressionStatement  Block
    addTestSource('class C {foo(){var f; {var x;} new^ }}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_instanceCreationExpression_keyword2() async {
    // InstanceCreationExpression  ExpressionStatement  Block
    addTestSource('class C {foo(){var f; {var x;} new^ C();}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_instanceCreationExpression_trailingStmt() async {
    // SimpleIdentifier  TypeName  ConstructorName  InstanceCreationExpression
    addTestSource('class C {foo(){var f; {var x;} new ^ int x = 7;}}');
    await assertOpType(constructors: true);
  }

  Future<void> test_integerLiteral_inArgumentList() async {
    addTestSource('main() { print(1^); }');
    await assertOpType();
  }

  Future<void> test_integerLiteral_inListLiteral() async {
    addTestSource('main() { var items = [1^]; }');
    await assertOpType();
  }

  Future<void> test_interpolationExpression_afterDollar() async {
    // SimpleIdentifier  InterpolationExpression  StringInterpolation
    addTestSource('main() {String name; print("hello \$^");}');
    await assertOpType(constructors: true, returnValue: true);
  }

  Future<void> test_interpolationExpression_block() async {
    // SimpleIdentifier  InterpolationExpression  StringInterpolation
    addTestSource('main() {String name; print("hello \${n^}");}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_interpolationExpression_prefix_selector() async {
    // SimpleIdentifier  PrefixedIdentifier  InterpolationExpression
    addTestSource('main() {String name; print("hello \${name.^}");}');
    await assertOpType(
        constructors: true, returnValue: true, typeNames: true, prefixed: true);
  }

  Future<void> test_interpolationExpression_prefix_target() async {
    // SimpleIdentifier  PrefixedIdentifier  InterpolationExpression
    addTestSource('main() {String name; print("hello \${nam^e.length}");}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_isExpression_target() async {
    // IfStatement  Block  BlockFunctionBody
    addTestSource('main(){var a; if (^ is A)}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_isExpression_type_empty() async {
    // SimpleIdentifier  TypeName  IsExpression  IfStatement
    addTestSource('main() {var x; if (x is ^) { }}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_isExpression_type_partial() async {
    // SimpleIdentifier  TypeName  IsExpression  IfStatement
    addTestSource('main(){var a; if (a is Obj^)}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_literal_list() async {
    // ']'  ListLiteral  ArgumentList  MethodInvocation
    addTestSource('main() {var Some; print([^]);}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_literal_list2() async {
    // SimpleIdentifier ListLiteral  ArgumentList  MethodInvocation
    addTestSource('main() {var Some; print([S^]);}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_literal_string() async {
    // SimpleStringLiteral  ExpressionStatement  Block
    addTestSource('class A {a() {"hel^lo"}}');
    await assertOpType();
  }

  Future<void> test_mapLiteralEntry_emptyKey() async {
    // MapLiteralEntry  MapLiteral  VariableDeclaration
    addTestSource('foo = {^');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_mapLiteralEntry_partialKey() async {
    // MapLiteralEntry  MapLiteral  VariableDeclaration
    addTestSource('foo = {T^');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_mapLiteralEntry_value() async {
    // SimpleIdentifier  MapLiteralEntry  MapLiteral  VariableDeclaration
    addTestSource('foo = {7:T^};');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_methodDeclaration_inClass1() async {
    // SimpleIdentifier  MethodDeclaration  ClassDeclaration
    addTestSource('class Bar {const ^Fara();}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodDeclaration_inClass2() async {
    // SimpleIdentifier  MethodDeclaration  ClassDeclaration
    addTestSource('class Bar {const F^ara();}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodDeclaration_inClass_inLineComment() async {
    // Comment  ClassDeclaration  CompilationUnit
    addTestSource('''
      class C2 {
        // normal comment ^
        zoo(z) { } String name; }''');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_inLineComment2() async {
    // Comment  ClassDeclaration  CompilationUnit
    addTestSource('''
      class C2 {
        // normal ^comment
        zoo(z) { } String name; }''');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_inLineComment3() async {
    // Comment  ClassDeclaration  CompilationUnit
    addTestSource('''
      class C2 {
        // normal comment ^
        // normal comment 2
        zoo(z) { } String name; }''');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_inLineDocComment() async {
    // Comment  MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('''
      class C2 {
        /// some dartdoc ^
        zoo(z) { } String name; }''');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_inLineDocComment2() async {
    // Comment  MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('''
      class C2 {
        /// some ^dartdoc
        zoo(z) { } String name; }''');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_inStarComment() async {
    // Comment  ClassDeclaration  CompilationUnit
    addTestSource('class C2 {/* ^ */ zoo(z) {} String name;}');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_inStarComment2() async {
    // Comment  ClassDeclaration  CompilationUnit
    addTestSource('class C2 {/*  *^/ zoo(z) {} String name;}');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_inStarDocComment() async {
    // Comment  MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('class C2 {/** ^ */ zoo(z) { } String name; }');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_inStarDocComment2() async {
    // Comment  MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('class C2 {/**  *^/ zoo(z) { } String name; }');
    await assertOpType();
  }

  Future<void> test_methodDeclaration_inClass_returnType() async {
    // ClassDeclaration  CompilationUnit
    addTestSource('class C2 {^ zoo(z) { } String name; }');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_methodDeclaration_inClass_returnType_afterLineComment() async {
    // MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('''
      class C2 {
        // normal comment
        ^ zoo(z) {} String name;}''');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_methodDeclaration_inClass_returnType_afterLineComment2() async {
    // MethodDeclaration  ClassDeclaration  CompilationUnit
    // TOD(danrubel) left align all test source
    addTestSource('''
class C2 {
  // normal comment
^ zoo(z) {} String name;}''');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_methodDeclaration_inClass_returnType_afterLineDocComment() async {
    // SimpleIdentifier  MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('''
      class C2 {
        /// some dartdoc
        ^ zoo(z) { } String name; }''');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_methodDeclaration_inClass_returnType_afterLineDocComment2() async {
    // SimpleIdentifier  MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('''
class C2 {
  /// some dartdoc
^ zoo(z) { } String name; }''');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_methodDeclaration_inClass_returnType_afterStarComment() async {
    // ClassDeclaration  CompilationUnit
    addTestSource('class C2 {/* */ ^ zoo(z) { } String name; }');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_methodDeclaration_inClass_returnType_afterStarComment2() async {
    // ClassDeclaration  CompilationUnit
    addTestSource('class C2 {/* */^ zoo(z) { } String name; }');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_methodDeclaration_inClass_returnType_afterStarDocComment() async {
    // MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('class C2 {/** */ ^ zoo(z) { } String name; }');
    await assertOpType(typeNames: true);
  }

  Future<void>
      test_methodDeclaration_inClass_returnType_afterStarDocComment2() async {
    // MethodDeclaration  ClassDeclaration  CompilationUnit
    addTestSource('class C2 {/** */^ zoo(z) { } String name; }');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodDeclaration_inExtension2_inName() async {
    // SimpleIdentifier  ExtensionDeclaration  MixinDeclaration
    addTestSource('extension E on int {const F^ara();}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodDeclaration_inExtension_beforeName() async {
    // SimpleIdentifier  ExtensionDeclaration  MixinDeclaration
    addTestSource('extension E on int {const ^Fara();}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodDeclaration_inExtension_returnType() async {
    // ExtensionDeclaration  CompilationUnit
    addTestSource('extension E on int {^ zoo(z) { } String name; }');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodDeclaration_inMixin1() async {
    // SimpleIdentifier  MethodDeclaration  MixinDeclaration
    addTestSource('mixin M {const ^Fara();}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodDeclaration_inMixin2() async {
    // SimpleIdentifier  MethodDeclaration  MixinDeclaration
    addTestSource('mixin M {const F^ara();}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodDeclaration_inMixin_returnType() async {
    // MixinDeclaration  CompilationUnit
    addTestSource('mixin M {^ zoo(z) { } String name; }');
    await assertOpType(typeNames: true);
  }

  Future<void> test_methodInvocation_no_semicolon() async {
    // MethodInvocation  ExpressionStatement  Block
    addTestSource('''
      class A implements I {
        // no semicolon between completion point and next statement
        set _s2(I x) {x.^ m(null);}
      }''');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_mixinDeclaration_body() async {
    // MixinDeclaration  CompilationUnit
    addTestSource('mixin M {^}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_mixinDeclaration_body2() async {
    // SimpleIdentifier  MethodDeclaration  MixinDeclaration
    addTestSource('mixin M {^mth() {}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_namedExpression_beforeName() async {
    addTestSource('''
main() { f(3, ^); }
void f(int a, {int b}) {}
''');
    await assertOpType(namedArgs: true);
  }

  Future<void> test_onClause_beginning() async {
    // OnClause  MixinDeclaration
    addTestSource('mixin M on ^\n{}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_postfixExpression_inOperator() async {
    // SimpleIdentifier  PostfixExpression  ForStatement
    addTestSource('int x = 0; main() {ax+^+;}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_prefixedIdentifier_class_const() async {
    // SimpleIdentifier PrefixedIdentifier ExpressionStatement Block
    addTestSource('main() {A.^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_prefixedIdentifier_class_imported() async {
    // SimpleIdentifier  PrefixedIdentifier  ExpressionStatement
    addTestSource('main() {A a; a.^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_prefixedIdentifier_prefix() async {
    // SimpleIdentifier  PrefixedIdentifier  ExpressionStatement
    addTestSource('class X {foo(){A^.bar}}');
    await assertOpType(
        constructors: true,
        typeNames: true,
        returnValue: true,
        voidReturn: true);
  }

  Future<void> test_propertyAccess_expression() async {
    // SimpleIdentifier  MethodInvocation  PropertyAccess  ExpressionStatement
    addTestSource('class A {a() {"hello".to^String().length}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_propertyAccess_noTarget() async {
    // SimpleIdentifier  PropertyAccess  ExpressionStatement
    addTestSource('main() {.^}');
    await assertOpType();
  }

  Future<void> test_propertyAccess_noTarget2() async {
    // SimpleIdentifier  PropertyAccess  CascadeExpressions
    addTestSource('main() {.^.}');
    await assertOpType();
  }

  Future<void> test_propertyAccess_noTarget3() async {
    // SimpleIdentifier  PropertyAccess  CascadeExpressions
    addTestSource('main() {..^}');
    await assertOpType();
  }

  Future<void> test_propertyAccess_selector() async {
    // SimpleIdentifier  PropertyAccess  ExpressionStatement  Block
    addTestSource('class A {a() {"hello".length.^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_returnStatement_empty() async {
    // ReturnStatement  Block
    addTestSource('f() { var vvv = 42; return ^ }');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_simpleFormalParameter_closure() async {
    // SimpleIdentifier  SimpleFormalParameter  FormalParameterList
    addTestSource('mth() { PNGS.sort((String a, Str^) => a.compareTo(b)); }');
    await assertOpType(typeNames: true);
  }

  Future<void> test_simpleFormalParameter_functionType_name() async {
    addTestSource('void Function(int ^) v;');
    await assertOpType(typeNames: false, varNames: true);
  }

  Future<void> test_simpleFormalParameter_functionType_name_named() async {
    addTestSource('void Function({int ^}) v;');
    await assertOpType(typeNames: false, varNames: true);
  }

  Future<void> test_simpleFormalParameter_functionType_name_optional() async {
    addTestSource('void Function([int ^]) v;');
    await assertOpType(typeNames: false, varNames: true);
  }

  Future<void> test_simpleFormalParameter_functionType_type_withName() async {
    addTestSource('void Function(Str^ name) v;');
    await assertOpType(typeNames: true, varNames: false);
  }

  Future<void> test_simpleFormalParameter_functionType_type_withName2() async {
    addTestSource('void Function(^ name) v;');
    await assertOpType(typeNames: true, varNames: false);
  }

  Future<void> test_simpleFormalParameter_name_typed() async {
    addTestSource('f(String ^, int b) {}');
    await assertOpType(typeNames: false, varNames: true);
  }

  Future<void> test_simpleFormalParameter_name_typed_hasName() async {
    addTestSource('f(String n^, int b) {}');
    await assertOpType(typeNames: false, varNames: true);
  }

  Future<void> test_simpleFormalParameter_name_typed_last() async {
    addTestSource('f(String ^) {}');
    await assertOpType(typeNames: false, varNames: true);
  }

  Future<void> test_simpleFormalParameter_name_typed_last_hasName() async {
    addTestSource('f(String n^) {}');
    await assertOpType(typeNames: false, varNames: true);
  }

  Future<void> test_simpleFormalParameter_type_named() async {
    addTestSource('f(^ name) {}');
    await assertOpType(typeNames: true, varNames: false);
  }

  Future<void> test_simpleFormalParameter_type_optionalNamed() async {
    // SimpleIdentifier  DefaultFormalParameter  FormalParameterList
    addTestSource('m({Str^}) {}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_simpleFormalParameter_type_optionalPositional() async {
    // SimpleIdentifier  DefaultFormalParameter  FormalParameterList
    addTestSource('m([Str^]) {}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_simpleFormalParameter_type_withName() async {
    // SimpleIdentifier  SimpleFormalParameter  FormalParameterList
    addTestSource('m(Str^ name) {}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_simpleFormalParameter_type_withoutName1() async {
    // SimpleIdentifier  SimpleFormalParameter  FormalParameterList
    addTestSource('m(Str^) {}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_simpleFormalParameter_type_withoutName2() async {
    // FormalParameterList
    addTestSource('m(^) {}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_simpleFormalParameter_type_withoutName3() async {
    // SimpleIdentifier  SimpleFormalParameter  FormalParameterList
    addTestSource('m(int first, Str^) {}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_simpleFormalParameter_untyped() async {
    addTestSource('main(final ^) {}');
    await assertOpType(typeNames: true, varNames: false);
  }

  Future<void> test_spreadElement_emptyExpression() async {
    addTestSource(r'''
main() {
  [...^];
}
''');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_switchCase_before() async {
    // SwitchCase  SwitchStatement  Block
    addTestSource('main() {switch(k) {^case 1:}}');
    await assertOpType();
  }

  Future<void> test_switchCase_between() async {
    // SwitchCase  SwitchStatement  Block
    addTestSource('main() {switch(k) {case 1: ^ case 2: return}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_switchCase_expression1() async {
    // SimpleIdentifier  SwitchCase  SwitchStatement
    addTestSource('''m() {switch (x) {case ^D: return;}}''');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_switchCase_expression2() async {
    // SimpleIdentifier  SwitchCase  SwitchStatement
    addTestSource('''m() {switch (x) {case ^}}''');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_switchDefault_before() async {
    // SwitchDefault  SwitchStatement  Block
    addTestSource('main() {switch(k) { ^ default: return;}}');
    await assertOpType();
  }

  Future<void> test_switchDefault_between() async {
    // SwitchDefault  SwitchStatement  Block
    addTestSource('main() {switch(k) {case 1: ^ default: return;}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_switchStatement_body_empty() async {
    // Token('}')  SwitchStatement  Block
    addTestSource('main() {switch(k) {^}}');
    await assertOpType();
  }

  Future<void> test_switchStatement_body_end() async {
    // Token('}')  SwitchStatement  Block
    addTestSource('main() {switch(k) {case 1:^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_switchStatement_body_end2() async {
    addTestSource('main() {switch(k) {case 1:as^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_switchStatement_expression1() async {
    // SimpleIdentifier  SwitchStatement  Block
    addTestSource('main() {switch(^k) {case 1:{}}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_switchStatement_expression2() async {
    // SimpleIdentifier  SwitchStatement  Block
    addTestSource('main() {switch(k^) {case 1:{}}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_switchStatement_expression_empty() async {
    // SimpleIdentifier  SwitchStatement  Block
    addTestSource('main() {switch(^) {case 1:{}}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_thisExpression_block() async {
    // MethodInvocation  ExpressionStatement  Block
    addTestSource('''
      class A implements I {
        // no semicolon between completion point and next statement
        set s1(I x) {} set _s2(I x) {this.^ m(null);}
      }''');
    // TODO(brianwilkerson) We should not be adding constructors here.
    await assertOpType(
        constructors: true,
        returnValue: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_thisExpression_constructor() async {
    // SimpleIdentifier  PropertyAccess  ExpressionStatement
    addTestSource('''
      class A implements I {
        A() {this.^}
      }''');
    await assertOpType(
        constructors: true,
        returnValue: true,
        voidReturn: true,
        prefixed: true);
  }

  Future<void> test_thisExpression_constructor_param() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
      class A implements I {
        A(this.^) {}
      }''');
    await assertOpType(prefixed: true);
  }

  Future<void> test_thisExpression_constructor_param2() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
      class A implements I {
        A(this.f^) {}
      }''');
    await assertOpType(prefixed: true);
  }

  Future<void> test_thisExpression_constructor_param3() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
      class A implements I {
        A(this.^f) {}
      }''');
    await assertOpType(prefixed: true);
  }

  Future<void> test_thisExpression_constructor_param4() async {
    // FieldFormalParameter  FormalParameterList  ConstructorDeclaration
    addTestSource('''
      class A implements I {
        A(Str^ this.foo) {}
      }''');
    await assertOpType(typeNames: true);
  }

  Future<void> test_throwExpression_empty() async {
    // SimpleIdentifier  ThrowExpression  ExpressionStatement
    addTestSource('main() {throw ^;}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_topLevelVariableDeclaration_typed_name() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // TopLevelVariableDeclaration
    // _OpTypeAstVisitor.visitVariableDeclarationList is executed with this
    // source, but _OpTypeAstVisitor.visitTopLevelVariableDeclaration is called
    // for test_topLevelVariableDeclaration_typed_name_semicolon
    addTestSource('class A {} B ^');
    await assertOpType(varNames: true);
  }

  Future<void> test_topLevelVariableDeclaration_typed_name_semicolon() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // TopLevelVariableDeclaration
    // See comment in test_topLevelVariableDeclaration_typed_name
    addTestSource('class A {} B ^;');
    await assertOpType(varNames: true);
  }

  Future<void> test_topLevelVariableDeclaration_untyped_name() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // TopLevelVariableDeclaration
    addTestSource('class A {} var ^');
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_1a() async {
    // '}'  Block  BlockFunctionBody  FunctionExpression
    addTestSource('main() {try {} ^}');
    // Only return 'on', 'catch', and 'finally' keywords
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_1b() async {
    // [ExpressionStatement 'c']  Block  BlockFunctionBody
    addTestSource('main() {try {} c^}');
    // Only return 'on', 'catch', and 'finally' keywords
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_1c() async {
    // [EmptyStatement]  Block  BlockFunctionBody  FunctionExpression
    addTestSource('main() {try {} ^;}');
    // Only return 'on', 'catch', and 'finally' keywords
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_1d() async {
    // [VariableDeclarationStatement 'Foo foo']  Block  BlockFunctionBody
    addTestSource('main() {try {} ^ Foo foo;}');
    // Only return 'on', 'catch', and 'finally' keywords
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_2a() async {
    // '}'  Block  BlockFunctionBody  FunctionExpression
    addTestSource('main() {try {} catch () {} ^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catch_2b() async {
    // [ExpressionStatement 'c']  Block  BlockFunctionBody
    addTestSource('main() {try {} catch () {} c^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catch_2c() async {
    // [EmptyStatement]  Block  BlockFunctionBody  FunctionExpression
    addTestSource('main() {try {} catch () {} ^;}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catch_2d() async {
    // [VariableDeclarationStatement 'Foo foo']  Block  BlockFunctionBody
    addTestSource('main() {try {} catch () {} ^ Foo foo;}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catch_3a() async {
    // '}'  Block  BlockFunctionBody  FunctionExpression
    addTestSource('main() {try {} finally {} ^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catch_3b() async {
    // [ExpressionStatement 'c']  Block  BlockFunctionBody
    addTestSource('main() {try {} finally {} c^}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catch_3c() async {
    // [EmptyStatement]  Block  BlockFunctionBody  FunctionExpression
    addTestSource('main() {try {} finally {} ^;}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catch_3d() async {
    // [VariableDeclarationStatement 'Foo foo']  Block  BlockFunctionBody
    addTestSource('main() {try {} finally {} ^ Foo foo;}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catch_4a1() async {
    addTestSource('main() {try {} ^ on SomeException {}}');
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_4a2() async {
    addTestSource('main() {try {} c^ on SomeException {}}');
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_4b1() async {
    addTestSource('main() {try {} ^ catch (e) {}}');
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_4b2() async {
    addTestSource('main() {try {} c^ catch (e) {}}');
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_4c1() async {
    addTestSource('main() {try {} ^ finally {}}');
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_4c2() async {
    addTestSource('main() {try {} c^ finally {}}');
    await assertOpType();
  }

  Future<void> test_tryStatement_catch_5a() async {
    addTestSource('main() {try {} on ^ finally {}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_tryStatement_catch_5b() async {
    addTestSource('main() {try {} on E^ finally {}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_tryStatement_catchClause_onType() async {
    // TypeName  CatchClause  TryStatement
    addTestSource('class A {a() {try{var x;} on ^ {}}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_tryStatement_catchClause_onType_noBrackets() async {
    // TypeName  CatchClause  TryStatement
    addTestSource('class A {a() {try{var x;} on ^}}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_tryStatement_catchClause_typed() async {
    // Block  CatchClause  TryStatement
    addTestSource('class A {a() {try{var x;} on E catch (e) {^}}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_tryStatement_catchClause_untyped() async {
    // Block  CatchClause  TryStatement
    addTestSource('class A {a() {try{var x;} catch (e, s) {^}}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_typeArgumentList_empty() async {
    // SimpleIdentifier  BinaryExpression  ExpressionStatement
    addTestSource('main() { C<^> c; }');
    await assertOpType(typeNames: true);
  }

  Future<void> test_typeArgumentList_partial() async {
    // TypeName  TypeArgumentList  TypeName
    addTestSource('main() { C<C^> c; }');
    await assertOpType(typeNames: true);
  }

  Future<void> test_typeParameter_beforeType() async {
    // SimpleIdentifier  TypeParameter  TypeParameterList
    addTestSource('class tezetst <String, ^List> {}');
    await assertOpType();
  }

  Future<void> test_typeParameterList_empty() async {
    // SimpleIdentifier  TypeParameter  TypeParameterList
    addTestSource('class tezetst <^> {}');
    await assertOpType();
  }

  Future<void> test_variableDeclaration_name() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('main() {var ^}');
    await assertOpType();
  }

  Future<void> test_variableDeclaration_name_hasSome_parameterizedType() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('main() {List<int> m^}');
    await assertOpType(varNames: true);
  }

  Future<void> test_variableDeclaration_name_hasSome_simpleType() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // VariableDeclarationStatement  Block
    addTestSource('main() {String m^}');
    await assertOpType(varNames: true);
  }

  Future<void> test_variableDeclarationList_final() async {
    // VariableDeclarationList  VariableDeclarationStatement  Block
    addTestSource('main() {final ^}');
    await assertOpType(typeNames: true);
  }

  Future<void> test_variableDeclarationStatement_afterSemicolon() async {
    // VariableDeclarationStatement  Block  BlockFunctionBody
    addTestSource('class A {var a; x() {var b;^}}');
    await assertOpType(
        constructors: true,
        returnValue: true,
        typeNames: true,
        voidReturn: true);
  }

  Future<void> test_variableDeclarationStatement_RHS() async {
    // SimpleIdentifier  VariableDeclaration  VariableDeclarationList
    // VariableDeclarationStatement
    addTestSource('class C {bar(){var f; {var x;} var e = ^}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_variableDeclarationStatement_RHS_missing_semicolon() async {
    // VariableDeclaration  VariableDeclarationList
    // VariableDeclarationStatement
    addTestSource('class C {bar(){var f; {var x;} var e = ^ var g}}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  Future<void> test_whileStatement_expression() async {
    // SimpleIdentifier  WhileStatement  Block
    addTestSource('mth() { while (b^) {} }}');
    await assertOpType(constructors: true, returnValue: true, typeNames: true);
  }

  @failingTest
  Future<void> test_withClause_empty() async {
    // WithClause  ClassDeclaration
    addTestSource('class x extends Object with ^\n{}');
    await assertOpType(constructors: true, typeNames: true);
  }
}
