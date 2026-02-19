# Goals and Progress Features - Implementation Guide

## Quick Start

### Installation
```bash
cd web
npm install
```

### Running the Application
```bash
npm start
# Navigate to http://localhost:4200
```

### Running Tests
```bash
npm test
```

---

## Feature Overview

### Goals Feature
**Route:** `/goals`

Manage personal goals with categories and status tracking.

**Key Features:**
- Create, edit, delete goals
- Organize by color-coded categories
- Track goal status: Active, Completed, On Hold
- View goal details with recent progress
- Manage categories (add custom, delete non-system)
- Target date tracking

**Components:**
1. `GoalsComponent` - Main list view
2. `GoalFormComponent` - Create/edit modal
3. `GoalDetailComponent` - Detail view with progress
4. `CategoryManageComponent` - Category management

### Progress Feature
**Route:** `/progress`

Track progress towards goals with values and dates.

**Key Features:**
- Log progress entries (value + optional note)
- Filter by goal
- View timeline grouped by date
- Generate line charts for visualization
- View statistics (average, min, max, total)
- Edit/delete entries

**Components:**
1. `ProgressComponent` - Main list view
2. `ProgressFormComponent` - Log progress modal
3. `ProgressChartComponent` - Chart visualization

---

## Service Reference

### GoalsService
Located: `web/src/app/core/services/goals.service.ts`

```typescript
// Create a goal
await goalsService.addGoal({
  title: 'Learn Angular',
  description: 'Master Angular framework',
  categoryId: 'cat-learning',
  targetDate: '2025-12-31',
  status: 'active'
});

// Get all goals
goalsService.getGoals().subscribe(goals => {
  console.log(goals);
});

// Update a goal
await goalsService.updateGoal(goalId, {
  status: 'completed',
  title: 'Updated Title'
});

// Delete (soft delete by default)
await goalsService.deleteGoal(goalId);

// Restore soft-deleted goal
await goalsService.restoreGoal(goalId);

// Category operations
await goalsService.addCategory({
  name: 'Work',
  color: '#FF5722'
});
```

### ProgressService
Located: `web/src/app/core/services/progress.service.ts`

```typescript
// Log progress entry
await progressService.addEntry({
  goalId: 'goal-id',
  value: 10,
  date: '2025-02-19',
  note: 'Great session'
});

// Get all progress entries
progressService.getProgress().subscribe(entries => {
  console.log(entries);
});

// Get entries for specific goal
const entries = await progressService.getProgressByGoal(goalId);

// Update entry
await progressService.updateEntry(entryId, {
  value: 15,
  note: 'Updated note'
});

// Delete entry
await progressService.deleteEntry(entryId);
```

---

## Database Schema

### Goals Table
```
id: string (primary key)
title: string
description: string
categoryId: string (FK to goalCategories)
targetDate: string (ISO date)
status: 'active' | 'completed' | 'on-hold'
createdAt: string (ISO timestamp)
updatedAt: string (ISO timestamp)
isDeleted: boolean
deletedAt: string (ISO timestamp, nullable)
```

### Progress Entries Table
```
id: string (primary key)
goalId: string (FK to goals)
value: number
date: string (ISO date)
note: string (nullable)
createdAt: string (ISO timestamp)
updatedAt: string (ISO timestamp)
isDeleted: boolean
deletedAt: string (ISO timestamp, nullable)
```

### Goal Categories Table
```
id: string (primary key)
name: string
color: string (hex color code)
createdAt: string (ISO timestamp)
isSystem: boolean (true for default categories)
```

