package common;

/**
 * Simulated bugfix: page numbers sent by the frontend start at 1,
 * but the old code used them as 0-based offsets directly.
 */
public class PageQuery {

    public static int toOffset(int page, int size) {
        // fix: convert 1-based page number to 0-based offset
        return (page - 1) * size;
    }
}
