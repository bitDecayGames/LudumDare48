package metrics;

import com.bitdecay.analytics.Bitlytics;

class Metrics {
	public static inline var MAX_DEPTH = "maxDepth";
	public static inline var FOLLOW_MOLES = "followMoles";
	public static inline var RESCUE_MOLES = "rescuedMoles";

	public static inline var DEATH = "death";

	private static var maxDepth = 0;
	private static var maxFollow = 0;

	public static function reportDepth(d:Int) {
		if (d > maxDepth) {
			maxDepth = d;
			if (maxDepth % 10 == 0) {
				// only report in increments of 10 to save payload size;
				Bitlytics.Instance().Queue(MAX_DEPTH, d);
			}
		}
	}

	public static function reportMolesFollowing(count:Int) {
		if (count > maxFollow) {
			Bitlytics.Instance().Queue(FOLLOW_MOLES, count);
			maxFollow = count;
		}
	}

	public static function reportMolesRescued(count:Int) {
		Bitlytics.Instance().Queue(RESCUE_MOLES, count);
	}
}