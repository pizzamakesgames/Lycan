package constraint;
import openfl.Vector;

private typedef TermParameter = OneOfTwo<Term, Vector<Term>>; // TODO

class Expression {
	private var terms:Vector<Term>;
	public var constant(get, null):Float;
	public var value(get, never):Float;
	
	public function new(?terms:TermParameter, ?constant:Float = 0.0) {
		this.terms = terms;
		this.constant = constant;
	}
	
	private function get_constant():Float {
		return constant;
	}
	
	private function get_value():Float {
		var result = constant;
		for (term in terms) {
			result += term.value;
		}
		
		return result;
	}
}