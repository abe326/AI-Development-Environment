# aide — AI Development Environment

**[日本語](README.md)** | English

> **A development framework where AI and humans collaborate phase by phase, using specifications as the common language**

A Specification-Driven Development (SDD) based AI co-pilot tool.
From meetings to release, AI assists through every phase. Supports 3 project scale modes.

| | |
|---|---|
| **Methodology** | Specification-Driven Development (SDD) + Spec-Anchored (bidirectional spec sync) |
| **Supported AI Tools** | Claude Code / GitHub Copilot / Codex |
| **Project Scales** | Quick (prototype) / Standard (default) / Enterprise (with audit) |
| **Target Workflows** | PM tasks / New development / Operations & maintenance |
| **Target Users** | Engineers & PMs (designed for non-engineers too) |

---

## What is aide?

Don't leave everything to AI. Humans make decisions, with specifications as the source of truth, progressing step by step.

aide is a workflow framework consisting of **24 slash commands + auto-execution features**.
Initialize your project with `/aide-init`, then execute commands along each phase to consistently manage requirements, design docs, test specs, code, and reports.

```
/aide-init         → Project initialization (scale: quick / standard / enterprise)
/aide-pm-*         → PM & management (meeting notes, brainstorm, estimates, docs, prototypes...)
/aide-dev-*        → Development (code, tests, quality reports...)
/aide-review-*     → Review (code, documents, audit...)
/aide-ops-*        → Operations & maintenance (intake, investigation, fix, close...)
```

---

## Core Principles

| Principle | Description |
|---|---|
| **Human-in-the-Loop** | AI proposes and generates; humans decide and approve |
| **Specification-Driven Development (SDD)** | Specifications are the single source of truth. Code implements specs, tests verify specs |
| **Spec-Anchored** | Bidirectional sync between implementation and specs. Proposes spec updates when code changes |
| **Phase-Driven** | Finalize deliverables in order before moving to the next phase. Iterative within each phase |
| **Deliverable-Based** | Never proceed on verbal agreements alone. Each step produces concrete deliverables |
| **Thought History Preservation** | Brainstorming and discussion processes are preserved in date-stamped files |

---

## Project Scales

Select a scale when running `/aide-init`. Folder structure, workflow, and quality gates vary by scale.

| Scale | Use Case | Features |
|---|---|---|
| **quick** | Prototypes, PoC, internal tools | Consolidated phases, prototype-to-spec reverse generation flow |
| **standard** | Normal development projects (default) | Standard phase-driven flow |
| **enterprise** | Compliance requirements | Audit trails, quality gates, traceability |

---

## Quick Start

```bash
# 1. Initialize project (run once)
/aide-init dev                    # New development (standard)
/aide-init dev quick              # For prototyping
/aide-init dev enterprise         # With audit support
/aide-init ops                    # Operations & maintenance

# 2. Follow the phase workflow
/aide-pm-brainstorm               # standard/enterprise: Start from requirements
/aide-pm-prototype                # quick: Start from prototype
/aide-ops-new                     # ops: Start from intake
```

For detailed usage, see [.aide/README.md](.aide/README.md).

---

## Workflow Overview

### Quick (Prototype)

```
Prototype → Reverse spec generation → Code cleanup → Test
```

| Step | Commands |
|---|---|
| Prototype | `pm-prototype` → verify → iterate |
| Spec finalization | `pm-reverse-spec` → `pm-brainstorm` (deep dive) |
| Code cleanup | `dev-code` → `review-code` |
| Test | `dev-testspec` → `dev-test` |

### Standard (New Development)

```
Requirements → Design → Planning → Implementation → Testing → Release
```

| Phase | Commands |
|---|---|
| Requirements | `meeting` → `brainstorm` → `diagram` → `analyze` |
| Design | `brainstorm` → `diagram` → `analyze` |
| Planning | `plan` → `estimate` |
| Implementation | `dev-code` (Spec-Anchored: with spec sync check) |
| Testing | `dev-testspec` → `dev-test` → `review-code` |
| Release | `review-doc` → `export` → `slide` |

### Enterprise (With Audit)

Same flow as Standard + `review-audit` for quality gate verification at each phase completion.

### Operations & Maintenance

Parallel task management with Task IDs (`T-XXX`).

```
Intake(new) → Investigation(investigate) → Fix(fix) → Close(close)
```

---

## Command List (24 commands)

