import { Component, Inject, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialogModule, MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MatTooltipModule } from '@angular/material/tooltip';
import { Goal, ProgressEntry } from '../../../core/models';
import { GoalsService } from '../../../core/services/goals.service';
import { ProgressService } from '../../../core/services/progress.service';
import { GoalFormComponent } from '../goal-form/goal-form.component';
import { MatDialog } from '@angular/material/dialog';

@Component({
  selector: 'app-goal-detail',
  standalone: true,
  imports: [
    CommonModule,
    MatButtonModule,
    MatCardModule,
    MatChipsModule,
    MatDialogModule,
    MatIconModule,
    MatListModule,
    MatTooltipModule
  ],
  templateUrl: './goal-detail.component.html',
  styleUrls: ['./goal-detail.component.scss']
})
export class GoalDetailComponent implements OnInit {
  private goalsService = inject(GoalsService);
  private progressService = inject(ProgressService);
  private dialog = inject(MatDialog);
  private dialogRef = inject(MatDialogRef<GoalDetailComponent>);
  @Inject(MAT_DIALOG_DATA) goal!: Goal;

  progressEntries: ProgressEntry[] = [];

  ngOnInit(): void {
    this.loadProgressEntries();
  }

  private async loadProgressEntries(): Promise<void> {
    this.progressEntries = await this.progressService.getProgressByGoal(this.goal.id);
    this.progressEntries = this.progressEntries.slice(0, 10); // Show last 10
  }

  getProgressValues(): number[] {
    return this.progressEntries.reverse().map(e => e.value);
  }

  getProgressDates(): string[] {
    return this.progressEntries.reverse().map(e =>
      new Date(e.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    );
  }

  editGoal(): void {
    this.dialog.open(GoalFormComponent, {
      width: '500px',
      data: this.goal,
      disableClose: false
    }).afterClosed().subscribe(result => {
      if (result) {
        this.dialogRef.close(true);
      }
    });
  }

  async deleteGoal(): Promise<void> {
    if (confirm('Are you sure you want to delete this goal?')) {
      await this.goalsService.deleteGoal(this.goal.id);
      this.dialogRef.close(true);
    }
  }

  getStatusColor(): string {
    switch (this.goal.status) {
      case 'active':
        return '#4caf50';
      case 'completed':
        return '#2196f3';
      case 'on-hold':
        return '#ff9800';
      default:
        return '#999';
    }
  }
}
