import { Injectable } from '@angular/core';
import { db } from '../database/app-database';
import { DailyLogCategory, DailyLogEntry, DEFAULT_LOG_CATEGORIES } from '../models';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DailyLogService {
  private entries$ = new BehaviorSubject<DailyLogEntry[]>([]);
  private categories$ = new BehaviorSubject<DailyLogCategory[]>([]);

  constructor() {
    this.initializeCategories();
    this.loadEntries();
  }

  private async initializeCategories(): Promise<void> {
    const count = await db.dailyLogCategories.count();
    if (count === 0) {
      await db.dailyLogCategories.bulkAdd(DEFAULT_LOG_CATEGORIES);
    }
    await this.loadCategories();
  }

  private async loadCategories(): Promise<void> {
    try {
      const categories = await db.dailyLogCategories
        .where('isDeleted')
        .equals(false)
        .toArray();
      this.categories$.next(categories);
    } catch (error) {
      console.error('Error loading daily log categories:', error);
    }
  }

  async loadEntries(date?: string): Promise<void> {
    try {
      let entries = await db.dailyLogEntries
        .where('isDeleted')
        .equals(false)
        .toArray();

      if (date) {
        entries = entries.filter(e => e.logDate === date);
      }

      entries.sort((a, b) => new Date(b.logDate).getTime() - new Date(a.logDate).getTime());
      this.entries$.next(entries);
    } catch (error) {
      console.error('Error loading daily log entries:', error);
    }
  }

  getEntries(): Observable<DailyLogEntry[]> {
    return this.entries$.asObservable();
  }

  getCategories(): Observable<DailyLogCategory[]> {
    return this.categories$.asObservable();
  }

  async getEntriesByDate(date: string): Promise<DailyLogEntry[]> {
    try {
      const entries = await db.dailyLogEntries
        .where('logDate')
        .equals(date)
        .filter(e => !e.isDeleted)
        .toArray();
      return entries;
    } catch (error) {
      console.error('Error loading entries by date:', error);
      return [];
    }
  }

  async addEntry(entry: Omit<DailyLogEntry, 'id' | 'createdAt' | 'isDeleted'>): Promise<DailyLogEntry> {
    const now = new Date().toISOString();
    const newEntry: DailyLogEntry = {
      id: this.generateId(),
      ...entry,
      createdAt: now,
      isDeleted: false
    };
    await db.dailyLogEntries.add(newEntry);
    await this.loadEntries();
    return newEntry;
  }

  async updateEntry(id: string, updates: Partial<DailyLogEntry>): Promise<DailyLogEntry> {
    const entry = await db.dailyLogEntries.get(id);
    if (!entry) {
      throw new Error(`Daily log entry with id ${id} not found`);
    }
    const updated: DailyLogEntry = {
      ...entry,
      ...updates,
      updatedAt: new Date().toISOString()
    };
    await db.dailyLogEntries.update(id, updated);
    await this.loadEntries();
    return updated;
  }

  async deleteEntry(id: string, soft: boolean = true): Promise<void> {
    if (soft) {
      await db.dailyLogEntries.update(id, {
        isDeleted: true,
        updatedAt: new Date().toISOString()
      });
    } else {
      await db.dailyLogEntries.delete(id);
    }
    await this.loadEntries();
  }

  async restoreEntry(id: string): Promise<void> {
    await db.dailyLogEntries.update(id, {
      isDeleted: false,
      updatedAt: new Date().toISOString()
    });
    await this.loadEntries();
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