**Default System Categories:**
- Learning (Blue #2196F3)
- Fitness (Orange #FF9800)
- Nutrition (Green #4CAF50)
- General (Purple #9C27B0)

---

## Component API Reference

### GoalsComponent
**Inputs:** None (standalone)
**Outputs:** None
**Methods:**
- `applyFilter()` - Filter by status
- `openNewGoal()` - Open create dialog
- `editGoal(goal)` - Open edit dialog
- `viewGoal(goal)` - Open detail view
- `deleteGoal(id)` - Delete goal
- `openCategoryManager()` - Open category dialog

### ProgressComponent
**Inputs:** None (standalone)
**Outputs:** None
**Methods:**
- `applyFilter()` - Filter by goal
- `openLogProgress()` - Open log progress dialog
- `viewChart()` - Open chart view
- `deleteEntry(id)` - Delete entry

### ProgressChartComponent
**Inputs:** @Inject(MAT_DIALOG_DATA) goalId: string
**Outputs:** None
**Methods:**
- `getStatistics()` - Get avg/min/max/total

---

## Routing

Routes are configured in `web/src/app/app.routes.ts`:

```typescript
{
  path: 'goals',
  component: GoalsComponent
},
{
  path: 'progress',
  component: ProgressComponent
}
```

Navigation example:
```typescript
constructor(private router: Router) {}

navigateToGoals() {
  this.router.navigate(['/goals']);
}

navigateToProgress() {
  this.router.navigate(['/progress']);
}
```

---

## Styling & Theme

All components use **Angular Material 3** design system.

**Color Palette:**
- Primary: #2196F3 (Blue)
- Success: #4CAF50 (Green)
- Warning: #FF9800 (Orange)
- Danger: #F44336 (Red)
- Neutral: #9E9E9E (Gray)

**Responsive Breakpoints:**
- Mobile: <600px
- Tablet: 600px-960px
- Desktop: >960px

Grid layouts adjust automatically for smaller screens.

---

## Error Handling

All async operations include try-catch blocks:

```typescript
try {
  await goalsService.addGoal(goalData);
} catch (error) {
  console.error('Error saving goal:', error);
  // User-friendly error message displayed
}
```

Form validation errors shown inline:
- Required fields marked with asterisk
- Error messages appear on blur/submission
- Submit button disabled until form valid

---

## Testing

### Running Tests
```bash
npm test
```

### Test Files
- `goals.service.spec.ts` - GoalsService unit tests
- `progress.service.spec.ts` - ProgressService unit tests
- `goals.component.spec.ts` - GoalsComponent tests
- `progress.component.spec.ts` - ProgressComponent tests

### Test Coverage
- Service CRUD operations: 22 tests
- Component initialization and logic: 8 tests
- Total: 30+ unit tests

### Key Test Scenarios
- Goal creation with unique IDs
- Goal updating with partial updates
- Soft delete and restore functionality
- Category protection (system categories locked)
- Progress entry filtering by goal
- Progress entries sorted by date
- Component initialization and data loading

---

## Development Guidelines

### Adding a New Goal Status
1. Update Goal interface in `core/models/goal.model.ts`
2. Update status badge colors in component SCSS
3. Update filter options in component
4. Add validation if needed

### Adding a New Field to Goal
1. Add property to Goal interface
2. Add form field in GoalFormComponent
3. Update goal-detail template
4. Add to GoalsService CRUD methods
5. Update tests

### Customizing Chart Appearance
Edit `progress-chart.component.ts`:
```typescript
chartOptions: ChartOptions<'line'> = {
  // Modify colors, fonts, scales here
};
```

---

## Common Issues & Solutions

### Issue: Chart not displaying
**Solution:** Ensure ng2-charts and chart.js are installed
```bash
npm install ng2-charts chart.js
```

### Issue: Dexie database errors
**Solution:** Clear browser's IndexedDB and refresh
```javascript
// In browser console
indexedDB.deleteDatabase('PrimeOS');
```

### Issue: Form validation not working
**Solution:** Ensure MatFormFieldModule is imported in component
```typescript
imports: [MatFormFieldModule, MatInputModule, ...]
```

### Issue: Material icons not showing
**Solution:** Ensure MatIconModule is imported
```typescript
imports: [MatIconModule, ...]
```

---

## Production Deployment

### Build for Production
```bash
npm run build
```

Output: `web/dist/web/`

### Environment Configuration
Update environment.prod.ts if needed:
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.example.com'
};
```

### Performance Tips
1. Enable Angular production mode
2. Use lazy loading for feature modules
3. Implement OnPush change detection
4. Minify and compress assets

---

## Browser Support
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

IndexedDB required for Dexie database support.

---

## File Structure
```
web/src/app/
├── core/
│   ├── database/
│   │   └── app-database.ts
│   ├── models/
│   │   ├── goal.model.ts
│   │   └── progress.model.ts
│   └── services/
│       ├── goals.service.ts
│       ├── progress.service.ts
│       └── (tests)
├── features/
│   ├── goals/
│   │   ├── goals.component.ts
│   │   ├── goal-form/
│   │   ├── goal-detail/
│   │   └── category-manage/
│   └── progress/
│       ├── progress.component.ts
│       ├── progress-form/
│       └── progress-chart/
└── app.routes.ts
```

---

## Support & Documentation

For more information:
- Angular Material: https://material.angular.io
- Dexie: https://dexie.org
- ng2-charts: https://valor-software.com/ng2-charts/
- Chart.js: https://www.chartjs.org

---

**Version:** 1.0.0
**Last Updated:** February 2025
**Status:** Production Ready
