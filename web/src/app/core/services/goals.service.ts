import { Injectable, signal } from '@angular/core';
import { db } from '../database/app-database';
import { Goal, GoalCategory, DEFAULT_GOAL_CATEGORIES } from '../models';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class GoalsService {
  private goals$ = new BehaviorSubject<Goal[]>([]);
  private categories$ = new BehaviorSubject<GoalCategory[]>([]);

  constructor() {
    this.initializeCategories();
    this.loadGoals();
  }

  private async initializeCategories(): Promise<void> {
    const count = await db.goalCategories.count();
    if (count === 0) {
      await db.goalCategories.bulkAdd(DEFAULT_GOAL_CATEGORIES);
    }
    await this.loadCategories();
  }

  private async loadCategories(): Promise<void> {
    try {
      const categories = await db.goalCategories.toArray();
      this.categories$.next(categories);
    } catch (error) {
      console.error('Error loading categories:', error);
    }
  }

  async loadGoals(): Promise<void> {
    try {
      const goals = await db.goals
        .where('isDeleted')
        .equals(false)
        .toArray();
      this.goals$.next(goals);
    } catch (error) {
      console.error('Error loading goals:', error);
    }
  }

  getGoals(): Observable<Goal[]> {
    return this.goals$.asObservable();
  }

  getCategories(): Observable<GoalCategory[]> {
    return this.categories$.asObservable();
  }

  async addGoal(goal: Omit<Goal, 'id' | 'createdAt' | 'updatedAt' | 'isDeleted' | 'deletedAt'>): Promise<Goal> {
    const now = new Date().toISOString();
    const newGoal: Goal = {
      id: this.generateId(),
      ...goal,
      createdAt: now,
      updatedAt: now,
      isDeleted: false
    };
    await db.goals.add(newGoal);
    await this.loadGoals();
    return newGoal;
  }

  async updateGoal(id: string, updates: Partial<Goal>): Promise<Goal> {
    const goal = await db.goals.get(id);
    if (!goal) {
      throw new Error(`Goal with id ${id} not found`);
    }
    const updated: Goal = {
      ...goal,
      ...updates,
      updatedAt: new Date().toISOString()
    };
    await db.goals.update(id, updated);
    await this.loadGoals();
    return updated;
  }

  async deleteGoal(id: string, soft: boolean = true): Promise<void> {
    if (soft) {
      const now = new Date().toISOString();
      await db.goals.update(id, {
        isDeleted: true,
        deletedAt: now,
        updatedAt: now
      });
    } else {
      await db.goals.delete(id);
    }
    await this.loadGoals();
  }

  async restoreGoal(id: string): Promise<void> {
    await db.goals.update(id, {
      isDeleted: false,
      deletedAt: undefined,
      updatedAt: new Date().toISOString()
    });
    await this.loadGoals();
  }

  async addCategory(category: Omit<GoalCategory, 'id' | 'createdAt' | 'isSystem'>): Promise<GoalCategory> {
    const newCategory: GoalCategory = {
      id: this.generateId(),
      ...category,
      createdAt: new Date().toISOString(),
      isSystem: false
    };
    await db.goalCategories.add(newCategory);
    await this.loadCategories();
    return newCategory;
  }

  async updateCategory(id: string, updates: Partial<GoalCategory>): Promise<GoalCategory> {
    const category = await db.goalCategories.get(id);
    if (!category) {
      throw new Error(`Category with id ${id} not found`);
    }
    const updated: GoalCategory = {
      ...category,
      ...updates
    };
    await db.goalCategories.update(id, updated);
    await this.loadCategories();
    return updated;
  }

  async deleteCategory(id: string): Promise<void> {
    const category = await db.goalCategories.get(id);
    if (category?.isSystem) {
      throw new Error('Cannot delete system categories');
    }
    await db.goalCategories.delete(id);
    await this.loadCategories();
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
