import os


HTML="""\
<!doctype html>
<html lang="" data-theme="light">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>coffeewhale wiki</title>
  <link
  rel="stylesheet"
  href="_pico.classless.min.css"
>
  <style>
    :root {{
        --pico-typography-spacing-vertical: 0rem;

    }}

  </style>
  <meta name="description" content="">
</head>

<body>
  <main>

    <h1>Personal wiki</h1>
    <hr style="margin-top: 1em; margin-bottom: 1em;"/>
      {0}
  </main>

</body>
</html>
"""

def gen_li(curdir, excepts):
    arr = []
    for f in sorted(os.listdir(curdir)):
        if f in excepts:
            continue
        if os.path.isdir(os.path.join(curdir, f)):
            ff = gen_li(os.path.join(curdir, f), excepts)
            d = os.path.join(curdir, f)
            arr.append(f"<li>{f}/ {ff}</li>")
        else:
            arr.append(f"<li><a target='_blank' href='{curdir}/{f}'>{f}</a></li>")
    return "<ul>" + ("\n".join(arr)) + "</ul>"



arr = []
#for f in sorted(os.listdir()):
#    if f == ".github" or f == ".git" or f == "index.html" or f == "_build-index.py" or f == "_pico.classless.min.css":
#        continue
#    if os.path.isdir(f):
#        for ff in sorted(os.listdir(f)):
#
#    arr.append(f"<li><a target='_blank' href='{f}'>{f}</li>")

arr = gen_li(".", [".github", ".git", "index.html", "_build-index.py", "_pico.classless.min.css"])

output = HTML.format(arr)
with open("index.html", "w") as f:
    print(output, file=f)
