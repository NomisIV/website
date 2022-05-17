{ pkgs }:
with pkgs;
with lib;
rec {
  mkSite = url: pages:
  runCommand url {} (let
    pageNamesFlat = attrsets.collect builtins.isString (
      attrsets.mapAttrsRecursive
      (path: value: strings.concatStringsSep "/" path)
      pages
    );

    pageMap = attrsets.genAttrs pageNamesFlat ( pageUrl:
      attrsets.getAttrFromPath (strings.splitString "/" pageUrl) pages
    );

    genPageList = attrsets.mapAttrsToList (name: value:
    ''
      mkdir -p $(dirname $out/${name})
      ln -s ${value} $out/${name}
    '') pageMap;
  in concatStringsSep "\n" (genPageList));

  substitute =
    substitutions:
    inFile:
    runCommand
    ((fileName inFile) + "-sub")
    {}
    (let
      nameFn = name: strings.escapeShellArg ("$" + name + "$");
      valueFn = value: strings.escapeShellArg value;

      mapFn = name: value: "--replace ${nameFn name} ${valueFn value}";

      subsList = mapAttrsToList mapFn substitutions;

      subsStr = concatStringsSep " " subsList;
    in
    ''
      substitute ${inFile} $out ${subsStr}
    '');

  htmlTemplate = {
    title,
    body,
    favicon ? null,
    stylesheets ? null,
    description ? null,
    themeColor ? null,
    openGraph ? null,
  }: with strings; let
    faviconStr =
      optionalString
      (favicon != null)
      "<link rel=\"icon\" type=\"image/x-icon\" href=\"${favicon}\">";

    stylesheetsStr =
      pkgs.lib.strings.optionalString
      (stylesheets != null)
      (
        concatMapStringsSep
        "\n"
        (stylesheet: "<link rel=\"stylesheet\" href=\"${stylesheet}\">")
        stylesheets
      );

    descriptionStr =
      optionalString
      (description != null)
      "<meta name=\"description\"  content=\"${description}\">";

    themeColorStr =
      optionalString
      (themeColor != null)
      "<meta name=\"theme-color\"  content=\"${themeColor}\">";

    openGraphStr =
      optionalString
      (openGraph != null)
      ''
        <meta property="og:url" content="https://${openGraph.url}/">
        <meta property="og:type" content="website">
        <meta property="og:title" content="${openGraph.title}">
        <meta property="og:description" content="${openGraph.description}">
        <meta property="og:image" content="${openGraph.image}">
        <meta property="og:image:type" content="image/png">
        <meta property="og:image:width" content="1200">
        <meta property="og:image:height" content="630">

        <meta name="twitter:card" content="summary_large_image">
        <meta name="twitter:domain" content="${openGraph.url}">
        <meta name="twitter:url" content="https://${openGraph.url}/">
        <meta name="twitter:title" content="${openGraph.title}">
        <meta name="twitter:description" content="${openGraph.description}">
        <meta name="twitter:image" content="${openGraph.image}">
      '';
    html = ''
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">

          ${faviconStr}
          ${stylesheetsStr}
          ${descriptionStr}
          ${themeColorStr}
          ${openGraphStr}

          <title>${title}</title>
        </head>
        <body>
        ${builtins.readFile body}
        </body>
      </html>
    '';
  in builtins.toString (writeText (fileName body) html);

  # remove the /nix/store/<hash>- part of a file path
  fileName = filePath:
    builtins.substring 44 (builtins.stringLength filePath) filePath;

  replaceExt =
    filePath:
    newExt:
    let
      fileNameNoExt = strings.concatStringsSep "." (
        lists.init
        (strings.splitString "." (fileName filePath))
      );
    in
    fileNameNoExt + newExt;

  mdToHtml =
    md:
    builtins.toString (
      runCommand
      (replaceExt md ".html")
      { buildInputs = [ pandoc ]; }
      "pandoc \\\
      --from markdown+autolink_bare_uris-implicit_figures \\\
      --output $out ${md}"
    );

  scssToCss =
    scss:
    builtins.toString (
      runCommand
      (replaceExt scss ".css")
      { buildInputs = [ sassc ]; }
      "sassc ${scss} $out"
    );

  svgToIco =
    svg:
    builtins.toString (
      runCommand
      (replaceExt svg ".ico")
      { buildInputs = [ imagemagick ]; }
      "convert -resize 16x16 -background transparent ${svg} $out"
    );

  svgToPng =
    svg:
    builtins.toString (
      runCommand
      (replaceExt svg ".png")
      { buildInputs = [ imagemagick ]; }
      "convert ${svg} $out"
    );

  mdToPdf =
    md:
    css:
    builtins.toString (
      runCommand
      (replaceExt md ".pdf")
      { buildInputs = [ pandoc wkhtmltopdf ]; }
      "pandoc ${md} \\\
      --output $out \\\
      --css ${css} \\\
      --pdf-engine wkhtmltopdf \\\
      --variable margin-top=20 \\\
      --variable margin-bottom=20 \\\
      --variable margin-left=30 \\\
      --variable margin-right=30"
    );

  camelCaseToKebabCase =
    string:
    concatStringsSep "-" (map toLower (splitString " " string));
}
