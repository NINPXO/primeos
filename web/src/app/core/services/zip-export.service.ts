import { Injectable } from '@angular/core';
import { db } from '../database/app-database';
import { CsvExportService } from './csv-export.service';

declare let JSZip: any;

@Injectable({
  providedIn: 'root'
})
export class ZipExportService {
  constructor(private csvExportService: CsvExportService) {}

  async exportAll(): Promise<Blob> {
    try {
      // Check if JSZip is available
      if (typeof window !== 'undefined' && !(window as any).JSZip) {
        throw new Error('JSZip library not loaded. Please ensure jszip is properly imported.');
      }

      const zip = new (window as any).JSZip();

      // Export all tables as JSON
      const goals = await db.goals.toArray();
      const progressEntries = await db.progressEntries.toArray();
      const goalCategories = await db.goalCategories.toArray();
      const dailyLogCategories = await db.dailyLogCategories.toArray();
      const dailyLogEntries = await db.dailyLogEntries.toArray();
      const noteTags = await db.noteTags.toArray();
      const notes = await db.notes.toArray();
      const appSettings = await db.appSettings.toArray();

      // Add JSON files
      zip.file('goals.json', JSON.stringify(goals, null, 2));
      zip.file('progressEntries.json', JSON.stringify(progressEntries, null, 2));
      zip.file('goalCategories.json', JSON.stringify(goalCategories, null, 2));
      zip.file('dailyLogCategories.json', JSON.stringify(dailyLogCategories, null, 2));
      zip.file('dailyLogEntries.json', JSON.stringify(dailyLogEntries, null, 2));
      zip.file('noteTags.json', JSON.stringify(noteTags, null, 2));
      zip.file('notes.json', JSON.stringify(notes, null, 2));
      zip.file('appSettings.json', JSON.stringify(appSettings, null, 2));

      // Add CSV files
      const goalsCSV = await this.csvExportService.exportGoals();
      const progressCSV = await this.csvExportService.exportProgress();
      const notesCSV = await this.csvExportService.exportNotes();

      zip.file('goals.csv', goalsCSV);
      zip.file('progressEntries.csv', progressCSV);
      zip.file('notes.csv', notesCSV);

      // Add metadata
      const metadata = {
        exportDate: new Date().toISOString(),
        version: '1.0',
        dataCount: {
          goals: goals.length,
          progressEntries: progressEntries.length,
          goalCategories: goalCategories.length,
          dailyLogCategories: dailyLogCategories.length,
          dailyLogEntries: dailyLogEntries.length,
          noteTags: noteTags.length,
          notes: notes.length
        }
      };

      zip.file('metadata.json', JSON.stringify(metadata, null, 2));

      return await zip.generateAsync({ type: 'blob' });
    } catch (error) {
      console.error('Error exporting data to ZIP:', error);
      throw error;
    }
  }

  downloadExport(blob: Blob, filename: string = 'primeos-export.zip'): void {
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  }
}
