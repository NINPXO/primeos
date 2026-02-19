import { Injectable } from '@angular/core';
import { db } from '../database/app-database';
import { ProgressEntry } from '../models';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ProgressService {
  private entries$ = new BehaviorSubject<ProgressEntry[]>([]);

  constructor() {
    this.loadProgress();
  }

  async loadProgress(): Promise<void> {
    try {
      const entries = await db.progressEntries
        .where('isDeleted')
        .equals(false)
        .toArray();
      // Sort by date descending
      entries.sort((a: ProgressEntry, b: ProgressEntry) => new Date(b.loggedDate).getTime() - new Date(a.loggedDate).getTime());
      this.entries$.next(entries);
    } catch (error) {
      console.error('Error loading progress entries:', error);
    }
  }

  getProgress(): Observable<ProgressEntry[]> {
    return this.entries$.asObservable();
  }

  async getProgressByGoal(goalId: string): Promise<ProgressEntry[]> {
    try {
      const entries = await db.progressEntries
        .where('goalId')
        .equals(goalId)
        .filter((e: ProgressEntry) => !e.isDeleted)
        .toArray();
      return entries.sort((a: ProgressEntry, b: ProgressEntry) => new Date(b.loggedDate).getTime() - new Date(a.loggedDate).getTime());
    } catch (error) {
      console.error('Error loading progress for goal:', error);
      return [];
    }
  }

  async addEntry(entry: Omit<ProgressEntry, 'id' | 'createdAt' | 'updatedAt' | 'isDeleted' | 'deletedAt'>): Promise<ProgressEntry> {
    const now = new Date().toISOString();
    const newEntry: ProgressEntry = {
      id: this.generateId(),
      ...entry,
      createdAt: now,
      updatedAt: now,
      isDeleted: false
    };
    await db.progressEntries.add(newEntry);
    await this.loadProgress();
    return newEntry;
  }

  async updateEntry(id: string, updates: Partial<ProgressEntry>): Promise<ProgressEntry> {
    const entry = await db.progressEntries.get(id);
    if (!entry) {
      throw new Error(`Progress entry with id ${id} not found`);
    }
    const updated: ProgressEntry = {
      ...entry,
      ...updates,
      updatedAt: new Date().toISOString()
    };
    await db.progressEntries.update(id, updated);
    await this.loadProgress();
    return updated;
  }

  async deleteEntry(id: string, soft: boolean = true): Promise<void> {
    if (soft) {
      const now = new Date().toISOString();
      await db.progressEntries.update(id, {
        isDeleted: true,
        deletedAt: now,
        updatedAt: now
      });
    } else {
      await db.progressEntries.delete(id);
    }
    await this.loadProgress();
  }

  async restoreEntry(id: string): Promise<void> {
    await db.progressEntries.update(id, {
      isDeleted: false,
      deletedAt: undefined,
      updatedAt: new Date().toISOString()
    });
    await this.loadProgress();
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
