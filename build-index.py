import os


HTML="""\
<!doctype html>
<html lang="" data-theme="light">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Personal wiki</title>
  <link
  rel="stylesheet"
  href="pico.classless.min.css"
>
  <meta name="description" content="">
</head>

<body>
  <main>

    <h1>Personal Wiki page</h1>
    <ul>
      {0}
    </ul>
  </main>

</body>
</html>
"""

arr = []
for f in sorted(os.listdir()):
    if f == ".github" or f == ".git" or f == "index.html" or f == "build-index.py" or f == "pico.classless.min.css":
        continue
    arr.append(f"<li><a target='_blank' href='{f}'>{f}</li>")

    output = HTML.format("\n".join(arr))
    with open("index.html", "w") as f:
        print(output, file=f)
