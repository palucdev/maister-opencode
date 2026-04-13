.PHONY: build validate clean watch build-opencode validate-opencode clean-opencode

build:
	bash platforms/copilot-cli/build.sh

validate:
	@echo "Checking no colons in command names..."
	@! grep -r '^name:.*:' plugins/maister-copilot/commands/ 2>/dev/null || (echo "FAIL: colons in command names" && exit 1)
	@echo "Checking no multi-select references..."
	@! grep -ri 'multi.select\|multiSelect' plugins/maister-copilot/skills/ 2>/dev/null || (echo "FAIL: multi-select found in skills" && exit 1)
	@echo "Checking commands are flat (no subdirectories)..."
	@test $$(find plugins/maister-copilot/commands -mindepth 2 -name "*.md" 2>/dev/null | wc -l) -eq 0 || (echo "FAIL: nested command directories found" && exit 1)
	@echo "Checking no CLAUDE.md references in skills..."
	@! grep -ri 'CLAUDE\.md' plugins/maister-copilot/skills/ 2>/dev/null || (echo "FAIL: CLAUDE.md references found in skills" && exit 1)
	@echo "Checking no maister- prefix in copilot command names..."
	@! grep -r '^name: maister-' plugins/maister-copilot/commands/ 2>/dev/null || (echo "FAIL: maister- prefix in command names" && exit 1)
	@echo "Checking no maister: prefixes in copilot variant..."
	@! grep -r 'maister:' plugins/maister-copilot/ --include="*.md" 2>/dev/null || (echo "FAIL: maister: prefix found" && exit 1)
	@echo "All checks passed"

clean:
	rm -rf plugins/maister-copilot/

watch:
	fswatch -o plugins/maister/ | xargs -n1 -I{} make build

build-opencode:
	bash platforms/opencode/build.sh

validate-opencode:
	@echo "Checking no colons in skill names..."
	@! grep -r '^name:.*:' plugins/maister-opencode/skills/ 2>/dev/null || \
		(echo "FAIL: colons in skill names" && exit 1)
	@echo "Checking no colons in command names..."
	@! grep -r '^name:.*:' plugins/maister-opencode/commands/ 2>/dev/null || \
		(echo "FAIL: colons in command names" && exit 1)
	@echo "Checking no AskUserQuestion references..."
	@! grep -r 'AskUserQuestion' plugins/maister-opencode/ --include="*.md" 2>/dev/null || \
		(echo "FAIL: AskUserQuestion found" && exit 1)
	@echo "Checking AGENTS.md exists..."
	@test -f plugins/maister-opencode/AGENTS.md || \
		(echo "FAIL: AGENTS.md missing" && exit 1)
	@echo "Checking no CLAUDE.md exists..."
	@! test -f plugins/maister-opencode/CLAUDE.md || \
		(echo "FAIL: CLAUDE.md should not exist" && exit 1)
	@echo "Checking no maister: references remain..."
	@! grep -r 'maister:' plugins/maister-opencode/ --include="*.md" 2>/dev/null || \
		(echo "FAIL: maister: prefix found" && exit 1)
	@echo "Checking hooks.js exists..."
	@test -f plugins/maister-opencode/.opencode/plugins/hooks.js || \
		(echo "FAIL: hooks.js missing" && exit 1)
	@echo "Checking opencode.json exists..."
	@test -f plugins/maister-opencode/opencode.json || \
		(echo "FAIL: opencode.json missing" && exit 1)
	@echo "Checking AGENTS.md has platform note..."
	@grep -q 'Platform: OpenCode' plugins/maister-opencode/AGENTS.md || \
		(echo "FAIL: AGENTS.md missing platform note" && exit 1)
	@echo "Checking hooks/ directory absent..."
	@test ! -d plugins/maister-opencode/hooks || \
		(echo "FAIL: hooks/ should not exist" && exit 1)
	@echo "Checking root package.json exists with correct main..."
	@test -f package.json || (echo "FAIL: root package.json missing" && exit 1)
	@grep -q '"main".*"plugins/maister-opencode/.opencode/plugins/hooks.js"' package.json || \
		(echo "FAIL: package.json main field incorrect" && exit 1)
	@echo "All OpenCode checks passed"

clean-opencode:
	rm -rf plugins/maister-opencode/
	rm -f package.json
