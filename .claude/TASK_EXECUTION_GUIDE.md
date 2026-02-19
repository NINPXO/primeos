# Task Execution Guide - PrimeOS

**For**: Sub-agents working on decomposed tasks
**Status**: Tasks ready for parallel execution
**Total Tasks**: 40 (organized into 3 phases)

---

## Quick Reference: Task Status

### Phase 1: Infrastructure (11 tasks - DO THESE FIRST)

#### Flutter Infrastructure (4 tasks)
```
#11 ⏳ Flutter: Fix pubspec.yaml and resolve dependencies
#12 ⏳ Flutter: Run code analysis and fix lint errors
#13 ⏳ Flutter: Run unit and widget tests
#14 ⏳ Flutter: Build APK successfully
```

#### Angular Infrastructure (5 tasks)
```
#23 ⏳ Angular: Setup package.json and install dependencies
#24 ⏳ Angular: Build production bundle
#25 ⏳ Angular: Run all unit tests
#26 ⏳ Angular: Verify app starts and loads UI
#36 ⏳ Angular: Setup Dexie.js database with 9 tables
```

**Start When**: Immediately
**Parallel**: All 9 can run simultaneously
**Blockers**: None - no prerequisites
**Est. Time**: 1-2 hours total

---

### Phase 2: Feature Implementation (23 tasks - DO THESE AFTER PHASE 1)

#### Flutter Features (8 tasks)
```
#15 ⏳ Flutter: Verify Goals feature
#16 ⏳ Flutter: Verify Progress feature
#17 ⏳ Flutter: Verify Daily Log feature
#18 ⏳ Flutter: Verify Notes feature with rich text
#19 ⏳ Flutter: Verify Dashboard feature
#20 ⏳ Flutter: Verify Search feature
#21 ⏳ Flutter: Verify Settings feature
#22 ⏳ Flutter: Verify Trash feature
```

#### Angular Features (8 tasks)
```
#27 ⏳ Angular: Implement and verify Goals feature
#28 ⏳ Angular: Implement and verify Progress feature
#29 ⏳ Angular: Implement and verify Daily Log feature
#30 ⏳ Angular: Implement and verify Notes feature with Quill
#31 ⏳ Angular: Implement and verify Dashboard feature
#32 ⏳ Angular: Implement and verify Search feature
#33 ⏳ Angular: Implement and verify Settings feature
#34 ⏳ Angular: Implement and verify Trash feature
#35 ⏳ Angular: Implement bottom navigation and routing
```

**Start When**: Phase 1 complete
**Parallel**: All 16 can run simultaneously
**Blockers**: All Phase 1 tasks must complete first
**Est. Time**: 2-3 hours total

---

### Phase 3: CI/CD Integration (4 tasks - DO THESE LAST)

```
#37 ⏳ GitHub Actions: Create CI workflow (.github/workflows/ci.yml)
#38 ⏳ GitHub Actions: Create Web Deploy workflow (.github/workflows/web-deploy.yml)
#39 ⏳ GitHub Actions: Create Mobile Release workflow (.github/workflows/mobile-release.yml)
#40 ⏳ CI/CD: Verify all workflows execute correctly
```

**Start When**: Phase 1 & 2 complete
**Parallel**: All 4 can run simultaneously
**Blockers**: All Phase 1 & 2 tasks must complete first
**Est. Time**: 1-2 hours total

---

## How to Execute a Task

### Step 1: Read the Task
```bash
TaskGet taskId=11  # Get full task details
```

### Step 2: Mark as In Progress
```bash
TaskUpdate taskId=11 status=in_progress
# Now everyone knows you're working on it
```

### Step 3: Complete Acceptance Criteria
Follow the acceptance criteria listed in the task description:
- Run commands (flutter, npm, ng)
- Create/modify files
- Add tests
- Verify functionality
- Fix any errors

### Step 4: Verify Before Completing
Use this checklist:
- ✓ All acceptance criteria met
- ✓ No syntax errors
- ✓ All tests passing (if applicable)
- ✓ No console errors/warnings
- ✓ Feature works as designed
- ✓ Documentation added
- ✓ No breaking changes

### Step 5: Mark as Complete
```bash
TaskUpdate taskId=11 status=completed
```

### Step 6: Next Task
```bash
TaskList  # See what's available
TaskGet taskId=12  # Read next task
```

---

## Task Dependency Chart

