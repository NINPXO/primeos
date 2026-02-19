import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialog } from '@angular/material/dialog';
import { Goal, GoalCategory } from '../../core/models';
import { GoalsService } from '../../core/services/goals.service';
import { GoalFormComponent } from './goal-form/goal-form.component';
import { GoalDetailComponent } from './goal-detail/goal-detail.component';
import { CategoryManageComponent } from './category-manage/category-manage.component';

@Component({
  selector: 'app-goals',
  standalone: true,
  imports: [
    CommonModule,
    MatButtonModule,
    MatCardModule,
    MatChipsModule,
    MatIconModule,
    MatMenuModule,
    MatToolbarModule,
    MatSelectModule,
    MatFormFieldModule,
    MatTooltipModule
  ],
  templateUrl: './goals.component.html',
  styleUrls: ['./goals.component.scss']
})
export class GoalsComponent implements OnInit {
  private goalsService = inject(GoalsService);
  private dialog = inject(MatDialog);

  goals: Goal[] = [];
  categories: GoalCategory[] = [];
  statusFilter: 'all' | 'active' | 'completed' | 'on-hold' = 'all';
  filteredGoals: Goal[] = [];

  ngOnInit(): void {
    this.goalsService.getGoals().subscribe(goals => {
      this.goals = goals;
      this.applyFilter();
    });

    this.goalsService.getCategories().subscribe(categories => {
      this.categories = categories;
    });
  }

  applyFilter(): void {
    if (this.statusFilter === 'all') {
      this.filteredGoals = this.goals;
    } else {
      this.filteredGoals = this.goals.filter(g => g.status === this.statusFilter);
    }
  }

  getGoalsByCategory(categoryId: string): Goal[] {
    return this.filteredGoals.filter(g => g.categoryId === categoryId);
  }

  getCategoryName(categoryId: string): string {
    return this.categories.find(c => c.id === categoryId)?.name || 'Unknown';
  }

  getCategoryColor(categoryId: string): string {
    return this.categories.find(c => c.id === categoryId)?.color || '#999';
  }

  openNewGoal(): void {
    this.dialog.open(GoalFormComponent, {
      width: '500px',
      disableClose: false
    }).afterClosed().subscribe(result => {
      if (result) {
        this.goalsService.loadGoals();
      }
    });
  }

  editGoal(goal: Goal): void {
    this.dialog.open(GoalFormComponent, {
      width: '500px',
      data: goal,
      disableClose: false
    }).afterClosed().subscribe(result => {
      if (result) {
        this.goalsService.loadGoals();
      }
    });
  }

  viewGoal(goal: Goal): void {
    this.dialog.open(GoalDetailComponent, {
      width: '600px',
      data: goal,
      disableClose: false
    }).afterClosed().subscribe(result => {
      if (result) {
        this.goalsService.loadGoals();
      }
    });
  }

  async deleteGoal(id: string): Promise<void> {
    if (confirm('Are you sure you want to delete this goal?')) {
      await this.goalsService.deleteGoal(id);
    }
  }

  openCategoryManager(): void {
    this.dialog.open(CategoryManageComponent, {
      width: '500px',
      disableClose: false
    }).afterClosed().subscribe(result => {
      if (result) {
        this.goalsService.getCategories();
      }
    });
  }

  onStatusFilterChange(status: 'all' | 'active' | 'completed' | 'on-hold'): void {
    this.statusFilter = status;
    this.applyFilter();
  }

  getUniqueCategories(): GoalCategory[] {
    const categoryIds = new Set(this.filteredGoals.map(g => g.categoryId));
    return this.categories.filter(c => categoryIds.has(c.id));
  }
}
