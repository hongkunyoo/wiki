import os
import json


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
  <script src="https://cdn.jsdelivr.net/npm/fuse.js@7.1.0"></script>
</head>

<body>
  <main>

    <h1>Personal wiki</h1>
    <hr style="margin-top: 1em; margin-bottom: 1em;"/>
    <input type="text" placeholder="Search" />
    <ul id="searchResult" style="top: 30px; left: 0; width: 100%; margin: 2px; padding: 2px;"></ul>
    <hr style="margin-top: 1em; margin-bottom: 1em;"/>
      {0}
  </main>

    <script>
  (async function() {{
    const url = "./search.json";
    try {{
      const response = await fetch(url);
      if (!response.ok) {{
        throw new Error(`Response status: ${{response.status}}`);
      }}

      const result = await response.json();

      const fuseOptions = {{
        minMatchCharLength: 1,
        threshold: 0.4,
        distance: 10000,
        //includeMatches: true,
        keys: [
          "title",
          "tags"
        ]
      }};

      const fuse = new Fuse(result, fuseOptions);
      const input = document.querySelector("input");
      const searchResult = document.querySelector("#searchResult");

      input.addEventListener("keypress", logKey);

      function logKey(e) {{
        if (event.key === 'Enter') {{
          const l = e.target.value;
          //console.log(l);
          searchResult.innerHTML = "";

          fuse.search(l).forEach(function(item){{
            const li = document.createElement("li");
            const _item = item.item;
            console.log(item);
            li.innerHTML=`<a target='_blank' href='${{_item.url}}'>${{_item.title}}</a>`;
            searchResult.appendChild(li);
          }});
        }}
      }}

    }} catch (error) {{
      console.error(error.message);
    }}
  }})();

  </script>

</body>
</html>
"""

TXT="""\
<!doctype html>
<html lang="" data-theme="light">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>coffeewhale wiki</title>
  <link
  rel="stylesheet"
  href="/wiki/_pico.classless.min.css"
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

    <h1>{0}</h1>
    <hr style="margin-top: 1em; margin-bottom: 1em;"/>
    <pre style="padding: 10px;">{1}</pre>
  </main>

</body>
</html>
"""

search = []

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
            if f.endswith("txt") or f.endswith("cfg"):
                with open(f"{curdir}/{f}.html", "w") as txt:
                    with open(f"{curdir}/{f}", "r") as content:
                        txtContent = content.read()
                        print(TXT.format(f, txtContent), file=txt)
                arr.append(f"<li><a target='_blank' href='{curdir}/{f}.html'>{f}</a></li>")
                search.append({
                    "title": f,
                    "tags": txtContent,
                    "url": f"{curdir}/{f}.html"
                })
            else:
                arr.append(f"<li><a target='_blank' href='{curdir}/{f}'>{f}</a></li>")
                search.append({
                    "title": f,
                    "tags": "",
                    "url": f"{curdir}/{f}"
                })
    return "<ul>" + ("\n".join(arr)) + "</ul>"



arr = gen_li(".", [".github", ".git", "index.html", "_build-index.py", "_pico.classless.min.css", ".gitignore"])

output = HTML.format(arr)
with open("index.html", "w") as f:
    print(output, file=f)

with open("search.json", "w") as json_file:
    json.dump(search, json_file, indent=2)