```
┌─────────────────────────────────────────────────────────┐
│               PHASE 1: INFRASTRUCTURE                   │
│                   (Run First)                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Flutter Setup:          Angular Setup:                │
│  #11 Pubspec            #23 Package.json               │
│  #12 Analysis           #24 Build                      │
│  #13 Tests              #25 Tests                      │
│  #14 Build APK          #26 Startup                    │
│                         #36 Dexie Setup                │
│                                                         │
│  ⬇️  Parallel: All 9 independent                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ⬇️ WAIT FOR ALL TO COMPLETE
┌─────────────────────────────────────────────────────────┐
│              PHASE 2: FEATURES                          │
│            (Run After Phase 1)                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Flutter (8):            Angular (9):                  │
│  #15 Goals              #27 Goals                      │
│  #16 Progress           #28 Progress                   │
│  #17 Daily Log          #29 Daily Log                  │
│  #18 Notes              #30 Notes                      │
│  #19 Dashboard          #31 Dashboard                  │
│  #20 Search             #32 Search                     │
│  #21 Settings           #33 Settings                   │
│  #22 Trash              #34 Trash                      │
│                         #35 Navigation                 │
│                                                         │
│  ⬇️  Parallel: All 16 independent                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ⬇️ WAIT FOR ALL TO COMPLETE
┌─────────────────────────────────────────────────────────┐
│               PHASE 3: CI/CD                            │
│             (Run After Phases 1-2)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  #37 CI Workflow                                       │
│  #38 Web Deploy Workflow                               │
│  #39 Mobile Release Workflow                           │
│  #40 Verify All Workflows                              │
│                                                         │
│  ⬇️  Parallel: All 4 independent                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ⬇️ FINAL
    All Tasks Complete!
```

---

## Agent Assignment Suggestion

### Ideal Setup: 8 Agents (Parallel Execution)

```
PHASE 1 (1-2 hours) - All agents active simultaneously

Agent A: Tasks #11-14 (Flutter setup)
  └─ 1-2 hours: pub get, analysis, tests, APK build

Agent B: Tasks #23-26 (Angular setup)
  └─ 1-2 hours: npm ci, build, tests, startup check

Agent C: Task #36 (Dexie setup)
  └─ 30 min: Database tables and schema

PHASE 2 (2-3 hours) - After Phase 1 complete

Agent D: Tasks #15-18 (Flutter features 1-4)
  └─ 2 hours: Goals, Progress, Daily Log, Notes

Agent E: Tasks #19-22 (Flutter features 5-8)
  └─ 2 hours: Dashboard, Search, Settings, Trash

Agent F: Tasks #27-30 (Angular features 1-4)
  └─ 2.5 hours: Goals, Progress, Daily Log, Notes

Agent G: Tasks #31-35 (Angular features 5-9)
  └─ 2.5 hours: Dashboard, Search, Settings, Trash, Navigation

PHASE 3 (1-2 hours) - After Phase 1 & 2 complete

Agent H: Tasks #37-40 (CI/CD)
  └─ 1.5 hours: CI workflow, Deploy, Release, Verification

TOTAL: ~5.5 hours elapsed time (vs 15-20 hours if sequential)
```

---

## Important Notes for Each Phase

### Phase 1 Specifics

