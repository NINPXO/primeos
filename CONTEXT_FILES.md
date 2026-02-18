# PrimeOS Context Files Guide

## What Are Context Files?

`.claude.md` files at strategic levels provide **development context** for AI assistants (and humans) working on the project. They document:

- Architecture patterns and conventions
- Critical files and their purposes
- Common tasks and step-by-step guides
- Testing checklists
- Common mistakes and how to avoid them
- Dependencies and relationships

## Where They Are

```
PrimeOS/
├── .claude.md                    ← Project overview, critical files, decisions
├── lib/
│   ├── core/.claude.md          ← Database, router, services
│   ├── features/.claude.md      ← Feature architecture pattern
│   ├── features/goals/.claude.md
│   ├── features/progress/.claude.md
│   ├── features/notes/.claude.md
│   ├── features/search/.claude.md
│   ├── shared/.claude.md        ← Reusable widgets and utilities
│   └── settings/.claude.md      ← Theme persistence, adding settings
└── DEVELOPMENT.md               ← Full project documentation (phases, stats)
```

## How to Use Them

### Starting a Session

1. **First Time?** Read `DEVELOPMENT.md` for full project overview
2. **Know the architecture?** Skim root `.claude.md` for critical files
3. **Adding to a module?** Read that module's `.claude.md` (e.g., `lib/features/goals/.claude.md`)

### Before Modifying

1. **Understand data flow**: Read the file structure section
2. **Follow the pattern**: Use the architecture pattern from `lib/features/.claude.md`
3. **Check constraints**: Look for "Key Decisions Made" section
4. **Test checklist**: Use the testing section before committing

### Example: Add a New Field to Goals

1. Open `lib/features/goals/.claude.md`
2. Search for "Adding a New Goal Field"
3. Follow the 6-step guide (schema → entity → model → datasource → form → test)
4. Check the testing checklist

### Example: Add a New Module

1. Open `lib/features/.claude.md`
2. Read "Development Workflow" (5 steps)
3. Follow the file structure template
4. Create module-specific `.claude.md` based on existing examples
5. Use the quick checklist

## Content Summary

| File | Key Sections | Use When |
|------|--------------|----------|
| Root `.claude.md` | Critical files, module deps, key decisions, quick ref | Need overall context |
| `core/.claude.md` | Schema rules, router config, service patterns | Modifying database or routing |
| `features/.claude.md` | Architecture pattern, development workflow, checklist | Adding new feature or module |
| `goals/.claude.md` | Goal entity, CRUD patterns, denormalization, testing | Working on goals module |
| `progress/.claude.md` | Progress tracking, denormalization sync, auto-logging | Working on progress module |
| `notes/.claude.md` | Rich text, tags, archive vs delete, FTS | Working on notes module |
| `search/.claude.md` | FTS5 design, sealed union, debounce, multi-module | Working on search or adding module |
| `shared/.claude.md` | Widget guidelines, models, extensions | Creating shared widgets |
| `settings/.claude.md` | Theme persistence flow, adding settings | Working on app config |

## Common Patterns Documented

### Across All Modules
- Clean architecture (domain/data/presentation)
- Riverpod state management
- AppResult<T> error handling
- AsyncValue.when state display
- Soft delete pattern (is_deleted + deleted_at)

### Database Operations
- SQLite queries with FTS maintenance
- Model → Entity conversion
- Error exception → DatabaseFailure mapping

### Feature Addition
- Step-by-step guides with code examples
- Testing checklists
- Common mistakes to avoid

### Module Dependencies
- Dependency graphs (which modules depend on which)
- Data flow (datasource → repository → use case → provider → screen)
- FTS index maintenance across modules

## Maintenance

**Keep context files up-to-date**:
- When adding new critical files
- When changing architecture patterns
- When documenting new modules
- When discovering common mistakes

**Update procedure**:
1. Edit relevant `.claude.md` file(s)
2. Add/modify section or create new section
3. Commit with message: `Update context: {what changed}`
4. Push to GitHub

## Best Practices for Context Files

1. **Keep them focused** (one topic per file)
2. **Use examples** (code snippets, not just theory)
3. **Include checklists** (testing, common tasks)
4. **Link to files** (e.g., "see `lib/core/constants/db_constants.dart`")
5. **Document decisions** (why, not just what)
6. **Update them regularly** (as patterns change)

## Example: Using Context to Extend Goals Module

**Scenario**: Add `priority` field to goals

1. Open `lib/features/goals/.claude.md`
2. Search for "Adding a New Goal Field"
3. See the 6-step pattern:
   - Add column to migration_v1.dart
   - Update goal.dart entity
   - Update goal_model.dart
   - Update datasource queries
   - Add UI in goal_form_screen.dart
   - Run CRUD test cycle
4. Follow the pattern exactly
5. Run testing checklist

**Result**: Consistent, correct implementation in ~15 minutes

---

**Context files = faster development + fewer mistakes + better onboarding**
