{pkgs}:
with pkgs;
with lib; rec {
  mkSite = url: pages:
    runCommand url {} (let
      pageNamesFlat = attrsets.collect (x: !builtins.isAttrs x) (
        attrsets.mapAttrsRecursive
        (path: value: strings.concatStringsSep "/" path)
        pages
      );

      pageMap = attrsets.genAttrs pageNamesFlat (
        pageUrl:
          attrsets.getAttrFromPath (strings.splitString "/" pageUrl) pages
      );

      genPageList =
        attrsets.mapAttrsToList (name: value: (let
          opts = {path = strings.splitString "/" name;};
        in ''
          mkdir -p $(dirname $out/${name})
          ln -s ${value opts} $out/${name}
        ''))
        pageMap;
    in
      concatStringsSep "\n" genPageList);

  substitute = substitutions: inFile:
    runCommand
    ((fileName inFile) + "-sub")
    {}
    (let
      nameFn = name: strings.escapeShellArg ("$" + name + "$");
      valueFn = value: strings.escapeShellArg value;

      mapFn = name: value: "--replace ${nameFn name} ${valueFn value}";

      subsList = mapAttrsToList mapFn substitutions;

      subsStr = concatStringsSep " " subsList;
    in ''
      substitute ${inFile} $out ${subsStr}
    '');

  # htmlTemplate : (self -> settings) -> self -> string

  htmlTemplate = settingsFunc: self: let
    settings = settingsFunc self;
  in
    with strings; let
      faviconStr =
        optionalString
        (settings.favicon != null)
        "<link rel=\"icon\" type=\"image/x-icon\" href=\"${settings.favicon}\">";

      stylesheetsStr =
        pkgs.lib.strings.optionalString
        (settings.stylesheets != null)
        (
          concatMapStringsSep
          "\n"
          (stylesheet: "<link rel=\"stylesheet\" href=\"${stylesheet}\">")
          settings.stylesheets
        );

      descriptionStr =
        optionalString
        (settings.description != null)
        "<meta name=\"description\" content=\"${settings.description}\">";

      themeColorStr =
        optionalString
        (settings.themeColor != null)
        "<meta name=\"theme-color\" content=\"${settings.themeColor}\">";

      openGraphStr =
        optionalString
        (settings.openGraph != null)
        ''
          <meta property="og:url" content="https://${settings.openGraph.url}/">
          <meta property="og:type" content="website">
          <meta property="og:title" content="${settings.openGraph.title}">
          <meta property="og:description" content="${settings.openGraph.description}">
          <meta property="og:image" content="${settings.openGraph.image}">
          <meta property="og:image:type" content="image/png">
          <meta property="og:image:width" content="1200">
          <meta property="og:image:height" content="630">

          <meta name="twitter:card" content="summary_large_image">
          <meta name="twitter:domain" content="${settings.openGraph.url}">
          <meta name="twitter:url" content="https://${settings.openGraph.url}/">
          <meta name="twitter:title" content="${settings.openGraph.title}">
          <meta name="twitter:description" content="${settings.openGraph.description}">
          <meta name="twitter:image" content="${settings.openGraph.image}">
        '';

      headerStr =
        optionalString
        (settings.header != null)
        "<header>${settings.header}</header>";

      footerStr =
        optionalString
        (settings.footer != null)
        "<footer>${settings.footer}</footer>";
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

            <title>${settings.title}</title>
          </head>
          <body>
          ${headerStr}
          ${builtins.readFile settings.body}
          ${footerStr}
          </body>
        </html>
      '';
    in
      builtins.toString (writeText (fileName settings.body) html);

  # remove the /nix/store/<hash>- part of a file path
  fileName = filePath:
    builtins.substring 44 (builtins.stringLength filePath) filePath;

  replaceExt = filePath: newExt: let
    fileNameNoExt = strings.concatStringsSep "." (
      lists.init
      (strings.splitString "." (fileName filePath))
    );
  in
    fileNameNoExt + newExt;

  mdToHtml = md: self:
    builtins.toString (
      runCommand
      (replaceExt md ".html")
      {buildInputs = [pandoc];}
      "pandoc \\\
      --from markdown+autolink_bare_uris-implicit_figures \\\
      --output $out ${md}"
    );

  scssToCss = scss: self:
    builtins.toString (
      runCommand
      (replaceExt scss ".css")
      {buildInputs = [sassc];}
      "sassc ${scss} $out"
    );

  svgToIco = svg: self:
    builtins.toString (
      runCommand
      (replaceExt svg ".ico")
      {buildInputs = [imagemagick];}
      "convert -resize 16x16 -background transparent ${svg} $out"
    );

  svgToPng = svg: self:
    builtins.toString (
      runCommand
      (replaceExt svg ".png")
      {buildInputs = [imagemagick];}
      "convert ${svg} $out"
    );

  mdToPdf = md: css: self:
    builtins.toString (
      runCommand
      (replaceExt md ".pdf")
      {buildInputs = [pandoc wkhtmltopdf];}
      "pandoc ${md} \\\
      --output $out \\\
      --css ${css self} \\\
      --pdf-engine wkhtmltopdf \\\
      --variable margin-top=20 \\\
      --variable margin-bottom=20 \\\
      --variable margin-left=30 \\\
      --variable margin-right=30"
    );

  camelCaseToKebabCase = string:
    concatStringsSep "-" (map toLower (splitString " " string));
}
