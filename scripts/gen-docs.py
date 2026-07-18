#!/usr/bin/env python3
"""Generate role variable documentation from meta/argument_specs.yml"""

import sys
from pathlib import Path
from typing import Any

import yaml

ROLES_DIR = Path("roles")
DOCS_DIR = Path("docs")
ROLES_DOCS_DIR = DOCS_DIR / "roles"


def load_argument_specs(role_dir: Path) -> dict[str, Any] | None:
    spec_file = role_dir / "meta" / "argument_specs.yml"
    spec_file_yaml = role_dir / "meta" / "argument_specs.yaml"
    for p in (spec_file, spec_file_yaml):
        if p.exists():
            with open(p) as f:
                data = yaml.safe_load(f)
            if data and "argument_specs" in data:
                return data["argument_specs"]
    return None


def type_label(t: str | None) -> str:
    mapping = {
        "str": "string",
        "bool": "boolean",
        "int": "integer",
        "float": "float",
        "list": "list",
        "dict": "dict",
        "path": "path",
        "raw": "raw",
    }
    return mapping.get(t or "", t or "")


def fmt_default(v: Any) -> str:
    if v is None:
        return ""
    if isinstance(v, bool):
        return str(v).lower()
    if isinstance(v, str):
        if v == "":
            return '""'
        return v
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, (list, dict)):
        text = yaml.dump(v, default_flow_style=False).strip()
        if "\n" in text:
            return f"<pre>{text}</pre>"
        return f"`{text}`"
    return str(v)


def generate_role_doc(
    role_name: str,
    specs: dict[str, Any],
) -> str:
    main_spec = specs.get("main", {})
    short_desc = main_spec.get("short_description", "")
    description = main_spec.get("description", "")
    options = main_spec.get("options", {})

    lines = [
        f"# {role_name}",
        "",
    ]

    if short_desc:
        lines.append(short_desc)
        lines.append("")

    if description:
        if isinstance(description, list):
            for para in description:
                lines.append(para)
                lines.append("")
        else:
            lines.append(description)
            lines.append("")

    if not options:
        lines.append("_No variables defined._")
        lines.append("")
        return "\n".join(lines)

    lines.append("## Variables")
    lines.append("")
    lines.append("| Variable | Type | Default | Description |")
    lines.append("|----------|------|---------|-------------|")

    for var_name, var_spec in sorted(options.items()):
        desc = var_spec.get("description", "")
        if isinstance(desc, list):
            desc = " ".join(desc)
        t = type_label(var_spec.get("type"))
        default = fmt_default(var_spec.get("default"))
        required = var_spec.get("required", False)
        desc_text = desc
        if required:
            desc_text = f"**Required.** {desc}" if desc else "**Required.**"

        var_cell = f"`{var_name}`"
        type_cell = t or "any"

        lines.append(f"| {var_cell} | {type_cell} | {default} | {desc_text} |")

    lines.append("")

    entry_points = [k for k in specs if k != "main"]
    if entry_points:
        lines.append("## Entry Points")
        lines.append("")
        for ep in entry_points:
            ep_spec = specs[ep] or {}
            ep_desc = ep_spec.get("short_description", "")
            lines.append(f"- **{ep}**: {ep_desc}" if ep_desc else f"- **{ep}**")
        lines.append("")

    return "\n".join(lines)


def generate_overview(role_list: list[tuple[str, str]]) -> str:
    lines = [
        "# Overview",
        "",
        "This section documents the variables exposed by each service role.",
        "",
        "All roles tagged `service` in `playbooks/site.yml`:",
        "",
        "| Role | Description |",
        "|------|-------------|",
    ]
    for name, desc in sorted(role_list):
        lines.append(f"| [{name}]({name}.md) | {desc} |")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    if not ROLES_DIR.is_dir():
        print(f"Error: {ROLES_DIR} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    ROLES_DOCS_DIR.mkdir(parents=True, exist_ok=True)

    role_list: list[tuple[str, str]] = []

    for entry in sorted(ROLES_DIR.iterdir()):
        if not entry.is_dir():
            continue
        role_name = entry.name
        specs = load_argument_specs(entry)
        if not specs:
            continue

        main_spec = specs.get("main", {})
        short_desc = main_spec.get("short_description", "")
        role_list.append((role_name, short_desc))

        md = generate_role_doc(role_name, specs)
        out_file = ROLES_DOCS_DIR / f"{role_name}.md"
        out_file.write_text(md)
        print(f"  Generated {out_file}")

    overview = generate_overview(role_list)
    overview_file = ROLES_DOCS_DIR / "index.md"
    overview_file.write_text(overview)
    print(f"  Generated {overview_file}")
    print(f"\nGenerated docs for {len(role_list)} roles.")


if __name__ == "__main__":
    main()
