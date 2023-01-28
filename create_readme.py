from pathlib import Path
import re

ROOTDIR = Path(__file__).parent
README = ROOTDIR / "README.md"

FILE_EXT = ".md"


def create_readme():
    """Create README.md file from all .md files in the current directory."""
    with README.open("r+") as readme:
        existing_explains_md = readme.readlines()
        existing_explains = [
            re.findall(r"-\s\[(.+)\]\(", x) for x in existing_explains_md
        ]

        for path in ROOTDIR.glob(f"*{FILE_EXT}"):
            if path.name == "README.md":
                continue
            if path.stem not in [x[0] for x in existing_explains if x]:
                raw_url = f"https://github.com/Anyesh/explains/blob/master/{path.name}"

                readme.write(f"- [{path.stem}]({build_url(raw_url)})\n")


def build_url(raw_url):
    """Build a GitHub URL from a raw URL."""
    return "%20".join(raw_url.split(" "))


if __name__ == "__main__":
    create_readme()
