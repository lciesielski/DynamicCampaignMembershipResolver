public class ReversePolishNotation {

	public static final String TRUE_SHORT = 't';
	public static final String FALSE_SHORT = 'f';

	public static final String AND_OPERATOR = ' AND ';
	public static final String OR_OPERATOR = ' OR ';

	public static final String LEFT_PARENTHESIS = '(';
	public static final String RIGHT_PARENTHESIS = ')';
	
	private static final String NEGATION_OPERATOR = '!';

	private static final Map<String,Integer> operatorsPriorities = new Map<String,Integer>{
		'-' => 3, // NOT - unary
		'*' => 2, // AND binary
		'+' => 1, // OR binary
		LEFT_PARENTHESIS => -1, 
		RIGHT_PARENTHESIS => -2
	};

	public static Boolean evaluateString(String param){
		return evalRPN(buildRPN(param));
	}

	private static String buildRPN(String param){
		final List<String> stack = new List<String>();
		param = param
			.toUpperCase()
			.replace(' ','')
			.replace(AND_OPERATOR.trim(),'*')
			.replace(OR_OPERATOR.trim(),'+')
			.replace(NEGATION_OPERATOR,'-')
			.trim();
		String result = '';
		Integer counter = 0;
		
		while (counter < param.length()) {
			final String p = param.substring(counter, counter + 1);

			if (p == TRUE_SHORT || p == FALSE_SHORT) {
				result += p;
			} else {
				if (operatorsPriorities.get(p) == -1) {
					stack.add(p);
				} else if (operatorsPriorities.get(p) == -2) {
					while(stack.get(stack.size() - 1) != '(') {
						result += stack.remove(stack.size() - 1);
					}
					stack.remove(stack.size() - 1);
				} else {
					while (stack.size() > 0 && operatorsPriorities.get(p) <= operatorsPriorities.get(stack.get(stack.size() - 1))){
						result += stack.remove(stack.size() - 1);
					}
					stack.add(p);
				}
			}
			counter++;
		}

		while (stack.size()> 0) {
			result += stack.remove(stack.size() - 1);
		}

		return result;
	}

	private static Boolean evalRPN(String rpn){
		final List<String> elements = rpn.split('');
		Integer position = 0;

		while (elements.size() > 1) {
			final String element = elements.get(position);

			if (element == TRUE_SHORT || element == FALSE_SHORT) {
				position++;
			} else {
				if (element == '-') {
					elements.set(position - 1, opposite(elements.get(position - 1)));
					elements.remove(position);
					position--;
				} else if (element == '*') {
					String res = (elements.get(position - 2) == FALSE_SHORT || elements.get(position - 1) == FALSE_SHORT) ? FALSE_SHORT : TRUE_SHORT;
					elements.set(position - 2, res);
					elements.remove(position);
					elements.remove(position - 1);
					position -= 2;
				} else if (element == '+') {
					String res = (elements.get(position - 2) == TRUE_SHORT || elements.get(position - 1) == TRUE_SHORT) ? TRUE_SHORT : FALSE_SHORT;
					elements.set(position - 2, res);
					elements.remove(position);
					elements.remove(position - 1);
					position -= 2;
				}
			}
		}

		return (elements.get(0) == TRUE_SHORT) ? true : false;
	}

	private static String opposite(String param){
		return (param == TRUE_SHORT) ? FALSE_SHORT : TRUE_SHORT;
	}

}