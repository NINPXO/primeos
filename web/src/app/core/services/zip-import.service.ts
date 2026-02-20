import { Injectable } from '@angular/core';
import { db } from '../database/app-database';
import { AppResult } from '../types/app-result';

declare let JSZip: any;

interface ImportResult {
  goalsCount: number;
  progressEntriesCount: number;
  goalCategoriesCount: number;
  dailyLogCategoriesCount: number;
  dailyLogEntriesCount: number;
  noteTagsCount: number;
  notesCount: number;
  appSettingsCount: number;
}

@Injectable({
  providedIn: 'root'
})
export class ZipImportService {
  async importFromFile(file: File): Promise<AppResult<ImportResult>> {
    try {
      // Check if JSZip is available
      if (typeof window !== 'undefined' && !(window as any).JSZip) {
        throw new Error('JSZip library not loaded. Please ensure jszip is properly imported.');
      }

      // Determine file type
      if (file.name.endsWith('.zip')) {
        return await this.importFromZip(file);
      } else if (file.name.endsWith('.json')) {
        return await this.importFromJson(file);
      } else {
        return { ok: false, error: 'Only .zip and .json files are supported' };
      }
    } catch (error) {
      console.error('Import failed:', error);
      return { ok: false, error: String(error) };
    }
  }

  private async importFromZip(file: File): Promise<AppResult<ImportResult>> {
    try {
      const zip = new (window as any).JSZip();
      const loadedZip = await zip.loadAsync(file);

      const result: ImportResult = {
        goalsCount: 0,
        progressEntriesCount: 0,
        goalCategoriesCount: 0,
        dailyLogCategoriesCount: 0,
        dailyLogEntriesCount: 0,
        noteTagsCount: 0,
        notesCount: 0,
        appSettingsCount: 0
      };

      // Import each JSON file
      const files = Object.keys(loadedZip.files);

      // Import goal categories
      if (files.includes('goalCategories.json')) {
        const content = await loadedZip.file('goalCategories.json').async('string');
        const data = JSON.parse(content);
        if (Array.isArray(data) && data.length > 0) {
          await db.goalCategories.bulkPut(data);
          result.goalCategoriesCount = data.length;
        }
      }

      // Import daily log categories
      if (files.includes('dailyLogCategories.json')) {
        const content = await loadedZip.file('dailyLogCategories.json').async('string');
        const data = JSON.parse(content);
        if (Array.isArray(data) && data.length > 0) {
          await db.dailyLogCategories.bulkPut(data);
          result.dailyLogCategoriesCount = data.length;
        }
      }

      // Import note tags
      if (files.includes('noteTags.json')) {
        const content = await loadedZip.file('noteTags.json').async('string');
        const data = JSON.parse(content);
        if (Array.isArray(data) && data.length > 0) {
          await db.noteTags.bulkPut(data);
          result.noteTagsCount = data.length;
        }
      }

      // Import goals
      if (files.includes('goals.json')) {
        const content = await loadedZip.file('goals.json').async('string');
        const data = JSON.parse(content);
        if (Array.isArray(data) && data.length > 0) {
          await db.goals.bulkPut(data);
          result.goalsCount = data.length;
        }
      }

      // Import progress entries
      if (files.includes('progressEntries.json')) {
        const content = await loadedZip.file('progressEntries.json').async('string');
        const data = JSON.parse(content);
        if (Array.isArray(data) && data.length > 0) {
          await db.progressEntries.bulkPut(data);
          result.progressEntriesCount = data.length;
        }
      }

      // Import daily log entries
      if (files.includes('dailyLogEntries.json')) {
        const content = await loadedZip.file('dailyLogEntries.json').async('string');
        const data = JSON.parse(content);
        if (Array.isArray(data) && data.length > 0) {
          await db.dailyLogEntries.bulkPut(data);
          result.dailyLogEntriesCount = data.length;
        }
      }

      // Import notes
      if (files.includes('notes.json')) {
        const content = await loadedZip.file('notes.json').async('string');
        const data = JSON.parse(content);
        if (Array.isArray(data) && data.length > 0) {
          await db.notes.bulkPut(data);
          result.notesCount = data.length;
        }
      }

      // Import app settings
      if (files.includes('appSettings.json')) {
        const content = await loadedZip.file('appSettings.json').async('string');
        const data = JSON.parse(content);
        if (Array.isArray(data) && data.length > 0) {
          await db.appSettings.bulkPut(data);
          result.appSettingsCount = data.length;
        }
      }

      return { ok: true, data: result };
    } catch (error) {
      console.error('ZIP import failed:', error);
      return { ok: false, error: `Failed to import ZIP file: ${String(error)}` };
    }
  }

