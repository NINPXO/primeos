import { Injectable } from '@angular/core';
import { db } from '../database/app-database';
import { SearchResult } from '../models';

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
      const goals = await db.goals
        .where('isDeleted')
        .equals(false)
        .toArray();

      goals.forEach(goal => {
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
      const progressEntries = await db.progressEntries
        .where('isDeleted')
        .equals(false)
        .toArray();

      progressEntries.forEach(entry => {
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
      const logEntries = await db.dailyLogEntries
        .where('isDeleted')
        .equals(false)
        .toArray();

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
      const notes = await db.notes
        .where('isDeleted')
        .equals(false)
        .toArray();

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
