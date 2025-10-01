#!/usr/bin/env python3
import re
from pathlib import Path
from collections.abc import Callable


def read_haskell_types(file_path: Path) -> str:
    content = file_path.read_text(encoding="utf-8")
    marker = "-- Types Definition"
    if marker not in content:
        raise ValueError(f"🤷‍♂️ Marker not found: {marker}")
    return content.split(marker, 1)[1].strip()


def remove_prefixes(content: str) -> str:
    content = re.sub(r"\breq_", "", content)
    content = re.sub(r"\bres_", "", content)
    return content


def transform_to_elm(content: str) -> str:
    result = content
    result = result.replace("Double", "Float")
    result = re.sub(r"\[(\w+)\]", r"List \1", result)
    result = result.replace("::", ":")
    result = re.sub(r"^type\s+(\w+)", r"type alias \1", result, flags=re.MULTILINE)
    result = re.sub(
        r"^data\s+(\w+)\s+=\s+\1", r"type alias \1 =", result, flags=re.MULTILINE
    )
    header = "module Models exposing (..)\n\n"
    return header + result


def transform_to_purescript(content: str) -> str:
    result = content
    result = result.replace("Double", "Number")
    result = result.replace("Bool", "Boolean")
    result = re.sub(r"\[(\w+)\]", r"Array \1", result)
    result = re.sub(r"^data\s+(\w+)\s+=\s+\1", r"type \1 =", result, flags=re.MULTILINE)
    header = "module Models where\n\nimport Data.Maybe (Maybe)\n\n"
    return header + result


def generate_file(
    source_path: Path, target_path: Path, transformer: Callable[[str], str]
) -> None:
    haskell_content = read_haskell_types(source_path)
    cleaned_content = remove_prefixes(haskell_content)
    transformed_content = transformer(cleaned_content)
    target_path.parent.mkdir(parents=True, exist_ok=True)
    target_path.write_text(transformed_content, encoding="utf-8")
    print(f"✅ Generated: {target_path}")


def main() -> None:
    script_dir = Path(__file__).parent
    root_dir = script_dir.parent
    source_file = root_dir / "models" / "Models.hs"
    elm_target = root_dir / "client" / "src" / "Models.elm"
    purs_target = root_dir / "server" / "src" / "Models.purs"

    if not source_file.exists():
        raise FileNotFoundError(f"🤣 Source file not found: {source_file}")
    generate_file(source_file, elm_target, transform_to_elm)
    generate_file(source_file, purs_target, transform_to_purescript)
    print("\n🎉 Done.")


if __name__ == "__main__":
    main()
