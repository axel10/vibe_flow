#!/usr/bin/env python3
"""
check_l10n.py

A tool to inspect Flutter ARB localization files in lib/l10n/,
find missing/extra translation keys across all languages, and check placeholder consistency.

Usage:
    python scripts/check_l10n.py [options]

Options:
    --dir, -d       Path to localization directory (default: lib/l10n)
    --template, -t  Template ARB file name (default: app_zh.arb)
    --verbose, -v   Show all missing keys and base translations in detail
    --json          Output results as JSON
    --ci            Exit with code 1 if any missing keys or placeholder mismatches are found
"""

import os
import sys
import json
import glob
import re
import argparse

PLACEHOLDER_REGEX = re.compile(r"\{([a-zA-Z0-9_]+)\}")

def extract_placeholders(text: str):
    if not isinstance(text, str):
        return set()
    return set(PLACEHOLDER_REGEX.findall(text))

def check_l10n(l10n_dir: str, template_name: str, verbose: bool = False, is_ci: bool = False, as_json: bool = False):
    template_path = os.path.join(l10n_dir, template_name)
    if not os.path.exists(template_path):
        print(f"Error: Template file not found: {template_path}", file=sys.stderr)
        sys.exit(1)

    with open(template_path, 'r', encoding='utf-8') as f:
        template_data = json.load(f)

    # Base translation keys (excluding @metadata)
    base_keys = {k: v for k, v in template_data.items() if not k.startswith('@')}
    base_meta = {k: v for k, v in template_data.items() if k.startswith('@')}

    arb_files = sorted(glob.glob(os.path.join(l10n_dir, "app_*.arb")))
    
    results = {}
    has_issues = False

    for arb_path in arb_files:
        filename = os.path.basename(arb_path)
        if filename == template_name:
            continue

        with open(arb_path, 'r', encoding='utf-8') as f:
            target_data = json.load(f)

        target_keys = {k: v for k, v in target_data.items() if not k.startswith('@')}
        
        missing_keys = [k for k in base_keys if k not in target_keys]
        extra_keys = [k for k in target_keys if k not in base_keys]
        
        # Check placeholder mismatches for common keys
        placeholder_mismatches = []
        for k in base_keys:
            if k in target_keys:
                base_ph = extract_placeholders(base_keys[k])
                target_ph = extract_placeholders(target_keys[k])
                if base_ph != target_ph:
                    placeholder_mismatches.append({
                        "key": k,
                        "expected": sorted(list(base_ph)),
                        "actual": sorted(list(target_ph))
                    })

        empty_keys = [k for k, v in target_keys.items() if not str(v).strip()]

        if missing_keys or placeholder_mismatches or empty_keys:
            has_issues = True

        results[filename] = {
            "total_keys": len(target_keys),
            "missing_count": len(missing_keys),
            "missing_keys": missing_keys,
            "extra_count": len(extra_keys),
            "extra_keys": extra_keys,
            "empty_count": len(empty_keys),
            "empty_keys": empty_keys,
            "placeholder_mismatches": placeholder_mismatches,
            "completion_rate": round(len(target_keys) / len(base_keys) * 100, 2) if base_keys else 100.0
        }

    if as_json:
        print(json.dumps({
            "template": template_name,
            "total_base_keys": len(base_keys),
            "languages": results
        }, indent=2, ensure_ascii=False))
        if is_ci and has_issues:
            sys.exit(1)
        return

    print("=" * 70)
    print(f"  Localization Check Report (Template: {template_name}, Total keys: {len(base_keys)})")
    print("=" * 70)

    for filename, r in results.items():
        status = "✅ OK" if r["missing_count"] == 0 and not r["placeholder_mismatches"] and not r["empty_keys"] else "⚠️ INCOMPLETE"
        print(f"\n[{status}] {filename}")
        print(f"    Completion: {r['completion_rate']}% ({r['total_keys']}/{len(base_keys)})")
        
        if r["missing_count"] > 0:
            print(f"    ❌ Missing ({r['missing_count']}):")
            if verbose:
                for k in r["missing_keys"]:
                    base_val = base_keys[k]
                    print(f"       • {k}: \"{base_val}\"")
            else:
                sample = ", ".join(r["missing_keys"][:5])
                suffix = "..." if r["missing_count"] > 5 else ""
                print(f"       [{sample}{suffix}] (use -v to view all)")

        if r["placeholder_mismatches"]:
            print(f"    ⚠️ Placeholder Mismatches ({len(r['placeholder_mismatches'])}):")
            for m in r["placeholder_mismatches"]:
                print(f"       • {m['key']}: expected {m['expected']}, got {m['actual']}")

        if r["empty_keys"]:
            print(f"    ⚠️ Empty Translations ({r['empty_count']}): {', '.join(r['empty_keys'])}")

        if r["extra_count"] > 0:
            print(f"    ℹ️ Extra Keys ({r['extra_count']}): {', '.join(r['extra_keys'][:5])}")

    print("\n" + "=" * 70)
    if has_issues:
        print("⚠️ Some languages have missing or mismatched translation keys.")
    else:
        print("🎉 All localization files are complete and in sync!")
    print("=" * 70)

    if is_ci and has_issues:
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Check Flutter ARB localization completeness.")
    parser.add_argument("--dir", "-d", default="lib/l10n", help="Path to lib/l10n directory")
    parser.add_argument("--template", "-t", default="app_zh.arb", help="Template ARB filename")
    parser.add_argument("--verbose", "-v", action="store_true", help="Print all missing keys in detail")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    parser.add_argument("--ci", action="store_true", help="Exit with non-zero code on missing keys")

    args = parser.parse_args()
    check_l10n(args.dir, args.template, verbose=args.verbose, is_ci=args.ci, as_json=args.json)

if __name__ == "__main__":
    main()
