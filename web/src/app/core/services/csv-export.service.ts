import { Injectable } from '@angular/core';
import { GoalsService } from './goals.service';
import { ProgressService } from './progress.service';
import { NotesService } from './notes.service';
import { Goal, ProgressEntry, Note } from '../models';

@Injectable({
  providedIn: 'root'
})
export class CsvExportService {
  constructor(
    private goalsService: GoalsService,
    private progressService: ProgressService,
    private notesService: NotesService
  ) {}

  async exportGoals(): Promise<string> {
    const goals = await this.goalsService.loadGoals()
      .then(() => new Promise<Goal[]>(resolve => {
        this.goalsService.getGoals().subscribe(g => resolve(g));
      }));

    if (goals.length === 0) return this.createCsvHeader(['ID', 'Title', 'Category ID', 'Status', 'Target Date']);

    const headers = ['ID', 'Title', 'Description', 'Category ID', 'Status', 'Target Date', 'Created At', 'Updated At'];
    const rows = goals.map(g => [
      g.id,
      this.escapeCsv(g.title),
      this.escapeCsv(g.description),
      g.categoryId,
      g.status,
      g.targetDate,
      g.createdAt,
      g.updatedAt
    ]);

    return this.formatCsv(headers, rows);
  }

  async exportProgress(): Promise<string> {
    const entries = await this.progressService.loadProgress()
      .then(() => new Promise<ProgressEntry[]>(resolve => {
        this.progressService.getProgress().subscribe(e => resolve(e));
      }));

    if (entries.length === 0) return this.createCsvHeader(['ID', 'Goal ID', 'Value', 'Date']);

    const headers = ['ID', 'Goal ID', 'Value', 'Date', 'Note', 'Created At', 'Updated At'];
    const rows = entries.map(e => [
      e.id,
      e.goalId,
      e.value,
      e.date,
      this.escapeCsv(e.note || ''),
      e.createdAt,
      e.updatedAt
    ]);

    return this.formatCsv(headers, rows);
  }

  async exportNotes(): Promise<string> {
    const notes = await this.notesService.loadNotes()
      .then(() => new Promise<Note[]>(resolve => {
        this.notesService.getNotes().subscribe(n => resolve(n));
      }));

    if (notes.length === 0) return this.createCsvHeader(['ID', 'Title', 'Content', 'Tags', 'Is Archived']);

    const headers = ['ID', 'Title', 'Content', 'Tags', 'Is Archived', 'Created At', 'Updated At'];
    const rows = notes.map(n => [
      n.id,
      this.escapeCsv(n.title),
      this.escapeCsv(this.extractTextFromDelta(n.richContent)),
      this.escapeCsv(n.tags.map(t => t.name).join(', ')),
      n.isArchived ? 'true' : 'false',
      n.createdAt,
      n.updatedAt
    ]);

    return this.formatCsv(headers, rows);
  }

  private formatCsv(headers: string[], rows: (string | number | boolean)[][]): string {
    const headerRow = headers.map(h => this.escapeCsv(h)).join(',');
    const dataRows = rows.map(row =>
      row.map(cell => this.escapeCsv(String(cell))).join(',')
    );
    return [headerRow, ...dataRows].join('\n');
  }

  private createCsvHeader(headers: string[]): string {
    return headers.map(h => this.escapeCsv(h)).join(',');
  }

  private escapeCsv(value: string): string {
    if (!value) return '';
    if (value.includes(',') || value.includes('"') || value.includes('\n')) {
      return `"${value.replace(/"/g, '""')}"`;
    }
    return value;
  }

  private extractTextFromDelta(delta: object): string {
    try {
      if (typeof delta !== 'object' || !delta) return '';
      const deltaObj = delta as any;
      if (!Array.isArray(deltaObj.ops)) return '';

      return deltaObj.ops
        .map((op: any) => (typeof op.insert === 'string' ? op.insert : ''))
        .join('');
    } catch {
      return '';
    }
  }
}
