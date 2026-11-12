"""Deterministic, offline tests; fixtures live in the agent scratch directory."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest import mock

SPEC = importlib.util.spec_from_file_location("skill_library", Path(__file__).with_name("skill_library.py"))
assert SPEC is not None and SPEC.loader is not None
lib = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(lib)


class LibraryTests(unittest.TestCase):
    def setUp(self):
        scratch = Path.home() / ".hermes/cache/scratch"
        scratch.mkdir(parents=True, exist_ok=True)
        self.tmp = tempfile.TemporaryDirectory(prefix="skills-test-", dir=scratch)
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.repo = self.root / "repo"
        self.home = self.root / "home"
        self.home.mkdir()
        self.package = self.repo / "agents/.agents/skills/demo"
        (self.package / "references").mkdir(parents=True)
        (self.package / "SKILL.md").write_text('---\nname: demo\ndescription: "Use when testing. Read evidence."\n---\nRead `references/probe.md`.\n')
        (self.package / "references/probe.md").write_text("real fixture\n")
        self.manifest = {"schema": 1, "skills": ["demo"], "clients": {"agents": ".agents/skills", "claude": ".claude/skills", "codex": ".codex/skills", "opencode": ".config/opencode/skills"}, "extra_links": {}}
        (self.repo / "scripts/agents").mkdir(parents=True)
        (self.repo / "scripts/agents/manifest.json").write_text(json.dumps(self.manifest))

    def validate(self):
        return lib.validate(self.repo)

    def test_valid_library(self):
        self.assertEqual(self.validate(), [])

    def test_dry_run_leaves_home_untouched(self):
        lib.install(self.repo, self.home, apply=False)
        self.assertFalse((self.home / ".agents").exists())

    def test_apply_is_idempotent_and_all_clients_share_bytes(self):
        first = lib.install(self.repo, self.home, apply=True)
        self.assertEqual(len(first["changed"]), 4)
        second = lib.install(self.repo, self.home, apply=True)
        self.assertEqual(second["changed"], [])
        for prefix in self.manifest["clients"].values():
            self.assertEqual((self.home / prefix / "demo").resolve(), self.package)
        self.assertEqual(lib.check_install(self.repo, self.home), [])

    def test_conflict_refused_before_any_links(self):
        conflict = self.home / ".claude/skills/demo"
        conflict.mkdir(parents=True)
        (conflict / "SKILL.md").write_text("unique old instructions")
        with self.assertRaisesRegex(ValueError, "conflict"):
            lib.install(self.repo, self.home, apply=True)
        self.assertFalse((self.home / ".agents/skills/demo").exists())
        self.assertEqual((conflict / "SKILL.md").read_text(), "unique old instructions")

    def test_explicit_conflict_backup_preserves_old_package(self):
        conflict = self.home / ".codex/skills/demo"
        conflict.mkdir(parents=True)
        (conflict / "SKILL.md").write_text("unique old instructions")
        backup = self.root / "backups"
        result = lib.install(self.repo, self.home, apply=True, replace=[".codex/skills/demo"], backup_root=backup)
        self.assertEqual(conflict.resolve(), self.package)
        self.assertEqual(len(result["backups"]), 1)
        self.assertEqual((Path(result["backups"][0]["backup"]) / "SKILL.md").read_text(), "unique old instructions")
        self.assertTrue((Path(result["receipt"])).is_file())

    def test_backup_inside_repository_is_refused(self):
        with self.assertRaisesRegex(ValueError, "outside"):
            lib.install(self.repo, self.home, apply=True, backup_root=self.repo / "backup")

    def test_unmanaged_skills_are_preserved(self):
        other = self.home / ".claude/skills/synced/account/vendor"
        other.mkdir(parents=True)
        (other / "SKILL.md").write_text("vendor content")
        lib.install(self.repo, self.home, apply=True)
        self.assertEqual((other / "SKILL.md").read_text(), "vendor content")

    def test_client_parent_symlink_uses_physical_relative_target(self):
        physical = self.repo / "claude/.claude"
        physical.mkdir(parents=True)
        (self.home / ".claude").symlink_to(physical)
        lib.install(self.repo, self.home, apply=True)
        self.assertEqual((self.home / ".claude/skills/demo").resolve(), self.package)
        self.assertEqual(lib.check_install(self.repo, self.home), [])

    def test_missing_reference(self):
        (self.package / "references/probe.md").unlink()
        self.assertTrue(any("reference" in e for e in self.validate()))

    def test_reference_escape(self):
        (self.package / "SKILL.md").write_text('---\nname: demo\ndescription: Valid\n---\nRead `references/../../../outside.md`.\n')
        self.assertTrue(any("escape" in e for e in self.validate()))

    def test_symlinked_package_asset_is_refused_without_reading_target(self):
        (self.package / "references/probe.md").unlink()
        (self.package / "references/probe.md").symlink_to(self.root / "private")
        self.assertTrue(any("symlink" in e for e in self.validate()))

    def test_manifest_path_escape(self):
        self.manifest["extra_links"] = {"../escape": "agents/.agents/skills/demo"}
        (self.repo / "scripts/agents/manifest.json").write_text(json.dumps(self.manifest))
        with self.assertRaisesRegex(ValueError, "relative"):
            lib.install(self.repo, self.home, apply=True)

    def test_manifest_source_escape(self):
        self.manifest["extra_links"] = {".agents/escape": "../outside"}
        (self.repo / "scripts/agents/manifest.json").write_text(json.dumps(self.manifest))
        with self.assertRaisesRegex(ValueError, "relative|outside|missing"):
            lib.install(self.repo, self.home, apply=True)

    def test_duplicate_skill_name(self):
        self.manifest["skills"].append("demo")
        (self.repo / "scripts/agents/manifest.json").write_text(json.dumps(self.manifest))
        self.assertTrue(any("duplicate" in e for e in self.validate()))

    def test_wrong_frontmatter_name(self):
        p = self.package / "SKILL.md"
        p.write_text(p.read_text().replace("name: demo", "name: different"))
        self.assertTrue(any("name" in e for e in self.validate()))

    def test_private_home_path_is_not_publishable(self):
        p = self.package / "references/probe.md"
        p.write_text("Use /Users/private-user/Library/private-vault")
        self.assertTrue(any("personal path" in e for e in self.validate()))

    def test_runtime_file_refused_without_reading(self):
        (self.package / ".env").write_text("not-a-real-secret")
        self.assertTrue(any("forbidden" in e for e in self.validate()))

    def test_hash_changes_when_reference_changes(self):
        before = lib.package_hash(self.package)
        (self.package / "references/probe.md").write_text("changed fixture")
        self.assertNotEqual(before, lib.package_hash(self.package))

    def test_shadowing_hermes_copy_is_reported(self):
        lib.install(self.repo, self.home, apply=True)
        p = self.home / ".hermes/skills/category/demo"
        p.mkdir(parents=True)
        (p / "SKILL.md").write_text("stale copy")
        self.assertTrue(any("shadow" in e for e in lib.check_install(self.repo, self.home)))

    def test_dangling_managed_link_is_reported(self):
        lib.install(self.repo, self.home, apply=True)
        p = self.home / ".claude/skills/demo"
        p.unlink()
        p.symlink_to(self.root / "missing")
        self.assertTrue(any("link" in e for e in lib.check_install(self.repo, self.home)))

    def test_unknown_replacement_path_refused(self):
        with self.assertRaisesRegex(ValueError, "unknown"):
            lib.install(self.repo, self.home, apply=True, replace=[".ssh"])

    def test_unmanaged_broken_links_are_warnings_not_removed(self):
        lib.install(self.repo, self.home, apply=True)
        broken = self.home / ".agents/skills/cua-driver"
        broken.symlink_to(self.root / "missing-app")
        self.assertEqual(lib.check_install(self.repo, self.home), [])
        self.assertTrue(any("cua-driver" in w for w in lib.installation_warnings(self.repo, self.home)))
        self.assertTrue(broken.is_symlink())

    def test_discovery_root_alias_cannot_replace_canonical_source(self):
        (self.home / ".agents").mkdir()
        (self.home / ".agents/skills").symlink_to(self.package.parent)
        before = lib.package_hash(self.package)
        for apply in [False, True]:
            with self.assertRaisesRegex(ValueError, "canonical source"):
                lib.install(self.repo, self.home, apply=apply, replace=[".agents/skills/demo"])
        self.assertFalse(self.package.is_symlink())
        self.assertEqual(lib.package_hash(self.package), before)
        self.assertFalse((self.home / ".claude").exists())
        self.assertFalse((self.home / ".local/state/agent-skills/backups").exists())

    def test_destination_nested_in_canonical_source_is_refused(self):
        (self.home / ".claude").mkdir()
        (self.home / ".claude/skills").symlink_to(self.package)
        with self.assertRaisesRegex(ValueError, "canonical source"):
            lib.install(self.repo, self.home, apply=True)
        self.assertFalse((self.home / ".agents").exists())
        self.assertFalse((self.package / "demo").exists())

    def test_canonical_ancestor_symlink_refused_before_content_reads(self):
        external = self.root / "outside-skills"
        self.package.parent.rename(external)
        self.package.parent.symlink_to(external)
        original = Path.read_text
        def guarded(path, *args, **kwargs):
            self.assertFalse(lib.within(path.resolve(), external), "outside package content was read")
            return original(path, *args, **kwargs)
        with mock.patch.object(Path, "read_text", guarded):
            self.assertTrue(any("symlink" in e for e in self.validate()))

    def test_symlinked_local_hermes_package_is_reported(self):
        lib.install(self.repo, self.home, apply=True)
        local = self.home / ".hermes/skills"
        local.mkdir(parents=True)
        (local / "demo").symlink_to(self.package)
        self.assertTrue(any("shadow" in e for e in lib.check_install(self.repo, self.home)))

    def test_symlinked_category_hermes_shadow_is_reported(self):
        lib.install(self.repo, self.home, apply=True)
        local = self.home / ".hermes/skills"
        local.mkdir(parents=True)
        (local / "category").symlink_to(self.package.parent)
        self.assertTrue(any("shadow" in e for e in lib.check_install(self.repo, self.home)))

    def test_alternate_directory_frontmatter_shadow_is_reported(self):
        lib.install(self.repo, self.home, apply=True)
        local = self.home / ".hermes/skills/legacy-demo"
        local.mkdir(parents=True)
        (local / "SKILL.md").write_text('---\nname: "demo"\ndescription: Legacy\n---\nStale.\n')
        self.assertTrue(any("shadow" in e for e in lib.check_install(self.repo, self.home)))

    def test_local_symlink_cycle_reports_without_recursion(self):
        lib.install(self.repo, self.home, apply=True)
        local = self.home / ".hermes/skills"
        local.mkdir(parents=True)
        (local / "cycle").symlink_to(local / "cycle")
        self.assertTrue(any("shadow" in e or "cycle" in e for e in lib.check_install(self.repo, self.home)))

    def test_parent_relative_markdown_reference_is_refused(self):
        (self.package.parent.parent / "outside.md").write_text("benign external fixture")
        p = self.package / "SKILL.md"
        original = p.read_text()
        for ref in ["../../outside.md", "../missing.md", "references/../../outside.md", "%2e%2e/outside.md"]:
            p.write_text(original + "\nRead [outside](" + ref + ").\n")
            self.assertTrue(any("escape" in e for e in self.validate()), ref)

    def test_markdown_local_links_anchors_and_web_links(self):
        p = self.package / "SKILL.md"
        p.write_text(p.read_text() + '\n[probe](references/probe.md#heading) [here](#heading) [web](https://example.com/docs)\n')
        ref = self.package / "references/probe.md"
        ref.write_text(ref.read_text() + '\n[skill](../SKILL.md)\n')
        self.assertEqual(self.validate(), [])

    def test_reference_style_markdown_escape_is_refused(self):
        p = self.package / "SKILL.md"
        p.write_text(p.read_text() + '\n[outside]: ../outside.md\n')
        self.assertTrue(any("escape" in e for e in self.validate()))

    def test_nested_local_package_shadow_is_reported(self):
        lib.install(self.repo, self.home, apply=True)
        parent = self.home / ".hermes/skills/category"
        (parent / "demo").mkdir(parents=True)
        (parent / "SKILL.md").write_text('---\nname: category\ndescription: Parent\n---\nParent.\n')
        (parent / "demo/SKILL.md").write_text('---\nname: demo\ndescription: Stale\n---\nStale.\n')
        self.assertTrue(any("category/demo" in e for e in lib.check_install(self.repo, self.home)))

    def test_nested_and_escaped_markdown_labels_cannot_hide_reference_escape(self):
        entry = self.package / "SKILL.md"
        original = entry.read_text()
        for label in ['outside [details]', r'outside \[details\]']:
            entry.write_text(original + '\n[' + label + '](../../outside.md)\n')
            self.assertTrue(any("escape" in e for e in self.validate()), label)
            entry.write_text(original + '\n[' + label + '](references/probe.md)\n')
            self.assertEqual(self.validate(), [], label)

    def test_unrendered_template_link_placeholder_is_allowed_only_in_templates(self):
        directory = self.package / "templates"
        directory.mkdir()
        (directory / "note.md").write_text('![product]({{image_url}})\n')
        self.assertEqual(self.validate(), [])
        entry = self.package / "SKILL.md"
        entry.write_text(entry.read_text() + '\n![product]({{image_url}})\n')
        self.assertTrue(any("missing reference" in e for e in self.validate()))

    def test_complex_local_destination_cannot_validate_a_truncated_path(self):
        entry = self.package / "SKILL.md"
        original = entry.read_text()
        (self.package / "safe(").write_text("not the intended link destination")
        for ref in ['safe()/../../outside.md', r'safe\)/../../outside.md', '<safe()/../../outside.md>']:
            entry.write_text(original + '\n[x](' + ref + ')\n')
            self.assertTrue(self.validate(), ref)

    @unittest.skipUnless(shutil.which("git"), "git required for ignore-policy test")
    def test_claude_runtime_allowlist_preserves_only_portable_sources(self):
        (self.repo / ".gitignore").write_bytes((lib.REPO / ".gitignore").read_bytes())
        subprocess.run(["git", "init", "-q", str(self.repo)], check=True)
        ignored = ["claude/.claude/.credentials.json", "claude/.claude/policy-limits.json", "claude/.claude/remote-settings.json", "claude/.claude/new-runtime-format.json", "claude/.claude/skills/synced/account/SKILL.md", "claude/.claude/skills/obsidian", "claude/.claude/CLAUDE.md"]
        portable = ["claude/.claude/settings.json", "claude/.claude/agents/note-taker.md", "claude/.claude/commands/wrapup.md", "claude/.claude/skills/home-assistant/SKILL.md", "agents/.agents/skills/obsidian/SKILL.md"]
        result = subprocess.run(["git", "-C", str(self.repo), "check-ignore", "--no-index", "--stdin"], input="\n".join(ignored + portable) + "\n", text=True, capture_output=True)
        self.assertEqual(result.returncode, 0)
        self.assertEqual(set(result.stdout.splitlines()), set(ignored))


if __name__ == "__main__":
    unittest.main()
