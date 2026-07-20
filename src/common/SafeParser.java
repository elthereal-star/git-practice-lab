package common;

/**
 * Simulated hotfix on production: guard against null input
 * that caused NPE in the online environment.
 */
public class SafeParser {

    public static int parseIntSafely(String value, int fallback) {
        // hotfix: return fallback instead of throwing NPE on null
        if (value == null) {
            return fallback;
        }
        return Integer.parseInt(value);
    }
}
