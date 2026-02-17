"""Calculator tool for evaluating mathematical expressions safely."""
import ast
import operator
from langchain_core.tools import tool

_SAFE_OPS = {
    ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul,
    ast.Div: operator.truediv, ast.Pow: operator.pow, ast.Mod: operator.mod,
    ast.FloorDiv: operator.floordiv, ast.USub: operator.neg, ast.UAdd: operator.pos,
}

def _safe_eval(node):
    if isinstance(node, ast.Expression): return _safe_eval(node.body)
    elif isinstance(node, ast.Constant):
        if isinstance(node.value, (int, float)): return node.value
        raise ValueError(f"Unsupported constant: {node.value}")
    elif isinstance(node, ast.BinOp):
        op = _SAFE_OPS.get(type(node.op))
        if op is None: raise ValueError(f"Unsupported operator: {type(node.op).__name__}")
        return op(_safe_eval(node.left), _safe_eval(node.right))
    elif isinstance(node, ast.UnaryOp):
        op = _SAFE_OPS.get(type(node.op))
        if op is None: raise ValueError(f"Unsupported operator: {type(node.op).__name__}")
        return op(_safe_eval(node.operand))
    else: raise ValueError(f"Unsupported expression: {type(node).__name__}")

@tool
def calculator(expression: str) -> str:
    """Evaluate a mathematical expression and return the result.
    Supports: +, -, *, /, **, %, //. Examples: '2 + 2', '(15 * 3.5) / 7'
    """
    try:
        tree = ast.parse(expression.strip(), mode="eval")
        result = _safe_eval(tree)
        return f"{expression} = {result}"
    except (ValueError, SyntaxError, TypeError, ZeroDivisionError) as e:
        return f"Error evaluating '{expression}': {e}"
