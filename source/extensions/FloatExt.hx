package extensions;

class FloatExt {
	public static function floor(f:Float):Int {
		return Std.int(f);
	}

	public static function ceil(f:Float):Int {
		return Std.int(f+1);
	}
}