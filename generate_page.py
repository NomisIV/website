import sys
import os
import cmarkgfm
import subprocess
import re
import css_html_js_minify

def substitute(input):
    pattern = r"\$\{(.*?)\}"
    captures = re.findall(pattern, input)
    # TODO: Make this some kind of map instead of subprocesses?
    for cap in captures:
        cmd = cap.split(" ")
        cmd = [ os.path.join(os.getcwd(), "src", "scripts", cmd[0]) ] + cmd[1::]
        try:
            out = subprocess.check_output(cmd).decode("utf-8").strip()
        except subprocess.CalledProcessError as err:
            print(f"error: {err.output}", file=sys.stderr)
            exit(1)
        input = input.replace(f"${{{cap}}}", out)
    return input

def template(input):
    file = sys.argv[1]
    title = file[file.rfind("/") + 1:file.rfind(".")].replace(",", " ").capitalize()
    if title == "Index":
        title = "NomisIV"

    with open(os.path.join(os.getcwd(), "template.html"), "r") as file:
        template_html = file.read()

    html = template_html
    html = html.replace("{title}", title)
    html = html.replace("{body}", input)
    return html

with open(sys.argv[1], "r") as file:
    input = file.read()

input = cmarkgfm.github_flavored_markdown_to_html(input)
input = substitute(input)
input = template(input)
input = css_html_js_minify.html_minify(input)

print(input)