  private async importFromJson(file: File): Promise<AppResult<ImportResult>> {
    try {
      const text = await file.text();
      const data = JSON.parse(text);

      const result: ImportResult = {
        goalsCount: 0,
        progressEntriesCount: 0,
        goalCategoriesCount: 0,
        dailyLogCategoriesCount: 0,
        dailyLogEntriesCount: 0,
        noteTagsCount: 0,
        notesCount: 0,
        appSettingsCount: 0
      };

      // Handle single array or object with table names as keys
      if (Array.isArray(data)) {
        // If it's a single array, determine which table based on first item
        if (data.length > 0) {
          const firstItem = data[0];
          if ('title' in firstItem && 'categoryId' in firstItem) {
            await db.goals.bulkPut(data);
            result.goalsCount = data.length;
          } else if ('goalId' in firstItem && 'value' in firstItem) {
            await db.progressEntries.bulkPut(data);
            result.progressEntriesCount = data.length;
          } else if ('name' in firstItem && 'description' in firstItem === false) {
            // Could be categories or tags
            if ('isSystem' in firstItem) {
              await db.goalCategories.bulkPut(data);
              result.goalCategoriesCount = data.length;
            } else {
              await db.noteTags.bulkPut(data);
              result.noteTagsCount = data.length;
            }
          }
        }
      } else if (typeof data === 'object') {
        // Handle object with multiple tables
        if (data.goals && Array.isArray(data.goals)) {
          await db.goals.bulkPut(data.goals);
          result.goalsCount = data.goals.length;
        }
        if (data.progressEntries && Array.isArray(data.progressEntries)) {
          await db.progressEntries.bulkPut(data.progressEntries);
          result.progressEntriesCount = data.progressEntries.length;
        }
        if (data.goalCategories && Array.isArray(data.goalCategories)) {
          await db.goalCategories.bulkPut(data.goalCategories);
          result.goalCategoriesCount = data.goalCategories.length;
        }
        if (data.dailyLogCategories && Array.isArray(data.dailyLogCategories)) {
          await db.dailyLogCategories.bulkPut(data.dailyLogCategories);
          result.dailyLogCategoriesCount = data.dailyLogCategories.length;
        }
        if (data.dailyLogEntries && Array.isArray(data.dailyLogEntries)) {
          await db.dailyLogEntries.bulkPut(data.dailyLogEntries);
          result.dailyLogEntriesCount = data.dailyLogEntries.length;
        }
        if (data.noteTags && Array.isArray(data.noteTags)) {
          await db.noteTags.bulkPut(data.noteTags);
          result.noteTagsCount = data.noteTags.length;
        }
        if (data.notes && Array.isArray(data.notes)) {
          await db.notes.bulkPut(data.notes);
          result.notesCount = data.notes.length;
        }
        if (data.appSettings && Array.isArray(data.appSettings)) {
          await db.appSettings.bulkPut(data.appSettings);
          result.appSettingsCount = data.appSettings.length;
        }
      }

      return { ok: true, data: result };
    } catch (error) {
      console.error('JSON import failed:', error);
      return { ok: false, error: `Failed to import JSON file: ${String(error)}` };
    }
  }
}
