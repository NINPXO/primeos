import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialog } from '@angular/material/dialog';
import { Goal, ProgressEntry } from '../../core/models';
import { GoalsService } from '../../core/services/goals.service';
import { ProgressService } from '../../core/services/progress.service';
import { ProgressFormComponent } from './progress-form/progress-form.component';
import { ProgressChartComponent } from './progress-chart/progress-chart.component';

@Component({
  selector: 'app-progress',
  standalone: true,
  imports: [
    CommonModule,
    MatButtonModule,
    MatCardModule,
    MatIconModule,
    MatSelectModule,
    MatFormFieldModule,
    MatToolbarModule,
    MatTooltipModule
  ],
  templateUrl: './progress.component.html',
  styleUrls: ['./progress.component.scss']
})
export class ProgressComponent implements OnInit {
  private progressService = inject(ProgressService);
  private goalsService = inject(GoalsService);
  private dialog = inject(MatDialog);

  progressEntries: ProgressEntry[] = [];
  goals: Goal[] = [];
  selectedGoalId: string = '';
  filteredEntries: ProgressEntry[] = [];

  ngOnInit(): void {
    this.progressService.getProgress().subscribe(entries => {
      this.progressEntries = entries;
      this.applyFilter();
    });

    this.goalsService.getGoals().subscribe(goals => {
      this.goals = goals;
    });
  }

  applyFilter(): void {
    if (this.selectedGoalId) {
      this.filteredEntries = this.progressEntries.filter(e => e.goalId === this.selectedGoalId);
    } else {
      this.filteredEntries = this.progressEntries;
    }
  }

  getGoalTitle(goalId: string): string {
    return this.goals.find(g => g.id === goalId)?.title || 'Unknown Goal';
  }

  onGoalFilterChange(goalId: string): void {
    this.selectedGoalId = goalId;
    this.applyFilter();
  }

  groupByDate(): Map<string, ProgressEntry[]> {
    const grouped = new Map<string, ProgressEntry[]>();

    this.filteredEntries.forEach(entry => {
      const date = new Date(entry.date).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });

      if (!grouped.has(date)) {
        grouped.set(date, []);
      }
      grouped.get(date)!.push(entry);
    });

    return grouped;
  }

  openLogProgress(): void {
    this.dialog.open(ProgressFormComponent, {
      width: '500px',
      disableClose: false
    }).afterClosed().subscribe(result => {
      if (result) {
        this.progressService.loadProgress();
      }
    });
  }

  async deleteEntry(id: string): Promise<void> {
    if (confirm('Are you sure you want to delete this entry?')) {
      await this.progressService.deleteEntry(id);
    }
  }

  viewChart(): void {
    if (!this.selectedGoalId) {
      alert('Please select a goal to view the chart');
      return;
    }

    this.dialog.open(ProgressChartComponent, {
      width: '800px',
      data: this.selectedGoalId,
      disableClose: false
    });
  }

  getGroupedEntries(): Array<[string, ProgressEntry[]]> {
    return Array.from(this.groupByDate().entries());
  }
}
