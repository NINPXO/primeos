import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { DatabaseService } from '../../../core/services/database.service';
import {
  LogEntry,
  LogCategory,
  LogEntryWithCategory,
  CreateLogEntryRequest,
  UpdateLogEntryRequest,
  DailyLogViewData,
} from '../../../shared/models';
import type { DailyLogEntry } from '../../../core/models';

/**
 * Daily Log Service
 * Manages log entries and categories with Dexie persistence
 */
@Injectable({
  providedIn: 'root',
})
export class DailyLogService {
  private entriesSubject = new BehaviorSubject<LogEntryWithCategory[]>([]);
  public entries$ = this.entriesSubject.asObservable();

  private categoriesSubject = new BehaviorSubject<LogCategory[]>([]);
  public categories$ = this.categoriesSubject.asObservable();

  constructor(private db: DatabaseService) {
    this.loadCategories();
  }

  /**
   * Load all non-deleted log categories
   */
  async loadCategories(): Promise<LogCategory[]> {
    try {
      const allCategories = await this.db.logCategories.toArray();
      const categories = allCategories.filter(c => !c.isDeleted);
      this.categoriesSubject.next(categories);
      return categories;
    } catch (error) {
      console.error('Error loading categories:', error);
      return [];
    }
  }

  /**
   * Get categories as observable
   */
  getCategories$(): Observable<LogCategory[]> {
    return this.categories$;
  }

  /**
   * Load all log entries for a specific date
   */
  async loadEntriesForDate(date: string): Promise<LogEntryWithCategory[]> {
    try {
      const entries = await this.db.logEntries
        .where('date')
        .equals(date)
        .and((entry: LogEntry) => !entry.isDeleted)
        .toArray();

      const entriesWithCategory = await Promise.all(
        entries.map(async (entry: LogEntry) => {
          const category = await this.db.logCategories.get(entry.categoryId);
          return {
            ...entry,
            category: category || ({} as LogCategory),
          } as LogEntryWithCategory;
        })
      );

      this.entriesSubject.next(entriesWithCategory);
      return entriesWithCategory;
    } catch (error) {
      console.error('Error loading entries for date:', error);
      return [];
    }
  }

  /**
   * Get entries as observable
   */
  getEntries$(): Observable<LogEntryWithCategory[]> {
    return this.entries$;
  }

  /**
   * Get entries grouped by category
   */
  getGroupedEntries(
    entries: LogEntryWithCategory[]
  ): Map<string, LogEntryWithCategory[]> {
    const grouped = new Map<string, LogEntryWithCategory[]>();

    entries.forEach((entry) => {
      const categoryId = entry.categoryId;
      if (!grouped.has(categoryId)) {
        grouped.set(categoryId, []);
      }
      grouped.get(categoryId)!.push(entry);
    });

    return grouped;
  }

  /**
   * Add a new log entry
   */
  async addEntry(request: CreateLogEntryRequest): Promise<LogEntry> {
    const now = new Date().toISOString();
    const entry: LogEntry = {
      id: this.generateId(),
      categoryId: request.categoryId,
      note: request.note,
      date: request.date,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    };

    try {
      await this.db.logEntries.add(entry);
      // Reload entries for the date
      await this.loadEntriesForDate(request.date);
      return entry;
    } catch (error) {
      console.error('Error adding entry:', error);
      throw error;
    }
  }

  /**
   * Update an existing log entry
   */
  async updateEntry(
    id: string,
    request: UpdateLogEntryRequest
  ): Promise<void> {
    try {
      const now = new Date().toISOString();
      const entry = await this.db.logEntries.get(id);

      if (!entry) {
        throw new Error(`Entry with id ${id} not found`);
      }

      await this.db.logEntries.update(id, {
        ...request,
        updatedAt: now,
      });

      // Reload entries for the date
      await this.loadEntriesForDate(entry.date);
    } catch (error) {
      console.error('Error updating entry:', error);
      throw error;
    }
  }

  /**
   * Delete a log entry (soft delete)
   */
  async deleteEntry(id: string): Promise<void> {
    try {
      const entry = await this.db.logEntries.get(id);

      if (!entry) {
        throw new Error(`Entry with id ${id} not found`);
      }

      const now = new Date().toISOString();
      await this.db.logEntries.update(id, {
        isDeleted: true,
        updatedAt: now,
      });

      // Reload entries for the date
      await this.loadEntriesForDate(entry.date);
    } catch (error) {
      console.error('Error deleting entry:', error);
      throw error;
    }
  }

  /**
   * Get today's date in ISO format (YYYY-MM-DD)
   */
  getTodayDate(): string {
    return new Date().toISOString().split('T')[0];
  }

  /**
   * Get the day before a given date
   */
  getPreviousDate(date: string): string {
    const d = new Date(date + 'T00:00:00Z');
    d.setUTCDate(d.getUTCDate() - 1);
    return d.toISOString().split('T')[0];
  }

  /**
   * Get the day after a given date
   */
  getNextDate(date: string): string {
    const d = new Date(date + 'T00:00:00Z');
    d.setUTCDate(d.getUTCDate() + 1);
    return d.toISOString().split('T')[0];
  }

  /**
   * Get view data for a specific date
   */
  async getViewData(date: string): Promise<DailyLogViewData> {
    const entries = await this.loadEntriesForDate(date);
    return {
      date,
      entries,
      groupedByCategory: this.getGroupedEntries(entries),
    };
  }

  /**
   * Generate a unique ID
   */
  private generateId(): string {
    return `entry-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
