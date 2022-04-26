{ pkgs }:
with pkgs;
with lib;
rec {
  mkSite = {
    base_url,
    pages,
    preGen ? "",
    postGen ? "",
  }:
  assert (builtins.isString base_url);
  assert (builtins.isList pages);
  assert (builtins.isString preGen);
  assert (builtins.isString postGen);
  runCommand base_url {} (let
    genPageList = map ( value: ''
      mkdir -p $(dirname $out${value.path})
      cp -r ${value.file} $out${value.path}
    '') pages;

    genStr = concatStringsSep "\n" (genPageList);
  in ''
    mkdir $out
    ${preGen}
    ${genStr}
    ${postGen}
  '');

  mkFile = path: file: { inherit path file; };
  mkFolder = path: files: {
    inherit path;
    file = runCommand path {} (let
      genPageList = attrsets.mapAttrsToList ( _name: value: ''
        mkdir -p $(dirname $out${value.path})
        cp -r ${value.file} $out${value.path}
      '') files;

      genStr = concatStringsSep "\n" (genPageList);
    in ''
      mkdir $out
      ${genStr}
    '');
  };

  substitute =
    substitutions:
    inFile:
    runCommand
    ((fileName inFile) + ".substituted")
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
  in writeText body html;

  fileName = filePath: lists.last (pkgs.lib.strings.splitString "/" filePath);

  replaceExt =
    filePath:
    newExt:
    let
      fileNameNoExt = strings.concatStringsSep "." (pkgs.lib.lists.init (pkgs.lib.strings.splitString "." (fileName filePath)));
    in
    fileNameNoExt + newExt;

  # Available extensions for cmark-gfm:
  # - footnotes
  # - table
  # - strikethrough
  # - autolink
  # - tagfilter
  # - tasklist
  mdToHtml =
    md:
    runCommand
    (replaceExt md ".html")
    { buildInputs = [ pandoc ]; }
    "pandoc --from markdown+autolink_bare_uris --output $out ${md}";

  scssToCss =
    scss:
    runCommand
    (replaceExt scss ".css")
    { buildInputs = [ sassc ]; }
    "sassc ${scss} $out";

  svgToIco =
    svg:
    runCommand
    (replaceExt svg ".ico")
    { buildInputs = [ imagemagick ]; }
    "convert -resize 16x16 -background transparent ${svg} $out";

  svgToPng =
    svg:
    runCommand
    (replaceExt svg ".png")
    { buildInputs = [ imagemagick ]; }
    "convert ${svg} $out";

  mdToPdf =
    md:
    css:
    runCommand
    (replaceExt md ".pdf")
    { buildInputs = [ pandoc wkhtmltopdf ]; }
    "pandoc ${md} \\\
      --output $out \\\
      --css ${css} \\\
      --pdf-engine wkhtmltopdf \\\
      -V margin-top=20 \\\
      -V margin-bottom=20 \\\
      -V margin-left=30 \\\
      -V margin-right=30";

  camelCaseToKebabCase =
    string:
    concatStringsSep "-" (map toLower (splitString " " string));
}
