#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_PATH="$REPO_ROOT/docs"
HOSTING_BASE_PATH="CDYelpFusionKit"
DOCS_ROOT="/$HOSTING_BASE_PATH/documentation/cdyelpfusionkit/"

echo "Generating DocC documentation..."
swift package --disable-sandbox generate-documentation \
    --target CDYelpFusionKit \
    --output-path "$OUTPUT_PATH" \
    --transform-for-static-hosting \
    --hosting-base-path "$HOSTING_BASE_PATH"

# GitHub Pages runs Jekyll by default, which can corrupt the binary LMDB
# index files DocC uses for search. This bypasses Jekyll entirely.
touch "$OUTPUT_PATH/.nojekyll"

# DocC overwrites the root index.html with its own app shell on every run.
# Restore the meta-refresh redirect so the bare GitHub Pages URL forwards
# cleanly to the documentation root.
cat > "$OUTPUT_PATH/index.html" <<EOF
<!doctype html>
<html lang="en-US">
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url=$DOCS_ROOT">
  <link rel="canonical" href="$DOCS_ROOT">
</head>
<body>
  <p>Redirecting to <a href="$DOCS_ROOT">CDYelpFusionKit documentation</a>…</p>
</body>
</html>
EOF

# Redirect any unknown URLs to the documentation root rather than showing
# a bare GitHub 404. All valid pages have their own index.html (generated
# by --transform-for-static-hosting), so a true 404 means a bad URL.
cat > "$OUTPUT_PATH/404.html" <<EOF
<!doctype html>
<html lang="en-US">
<head>
  <meta charset="utf-8">
  <title>CDYelpFusionKit Documentation</title>
  <script>window.location.replace('$DOCS_ROOT');</script>
  <noscript><meta http-equiv="refresh" content="0;url=$DOCS_ROOT"></noscript>
</head>
<body></body>
</html>
EOF

echo "Done. Output written to $OUTPUT_PATH"
