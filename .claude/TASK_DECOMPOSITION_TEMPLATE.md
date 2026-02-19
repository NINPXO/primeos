# Task Decomposition Template - Global Pattern

This document defines the standard pattern for breaking down broad project tasks into modular, independently-executable subtasks. This approach enables parallel agent execution, faster feedback, and better verification.

---

## Core Principles

1. **Modularity**: Each task is a single, self-contained deliverable
2. **Independence**: Tasks can run in parallel with minimal inter-dependencies
3. **Verification**: Each task includes specific acceptance criteria
4. **Parallelization**: Group related tasks into independent agents
5. **Clarity**: Task titles are imperative and descriptive

---

## Task Decomposition Strategy

### Step 1: Identify Work Categories

Group work into logical categories:
- **Infrastructure**: Setup, configuration, dependencies
- **Feature Implementation**: Core functionality for each feature
- **Verification**: Testing and validation of features
- **Integration**: Combining components, CI/CD setup
- **Documentation**: README, comments, guides

### Step 2: Create Infrastructure Tasks (executed first)

These tasks are prerequisites and should run first:
- Dependency resolution (pubspec.yaml, package.json)
- Build system setup (Flutter build, npm build)
- Database/persistence setup
- Core service configuration

**Pattern**: `[Framework]: Setup [component] and [action]`

Example:
```
Task #11: Flutter: Fix pubspec.yaml and resolve dependencies
Task #23: Angular: Setup package.json and install dependencies
Task #36: Angular: Setup Dexie.js database with 9 tables
```

### Step 3: Create Feature Implementation Tasks

For each feature, create focused implementation tasks:
- Feature-specific service/logic
- UI components
- Feature-specific tests

**Pattern**: `[Framework]: Implement and verify [Feature Name]`

Example:
```
Task #27: Angular: Implement and verify Goals feature
Task #28: Angular: Implement and verify Progress feature
Task #30: Angular: Implement and verify Notes feature with Quill
```

### Step 4: Create Verification Tasks

Separate verification/build tasks:
- Code analysis and linting
- Unit tests
- Build verification
- Feature functional testing

**Pattern**: `[Framework]: [Action] [component/all]`

Examples:
```
Task #12: Flutter: Run code analysis and fix lint errors
Task #13: Flutter: Run unit and widget tests
Task #14: Flutter: Build APK successfully
Task #15: Flutter: Verify Goals feature
```

### Step 5: Create Integration Tasks

Final integration and CI/CD:
- GitHub Actions workflows
- End-to-end testing
- Deployment verification

**Pattern**: `[Service]: [Action] [workflow name]`

Example:
```
Task #37: GitHub Actions: Create CI workflow (.github/workflows/ci.yml)
Task #38: GitHub Actions: Create Web Deploy workflow (.github/workflows/web-deploy.yml)
Task #40: CI/CD: Verify all workflows execute correctly
```

---

## Task Dependency Graph

```
Infrastructure Tasks (Run First - Can Parallelize)
├── #11: Flutter dependencies
├── #12: Flutter analysis
├── #13: Flutter tests
├── #14: Flutter build
├── #23: Angular dependencies
├── #24: Angular build
├── #25: Angular tests
├── #26: Angular startup
└── #36: Dexie database setup

Feature Implementation (Run After Infrastructure - Can Parallelize)
├── Flutter Features (#15-#22)
│   ├── #15: Goals
│   ├── #16: Progress
│   ├── #17: Daily Log
│   ├── #18: Notes
│   ├── #19: Dashboard
│   ├── #20: Search
│   ├── #21: Settings
│   └── #22: Trash
└── Angular Features (#27-#35)
    ├── #27: Goals
    ├── #28: Progress
    ├── #29: Daily Log
    ├── #30: Notes
    ├── #31: Dashboard
    ├── #32: Search
    ├── #33: Settings
    ├── #34: Trash
    └── #35: Bottom Navigation

Integration Tasks (Run Last - Sequential Dependency)
├── #37: CI workflow (blocked by infrastructure)
├── #38: Web Deploy (blocked by Angular)
├── #39: Mobile Release (blocked by Flutter)
└── #40: Verify All Workflows
```

---

## Task Structure Template

Each task should follow this structure:

