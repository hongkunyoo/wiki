import os

for f in os.listdir():
    if f == ".github" or f == ".git" or f == "index.html":
        continue

    print(f)
