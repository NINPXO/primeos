import { Injectable } from '@angular/core';
import { GoalsService } from './goals.service';
import { ProgressService } from './progress.service';
import { NotesService } from './notes.service';
import { AppResult } from '../types/app-result';

@Injectable({
  providedIn: 'root'
})
export class CsvImportService {
  constructor(
    private goalsService: GoalsService,
    private progressService: ProgressService,
    private notesService: NotesService
  ) {}

  async importGoals(csvContent: string): Promise<AppResult<{ count: number }>> {
    try {
      const lines = csvContent.trim().split('\n');
      if (lines.length < 2) {
        return { ok: false, error: 'CSV file is empty' };
      }

      const headers = this.parseCSVLine(lines[0]);
      const titleIndex = headers.indexOf('Title');
      const categoryIdIndex = headers.indexOf('Category ID');
      const statusIndex = headers.indexOf('Status');
      const targetDateIndex = headers.indexOf('Target Date');
      const descriptionIndex = headers.indexOf('Description');

      if (titleIndex === -1 || categoryIdIndex === -1) {
        return { ok: false, error: 'Missing required columns: Title, Category ID' };
      }

      let imported = 0;
      for (let i = 1; i < lines.length; i++) {
        const values = this.parseCSVLine(lines[i]);
        if (values.length < headers.length) continue;

        try {
          await this.goalsService.addGoal({
            title: values[titleIndex] || '',
            description: descriptionIndex >= 0 ? values[descriptionIndex] : '',
            categoryId: values[categoryIdIndex] || '',
            status: (statusIndex >= 0 ? values[statusIndex] : 'active') as any,
            targetDate: targetDateIndex >= 0 ? values[targetDateIndex] : new Date().toISOString()
          });
          imported++;
        } catch (error) {
          console.warn(`Failed to import goal row ${i}:`, error);
        }
      }

      return { ok: true, data: { count: imported } };
    } catch (error) {
      return { ok: false, error: String(error) };
    }
  }

  async importProgress(csvContent: string): Promise<AppResult<{ count: number }>> {
    try {
      const lines = csvContent.trim().split('\n');
      if (lines.length < 2) {
        return { ok: false, error: 'CSV file is empty' };
      }

      const headers = this.parseCSVLine(lines[0]);
      const goalIdIndex = headers.indexOf('Goal ID');
      const valueIndex = headers.indexOf('Value');
      const dateIndex = headers.indexOf('Date');
      const noteIndex = headers.indexOf('Note');

      if (goalIdIndex === -1 || valueIndex === -1 || dateIndex === -1) {
        return { ok: false, error: 'Missing required columns: Goal ID, Value, Date' };
      }

      let imported = 0;
      for (let i = 1; i < lines.length; i++) {
        const values = this.parseCSVLine(lines[i]);
        if (values.length < headers.length) continue;

        try {
          await this.progressService.addEntry({
            goalId: values[goalIdIndex] || '',
            value: parseFloat(values[valueIndex]) || 0,
            date: values[dateIndex] || new Date().toISOString(),
            note: noteIndex >= 0 ? values[noteIndex] : undefined
          });
          imported++;
        } catch (error) {
          console.warn(`Failed to import progress row ${i}:`, error);
        }
      }

      return { ok: true, data: { count: imported } };
    } catch (error) {
      return { ok: false, error: String(error) };
    }
  }

  async importNotes(csvContent: string): Promise<AppResult<{ count: number }>> {
    try {
      const lines = csvContent.trim().split('\n');
      if (lines.length < 2) {
        return { ok: false, error: 'CSV file is empty' };
      }

      const headers = this.parseCSVLine(lines[0]);
      const titleIndex = headers.indexOf('Title');
      const contentIndex = headers.indexOf('Content');

      if (titleIndex === -1) {
        return { ok: false, error: 'Missing required column: Title' };
      }

      let imported = 0;
      for (let i = 1; i < lines.length; i++) {
        const values = this.parseCSVLine(lines[i]);
        if (values.length < headers.length) continue;

        try {
          const content = contentIndex >= 0 ? values[contentIndex] : '';
          await this.notesService.addNote({
            title: values[titleIndex] || '',
            richContent: {
              ops: [{ insert: content }]
            },
            tags: [],
            isArchived: false
          });
          imported++;
        } catch (error) {
          console.warn(`Failed to import note row ${i}:`, error);
        }
      }

      return { ok: true, data: { count: imported } };
    } catch (error) {
      return { ok: false, error: String(error) };
    }
  }

  private parseCSVLine(line: string): string[] {
    const result: string[] = [];
    let current = '';
    let insideQuotes = false;

    for (let i = 0; i < line.length; i++) {
      const char = line[i];

      if (char === '"') {
        if (insideQuotes && line[i + 1] === '"') {
          current += '"';
          i++;
        } else {
          insideQuotes = !insideQuotes;
        }
      } else if (char === ',' && !insideQuotes) {
        result.push(current.trim());
        current = '';
      } else {
        current += char;
      }
    }

    result.push(current.trim());
    return result;
  }
}