```yaml
Task #N: [Framework/Service]: [Action] [Target]

Description:
  [2-3 sentence overview of what needs to be done]

  Details:
  - [Key detail 1]
  - [Key detail 2]
  - [Key detail 3]

Acceptance Criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] Criterion 3
  - [ ] No runtime errors
  - [ ] All tests passing (if applicable)

Deliverables:
  - [File 1: description]
  - [File 2: description]
  - [Test report/verification log]

activeForm: [Present continuous verb]-ing [what]
Example: "Implementing Goals feature" or "Running unit tests"

Dependencies:
  - blockedBy: [List of task IDs that must complete first]
  - blocks: [List of task IDs waiting on this one]
```

---

## Execution Strategy

### Phase 1: Infrastructure (Parallel)
- Spawn agents for each framework (Flutter + Angular)
- Each agent handles: dependencies → analysis → tests → build
- Estimated time: 15-30 minutes per framework

### Phase 2: Feature Implementation (Parallel)
- Spawn multiple agents for each feature
- Each agent implements one feature start-to-finish
- Verify acceptance criteria before marking complete
- Estimated time: 30-60 minutes per feature

### Phase 3: Integration (Sequential)
- Run after phases 1 & 2 complete
- Setup CI/CD workflows
- Run end-to-end verification
- Estimated time: 20-30 minutes

### Phase 4: Commit & Push (Sequential)
- Consolidate all changes
- Single comprehensive commit covering all work
- Push to remote

---

## Agent Assignment Pattern

For N independent tasks that can run in parallel:

```
Agent A: Tasks 11, 12, 13, 14 (Flutter infrastructure)
Agent B: Tasks 23, 24, 25, 26, 36 (Angular infrastructure)
Agent C: Tasks 15, 16, 17 (Flutter features batch 1)
Agent D: Tasks 18, 19, 20, 21, 22 (Flutter features batch 2)
Agent E: Tasks 27, 28, 29 (Angular features batch 1)
Agent F: Tasks 30, 31, 32, 33, 34, 35 (Angular features batch 2)
Agent G: Tasks 37, 38, 39, 40 (CI/CD - after all complete)
```

---

## Verification Checklist Template

Each agent should verify before marking task complete:

```markdown
VERIFICATION CHECKLIST for Task #X: [Task Name]

Code Quality:
- [ ] No syntax errors
- [ ] Linting passes (flutter analyze / npm run lint)
- [ ] Code follows style guide
- [ ] No console errors/warnings

Functional Testing:
- [ ] Feature works as described
- [ ] All CRUD operations functional
- [ ] Edge cases handled
- [ ] Error handling present

Integration:
- [ ] No breaking changes to other features
- [ ] Database/state management working
- [ ] UI renders correctly
- [ ] Responsive on mobile/web

Tests:
- [ ] All unit tests passing
- [ ] Test coverage adequate
- [ ] New tests added for changes
- [ ] No flaky tests

Performance:
- [ ] No performance regressions
- [ ] Build time acceptable
- [ ] Runtime performance adequate

Documentation:
- [ ] Code comments present
- [ ] Complex logic explained
- [ ] TypeScript/Dart typing complete
```

---

## Reusable for Future Projects

When starting new projects with similar structure:

1. Identify frameworks/languages used
2. Adapt infrastructure tasks (dependencies, build, test)
3. List all features/modules
4. Create feature tasks (implement + verify each)
5. Create integration tasks
6. Define dependencies based on this template
7. Spawn agents for parallel execution

---

## Example Application (PrimeOS)

### Original (Broad) Tasks
- Task #8: Make existing Flutter app work
- Task #9: Create Angular web app with all 8 features
- Task #10: Setup GitHub Actions

### Decomposed (Modular) Tasks
- Tasks #11-#22: Flutter (12 tasks: 4 infrastructure + 8 features)
- Tasks #23-#36: Angular (14 tasks: 5 infrastructure + 8 features + 1 shared)
- Tasks #37-#40: CI/CD (4 tasks: 3 workflows + 1 verification)

**Total: 40 tasks enabling parallel execution**

---

## Tracking Progress

Use TaskList to see all tasks and their status:
- `pending`: Not started
- `in_progress`: Agent actively working
- `completed`: Fully done and verified

Dependencies show which tasks block which others, enabling efficient scheduling.

---

## Key Benefits of This Approach

1. **Parallelization**: 40 tasks can run in parallel instead of 3 sequential
2. **Clarity**: Each agent knows exact deliverable
3. **Verification**: Built-in acceptance criteria prevent rework
4. **Independence**: Agents don't need to coordinate
5. **Progress Tracking**: Real-time visibility into what's done
6. **Modularity**: Changes to one feature don't affect others
7. **Scalability**: Pattern works for small or large projects