### Common (2)

| Command | Purpose |
|---|---|
| `/aide-init` | Project initialization (scale: quick / standard / enterprise) |
| `/aide-router` | Suggest commands based on current context |

### PM & Management (11)

| Command | Purpose |
|---|---|
| `/aide-pm-meeting` | Create meeting notes + issue tracking |
| `/aide-pm-brainstorm` | Brainstorm → create/update deliverables |
| `/aide-pm-analyze` | Interactive analysis (no file updates) |
| `/aide-pm-diagram` | Generate draw.io-compatible SVG diagrams |
| `/aide-pm-plan` | Create development plan |
| `/aide-pm-estimate` | Create estimates (standard/rough) |
| `/aide-pm-slide` | Create documents (slides/estimates/schedules/discussion materials) |
| `/aide-pm-export` | Convert deliverables to HTML/PDF/docx |
| `/aide-pm-prototype` | Generate prototype from rough requirements (for Quick) |
| `/aide-pm-reverse-spec` | Reverse-generate specs from prototype |
| `/aide-pm-retro` | Retrospective (KPT) |

### Review (3)

| Command | Purpose |
|---|---|
| `/aide-review-code` | Code review (spec compliance, quality, security, coverage, static analysis). Use `--scope` to narrow focus |
| `/aide-review-doc` | Document review (deliverable consistency, completeness, traceability audit) |
| `/aide-review-audit` | Audit review (quality gates, compliance, audit trails). Enterprise only |

### Development (4)

| Command | Purpose |
|---|---|
| `/aide-dev-code` | Create/modify code based on specs (Spec-Anchored: with spec sync check) |
| `/aide-dev-testspec` | Create unit/integration test specifications |
| `/aide-dev-test` | Run tests + collect evidence + generate reports |
| `/aide-dev-migrate` | Dependency updates + CVE vulnerability checks |

### Operations & Maintenance (4)

| Command | Purpose |
|---|---|
| `/aide-ops-new` | Intake inquiry + create task |
| `/aide-ops-investigate` | Task investigation & root cause analysis |
| `/aide-ops-fix` | Task fix implementation |
| `/aide-ops-close` | Document resolution + close |

### Auto-Execution (on session start)

| Feature | Target | Content |
|---|---|---|
| Task status display | ops projects | Task list + stagnation warnings + summary + action suggestions |
| Issue status display | dev projects | Issue summary + stagnation warnings + action suggestions |

---

## Project Structure

```
.aide/                          ← aide core framework (Single Source of Truth)
├── rules.md                    ← Common rules (master)
├── skills/                     ← Skill definitions (24)
├── templates/                  ← Deliverable & export templates
├── scripts/sync-skills.sh      ← Wrapper batch generation
└── README.md                   ← Usage guide
.claude/skills/                 ← Claude Code wrappers (auto-generated)
.agents/skills/                 ← Codex CLI wrappers (auto-generated)
.github/skills/                 ← GitHub Copilot wrappers (auto-generated)
CLAUDE.md                       ← Project-specific settings (generated by /aide-init)
```

Running `/aide-init` generates a folder structure based on the selected scale:

### Quick

```
docs/
├── 00_pm/                     ← Issue management
├── specs/                     ← Requirements & design (consolidated)
└── testing/                   ← Test specs & evidence
```

### Standard

```
docs/
├── 00_pm/                     ← Issues, schedules, estimates
├── 01_requirements/           ← Requirements docs, meeting notes, brainstorms
├── 02_design/                 ← Design docs
├── 03_plans/                  ← Development plans
└── 04_testing/                ← Test specs & evidence
```

### Enterprise (Standard + Audit)

```
docs/
├── ... (same as Standard)
└── 05_audit/                  ← Audit trails, compliance register, quality metrics
```

---

## Requirements

### Supported AI Tools

| Tool | Status |
|---|---|
| **Claude Code** | Full support — run all skills with `/aide-*` commands |
| **GitHub Copilot** | Full support — reference skills in Agent Mode |
| **OpenAI Codex CLI** | Supported — loads rules via AGENTS.md |

### Prerequisites

- **Required**: Git only
- **Recommended OS**: WSL2 / macOS / Linux (Git Bash compatible, PowerShell not recommended)
- **For exports**: marked, marp-cli, pandoc, etc. (installation guided when running skills)

---

## License

[MIT](LICENSE)
