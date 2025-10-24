# -*- makefile -*-
# Suvawa Programming Language Build System
# (c) Aitzaz Imtiaz — Broke Consortium

.PHONY: all install uninstall test format lint mypy docs clean clean-all run-examples bump-major bump-minor bump-patch dist publish

# ============================================
# 🧩 Configuration
# ============================================
VENV_NAME?=venv
VENV_BIN=$(VENV_NAME)/bin
PYTHON=$(VENV_BIN)/python3
PIP=$(VENV_BIN)/pip
PYTEST=$(VENV_BIN)/pytest
PACKAGE=suvawa
VERSION_FILE=src/$(PACKAGE)/__init__.py

# ============================================
# 💡 Help
# ============================================
all: help
help:
	@echo "Suvawa Build System"
	@echo
	@echo "Commands:"
	@echo "  install         Create venv and install dev dependencies"
	@echo "  uninstall       Remove venv and uninstall suvawa"
	@echo "  test            Run tests with coverage"
	@echo "  format          Auto-format code with Black + isort"
	@echo "  lint            Run static analysis (flake8, mypy, etc.)"
	@echo "  mypy            Type-check project"
	@echo "  docs            Sync or rebuild HTML documentation"
	@echo "  dist            Build distributable package"
	@echo "  publish         Upload to PyPI via twine"
	@echo "  bump-major/minor/patch  Version bump controls"
	@echo "  clean           Remove build artifacts"
	@echo "  clean-all       Remove all generated files (including venv)"
	@echo "  run-examples    Execute all sample programs in examples/"
	@echo

# ============================================
# ⚙️  Core Environment
# ============================================
install:
	@echo "\n📦 Setting up Suvawa development environment..."
	python3 -m venv $(VENV_NAME)
	$(PIP) install --upgrade pip wheel
	$(PIP) install -e .[dev]
	@echo "\n✅ Virtual environment ready. Activate with:"
	@echo "   source $(VENV_BIN)/activate"

uninstall:
	@echo "\n🧹 Removing virtual environment and uninstallation..."
	rm -rf $(VENV_NAME)
	$(PYTHON) -m pip uninstall -y $(PACKAGE)
	@echo "\n✅ Suvawa uninstalled."

# ============================================
# 🧪  Testing & Quality
# ============================================
test:
	@echo "\n🧮 Running test suite..."
	$(PYTEST) -v --cov=src --cov-report=term-missing --cov-report=html:coverage_report tests/
	@echo "\n✅ Tests complete."

format:
	@echo "\n🎨 Formatting code..."
	$(VENV_BIN)/black src tests
	$(VENV_BIN)/isort src tests
	@echo "\n✅ Code formatted."

lint:
	@echo "\n🔍 Running static analysis..."
	$(VENV_BIN)/flake8 src tests
	$(VENV_BIN)/black --check src tests
	$(VENV_BIN)/isort --check src tests
	$(VENV_BIN)/mypy src
	@echo "\n✅ All checks passed."

mypy:
	$(VENV_BIN)/mypy src

# ============================================
# 🌐  Documentation
# ============================================
# Suvawa uses static HTML docs — no Sphinx required.
# Place all .html files under docs/html/ and they’ll be copied to docs/build/.
docs:
	@echo "\n🌐 Preparing Suvawa documentation..."
	@mkdir -p docs/build
	cp -r docs/html/* docs/build/
	@echo "\n✅ HTML documentation available at docs/build/index.html"

# ============================================
# 📦  Packaging
# ============================================
dist: clean
	@echo "\n📦 Building Suvawa distributable..."
	$(PYTHON) -m build
	$(VENV_BIN)/twine check dist/*
	@echo "\n✅ Distribution package ready."

publish: dist
	@echo "\n🚀 Uploading Suvawa to PyPI..."
	$(VENV_BIN)/twine upload dist/*
	@echo "\n✅ Publish complete."

# ============================================
# 🧭  Version Management
# ============================================
bump-major:
	$(VENV_BIN)/bumpver update --major

bump-minor:
	$(VENV_BIN)/bumpver update --minor

bump-patch:
	$(VENV_BIN)/bumpver update --patch

# ============================================
# 🧹  Cleanup
# ============================================
clean:
	rm -rf build/ dist/ *.egg-info .coverage coverage_report/ .mypy_cache/ .pytest_cache/

clean-all: clean
	rm -rf $(VENV_NAME) docs/build/ .DS_Store __pycache__

# ============================================
# 🧪  Examples
# ============================================
# If you don't have a CLI yet, you can safely comment this out or
# create a simple src/suvawa/cli.py as a placeholder.
run-examples:
	@echo "\n🏃 Running Suvawa examples..."
	@for example in examples/*.sua; do \
		echo "\n>>> Running $${example}..."; \
		$(PYTHON) -m $(PACKAGE).cli $${example}; \
	done
	@echo "\n✅ Examples executed."