**Flutter Tasks (#11-14)**
- Ensure Flutter SDK is installed: `flutter --version`
- Working directory: `C:/ClodueSpace/PrimeOS/`
- No workarounds - fix actual issues in code

**Angular Tasks (#23-26, #36)**
- Ensure Node.js v20 is installed: `node --version`
- Working directory: `C:/ClodueSpace/PrimeOS/web/`
- Dexie.js setup: Index.ts with 9 tables

### Phase 2 Specifics

**Flutter Features (#15-22)**
- These are verification tasks, not new implementation
- Ensure features already exist in code
- Run the app and test each feature
- Check database persistence (SQLite)

**Angular Features (#27-35)**
- These are implementation tasks - build the components
- Follow Material Design guidelines
- Connect to Dexie.js database
- Write unit tests for all services
- Implement all CRUD operations

### Phase 3 Specifics

**CI/CD Tasks (#37-40)**
- GitHub Actions syntax is strict YAML
- Use proper indentation (2 spaces)
- Test locally first if possible
- Verify all secrets are in GitHub (not hard-coded)
- Workflows must be in: `.github/workflows/`

---

## Verification Template

Before marking ANY task as complete, verify:

```markdown
## Task Verification Checklist

### Code Quality
- [ ] No syntax errors (language-specific linting passes)
- [ ] Code style is consistent
- [ ] Comments added where complex logic exists
- [ ] No commented-out code left behind

### Functional Testing
- [ ] Feature works as described in acceptance criteria
- [ ] All CRUD operations tested (if applicable)
- [ ] Edge cases handled
- [ ] Error states handled

### Testing
- [ ] All unit tests pass (flutter test / npm test)
- [ ] New tests added for changes
- [ ] No flaky/intermittent test failures
- [ ] Coverage is adequate

### Integration
- [ ] No breaking changes to other features
- [ ] Database/persistence working
- [ ] UI renders correctly
- [ ] No console errors or warnings

### Performance
- [ ] Build/test time is acceptable
- [ ] No obvious performance issues
- [ ] Memory usage reasonable

### Documentation
- [ ] Code comments added
- [ ] TypeScript/Dart types complete
- [ ] README updated if needed
```

---

## Common Commands by Task Type

### Flutter Tasks
```bash
# Infrastructure
flutter pub get                    # #11
flutter analyze                   # #12
flutter test                      # #13
flutter build apk --release       # #14

# Feature Verification (run app, then test feature)
flutter run                       # To start app
# Then manually test each feature
```

### Angular Tasks
```bash
# Infrastructure
npm ci                                          # #23
npm run build -- --configuration production    # #24
npm test -- --watch=false --browsers=ChromeHeadless  # #25
npm start                                       # #26 (then load localhost:4200)

# Feature Implementation
# Edit .ts files, create components, add tests
npm test                                        # Verify tests pass
```

### GitHub Actions Tasks
```bash
# Create files
.github/workflows/ci.yml              # #37
.github/workflows/web-deploy.yml      # #38
.github/workflows/mobile-release.yml  # #39

# No command to run - just validate syntax and commit
# Verification happens when you push/tag
```

---

## FAQ for Sub-Agents

**Q: Can I start Phase 2 before Phase 1 is done?**
A: No - Phase 2 tasks depend on Phase 1 completing. Check TaskList first.

**Q: What if my task is blocked by another task?**
A: TaskList will show `[blocked by #XX]`. Wait for that task to complete first.

**Q: Can I work on multiple tasks simultaneously?**
A: Yes, but mark each as `in_progress` so others know you're working on them.

**Q: What if I find a bug in existing code?**
A: Fix it as part of your task. Document in the task description what you fixed.

**Q: How do I know if my feature tests pass?**
A: For Flutter: run `flutter test`. For Angular: run `npm test`. Look for pass/fail summary.

**Q: Should I commit my work?**
A: NO - Don't commit! The Leader Agent will consolidate all changes into one commit.

**Q: What if a test is failing?**
A: Fix the code or test. Don't mark task complete until all tests pass.

**Q: Can I skip a test?**
A: No - tests must pass. If they seem wrong, document in task and ask for clarification.

---

## Success Metrics

### Task Completion = Meeting ALL Criteria
- ✓ Code compiles/builds
- ✓ All tests pass
- ✓ Feature works as designed
- ✓ No console errors
- ✓ Documentation complete
- ✓ Acceptance criteria met

### Project Success = All 40 Tasks Complete
- ✓ Flutter app fully functional
- ✓ Angular web app fully functional
- ✓ All CI/CD workflows created
- ✓ All tests passing
- ✓ Ready for production deployment

---

## Timeline Expectations

```
Start Time (T+0:00)
  ↓
Phase 1 Complete (T+1:00 to T+2:00)
  ↓
Phase 2 Complete (T+3:00 to T+4:00)
  ↓
Phase 3 Complete (T+4:30 to T+5:30)
  ↓
Final Commit & Push (T+5:30 to T+6:00)
  ↓
DONE - Project Ready!
```

---

## Need Help?

If you get stuck:
1. Check task description again for acceptance criteria
2. Look at similar completed tasks for reference
3. Check the global documentation at `~/.claude/TASK_DECOMPOSITION_GLOBAL.md`
4. Review error messages carefully
5. Ask the Leader Agent (me) for clarification

---

**Remember**: Each task is self-contained. Focus on YOUR task, not the whole project. When you're done, mark it complete and move to the next one!

**Current Date**: 2026-02-19
**Status**: All tasks ready to execute
**Next Step**: Start Phase 1 (9 agents on tasks #11-14, #23-26, #36)
