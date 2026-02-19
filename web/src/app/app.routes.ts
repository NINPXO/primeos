import { Routes } from '@angular/router';
import { DashboardComponent } from './features/dashboard/dashboard.component';
import { GoalsComponent } from './features/goals/goals.component';
import { ProgressComponent } from './features/progress/progress.component';
import { DailyLogComponent } from './features/daily-log/components/daily-log.component';
import { NotesComponent } from './features/notes/components/notes.component';
import { SearchComponent } from './features/search/search.component';
import { SettingsComponent } from './features/settings/settings.component';
import { TrashComponent } from './features/trash/trash.component';

export const routes: Routes = [
  {
    path: '',
    component: DashboardComponent
  },
  {
    path: 'goals',
    component: GoalsComponent
  },
  {
    path: 'progress',
    component: ProgressComponent
  },
  {
    path: 'daily-log',
    component: DailyLogComponent
  },
  {
    path: 'notes',
    component: NotesComponent
  },
  {
    path: 'search',
    component: SearchComponent
  },
  {
    path: 'settings',
    component: SettingsComponent
  },
  {
    path: 'trash',
    component: TrashComponent
  }
];
