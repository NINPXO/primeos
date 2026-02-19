import { Injectable } from '@angular/core';
import Dexie, { Table } from 'dexie';
import {
  LogCategory,
  LogEntry,
  Note,
  Tag,
  NoteTag,
} from '../../shared/models';

/**
 * Dexie Database Service
 * Manages IndexedDB database for PrimeOS web app
 */
@Injectable({
  providedIn: 'root',
})
export class DatabaseService extends Dexie {
  // Table declarations
  logCategories!: Table<LogCategory>;
  logEntries!: Table<LogEntry>;
  notes!: Table<Note>;
  tags!: Table<Tag>;
  noteTags!: Table<NoteTag>;

  constructor() {
    super('PrimeOS');
    this.version(1).stores({
      logCategories: 'id',
      logEntries: 'id, categoryId, date, createdAt',
      notes: 'id, createdAt, updatedAt',
      tags: 'id, name',
      noteTags: '[noteId+tagId]',
    });
  }

  /**
   * Initialize database with seed data
   */
  async initializeWithSeed(): Promise<void> {
    // Check if already seeded
    const categoryCount = await this.logCategories.count();
    if (categoryCount > 0) {
      return;
    }

    // Seed default log categories
    const now = new Date().toISOString();
    await this.logCategories.bulkAdd([
      {
        id: 'cat-location',
        name: 'Location',
        description: 'Location tracking',
        color: '#FF6B6B',
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'cat-mobile-usage',
        name: 'Mobile Usage',
        description: 'Mobile device usage',
        color: '#4ECDC4',
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'cat-app-usage',
        name: 'App Usage',
        description: 'Application usage tracking',
        color: '#45B7D1',
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      },
    ]);
  }

  /**
   * Clear all data (for testing)
   */
  async clearAll(): Promise<void> {
    await this.logCategories.clear();
    await this.logEntries.clear();
    await this.notes.clear();
    await this.tags.clear();
    await this.noteTags.clear();
  }
}
