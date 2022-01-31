{ pkgs }:
rec {
  mkSite = {
    base_url,
    pages,
    preGen ? "",
    postGen ? "",
  }: pkgs.runCommand base_url {} (with pkgs.lib; let
    genPageList = attrsets.mapAttrsToList ( _name: value: ''
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
    file = pkgs.runCommand path {} (let
      genPageList = pkgs.lib.attrsets.mapAttrsToList ( _name: value: ''
        mkdir -p $(dirname $out${value.path})
        cp -r ${value.file} $out${value.path}
      '') files;

      genStr = pkgs.lib.concatStringsSep "\n" (genPageList);
    in ''
      mkdir $out
      ${genStr}
    '');
  };

  substitute =
    substitutions:
    inFile:
    pkgs.runCommand
    ((fileName inFile) + ".substituted")
    {}
    (let
      nameFn = name: pkgs.lib.strings.escapeShellArg ("$" + name + "$");
      valueFn = value: pkgs.lib.strings.escapeShellArg value;

      mapFn = name: value: "--replace ${nameFn name} ${valueFn value}";

      subsList = pkgs.lib.mapAttrsToList mapFn substitutions;

      subsStr = pkgs.lib.concatStringsSep " " subsList;
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
  }: let
    faviconStr =
      pkgs.lib.strings.optionalString
      (favicon != null)
      "<link rel=\"icon\" type=\"image/x-icon\" href=\"${favicon}\">";

    stylesheetsStr =
      pkgs.lib.strings.optionalString
      (stylesheets != null)
      (
        pkgs.lib.strings.concatMapStringsSep
        "\n"
        (stylesheet: "<link rel=\"stylesheet\" href=\"${stylesheet}\">")
        stylesheets
      );

    descriptionStr =
      pkgs.lib.strings.optionalString
      (description != null)
      "<meta name=\"description\"  content=\"${description}\">";

    themeColorStr =
      pkgs.lib.strings.optionalString
      (themeColor != null)
      "<meta name=\"theme-color\"  content=\"${themeColor}\">";

    openGraphStr =
      pkgs.lib.strings.optionalString
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
  in pkgs.writeText body html;

  fileName = filePath: pkgs.lib.lists.last (pkgs.lib.strings.splitString "/" filePath);

  replaceExt =
    filePath:
    newExt:
    let
      fileNameNoExt = pkgs.lib.strings.concatStringsSep "." (pkgs.lib.lists.init (pkgs.lib.strings.splitString "." (fileName filePath)));
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
    pkgs.runCommand
    (replaceExt md ".html")
    { buildInputs = with pkgs; [ cmark-gfm ]; }
    "cmark-gfm -e table -e strikethrough -e autolink ${md} --to html > $out";

  scssToCss =
    scss:
    pkgs.runCommand
    (replaceExt scss ".css")
    { buildInputs = with pkgs; [ sassc ]; }
    "sassc ${scss} $out";

  svgToIco =
    svg:
    pkgs.runCommand
    (replaceExt svg ".ico")
    { buildInputs = with pkgs; [ imagemagick ]; }
    "convert -resize 16x16 -background transparent ${svg} $out";

  svgToPng =
    svg:
    pkgs.runCommand
    (replaceExt svg ".png")
    { buildInputs = with pkgs; [ imagemagick ]; }
    "convert ${svg} $out";

  mdToPdf =
    md:
    pkgs.runCommand
    (replaceExt md ".pdf")
    { buildInputs = with pkgs; [ pandoc wkhtmltopdf ]; }
    "pandoc ${md} -o $out --pdf-engine wkhtmltopdf";
}
