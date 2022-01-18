import sys
import os
import cmarkgfm
import subprocess
import re
import css_html_js_minify
import argparse

data_dir = os.environ["DATA"]
assert data_dir is not None, "DATA directory is not set"

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--substitute", help="only perform substitution on the file", action="store_true")
parser.add_argument("file", help="the file to use as the source")
args = parser.parse_args()

def substitute(input):
    pattern = r"\$\{(.*?)\}"
    captures = re.findall(pattern, input)
    # TODO: Make this some kind of map instead of subprocesses?
    for cap in captures:
        cmd = cap.split(" ")
        cmd = [ "python", os.path.join(data_dir, "scripts", cmd[0]) ] + cmd[1::]
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

    with open(os.path.join(data_dir, "template.html"), "r") as file:
        template_html = file.read()

    html = template_html
    html = html.replace("{title}", title)
    html = html.replace("{body}", input)
    # TODO: replace description
    return html

with open(args.file, "r") as file:
    input = file.read()

if args.substitute:
    input = substitute(input)
else:
    input = cmarkgfm.github_flavored_markdown_to_html(input)
    input = substitute(input)
    input = template(input)
    input = css_html_js_minify.html_minify(input)

print(input)
