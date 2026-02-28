import java.io.File;
import java.io.IOException;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

/**
 * Mirrors the lexbor/vsoup selector benchmark methodology exactly:
 * - Same HTML (average.html)
 * - Same 10 selectors
 * - 5 iterations x 10,000 reps, mean time in seconds
 */
public class JsoupBenchmark {

  static final String[] SELECTORS = {
    "div",
    "div span",
    "p ~ p",
    "p + p",
    "div > p",
    "div > div",
    "div p:not(#p-5) a",
    "div:has(a) a",
    "div p:nth-child(n+2)",
    // jsoup doesn't support "nth-child(An+B of S)" syntax, skip last one
  };

  static final int ITERATIONS = 5;
  static final int REPEAT = 10000;

  public static void main(String[] args) throws IOException {
    String htmlPath =
      args.length > 0
        ? args[0]
        : "lexbor/benchmarks/lexbor/selectors/files/average.html";

    String html = new String(
      java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(htmlPath))
    );

    System.out.println("jsoup selector benchmark");
    System.out.printf("HTML: %s (%d bytes)%n", htmlPath, html.length());
    System.out.printf(
      "Method: mean of %d iterations x %d reps%n",
      ITERATIONS,
      REPEAT
    );
    System.out.println();

    // Parse once (same as vsoup cached API — document is reused)
    Document doc = Jsoup.parse(html);

    // Warmup JIT
    for (int w = 0; w < 1000; w++) {
      doc.select("div");
    }

    for (String sel : SELECTORS) {
      double mean = 0;
      for (int i = 0; i < ITERATIONS; i++) {
        long start = System.nanoTime();
        for (int r = 0; r < REPEAT; r++) {
          doc.select(sel);
        }
        long elapsed = System.nanoTime() - start;
        mean += elapsed / 1_000_000_000.0;
      }
      mean /= ITERATIONS;
      System.out.printf(
        "Run: %s; Repeat: %d; Result: %.5f sec%n",
        sel,
        REPEAT,
        mean
      );
    }
  }
}
