import { Injectable } from '@angular/core';
import { db } from '../database/app-database';
import { SearchResult, Goal, ProgressEntry, DailyLogEntry, Note } from '../models';

@Injectable({
  providedIn: 'root'
})
export class SearchService {
  async search(query: string): Promise<SearchResult[]> {
    if (!query || query.length < 2) {
      return [];
    }

    const lowerQuery = query.toLowerCase();
    const results: SearchResult[] = [];

    try {
      // Search goals
      const allGoals = await db.goals.toArray();
      const goals = allGoals.filter(g => !g.isDeleted);

      goals.forEach((goal: Goal) => {
        if (
          goal.title.toLowerCase().includes(lowerQuery) ||
          goal.description?.toLowerCase().includes(lowerQuery)
        ) {
          results.push({
            type: 'goal',
            id: goal.id,
            title: goal.title,
            snippet: goal.description || '',
            path: `/goals/${goal.id}`,
            createdAt: goal.createdAt
          });
        }
      });

      // Search progress entries
      const allProgressEntries = await db.progressEntries.toArray();
      const progressEntries = allProgressEntries.filter(e => !e.isDeleted);

      progressEntries.forEach((entry: ProgressEntry) => {
        if (entry.note?.toLowerCase().includes(lowerQuery)) {
          results.push({
            type: 'progress',
            id: entry.id,
            title: `Progress for Goal ${entry.goalId}`,
            snippet: entry.note || '',
            path: `/progress/${entry.id}`,
            createdAt: entry.createdAt
          });
        }
      });

      // Search daily logs
      const allLogEntries = await db.dailyLogEntries.toArray();
      const logEntries = allLogEntries.filter(e => !e.isDeleted);

      logEntries.forEach(entry => {
        if (entry.note?.toLowerCase().includes(lowerQuery)) {
          results.push({
            type: 'log',
            id: entry.id,
            title: `Daily Log ${entry.logDate}`,
            snippet: entry.note || '',
            path: `/daily-log?date=${entry.logDate}`,
            createdAt: entry.createdAt
          });
        }
      });

      // Search notes
      const allNotes = await db.notes.toArray();
      const notes = allNotes.filter(n => !n.isDeleted);

      notes.forEach(note => {
        if (note.title.toLowerCase().includes(lowerQuery)) {
          results.push({
            type: 'note',
            id: note.id,
            title: note.title,
            snippet: this.extractTextFromDelta(note.richContent),
            path: `/notes/${note.id}`,
            createdAt: note.createdAt
          });
        }
      });

      // Sort by relevance (exact matches first, then by creation date)
      results.sort((a, b) => {
        const aExact = a.title.toLowerCase().includes(lowerQuery);
        const bExact = b.title.toLowerCase().includes(lowerQuery);
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
        return new Date(b.createdAt || '').getTime() - new Date(a.createdAt || '').getTime();
      });

      return results;
    } catch (error) {
      console.error('Error searching:', error);
      return [];
    }
  }

  private extractTextFromDelta(delta: object): string {
    try {
      if (typeof delta !== 'object' || !delta) return '';
      const deltaObj = delta as any;
      if (!Array.isArray(deltaObj.ops)) return '';

      return deltaObj.ops
        .map((op: any) => (typeof op.insert === 'string' ? op.insert : ''))
        .join('')
        .substring(0, 200);
    } catch {
      return '';
    }
  }
}
