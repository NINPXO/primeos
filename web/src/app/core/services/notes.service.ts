import { Injectable } from '@angular/core';
import { db } from '../database/app-database';
import { Note, NoteTag } from '../models';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class NotesService {
  private notes$ = new BehaviorSubject<Note[]>([]);
  private tags$ = new BehaviorSubject<NoteTag[]>([]);

  constructor() {
    this.loadNotes();
    this.loadTags();
  }

  async loadNotes(): Promise<void> {
    try {
      const notes = await db.notes
        .where('isDeleted')
        .equals(false)
        .toArray();
      notes.sort((a: Note, b: Note) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
      this.notes$.next(notes);
    } catch (error) {
      console.error('Error loading notes:', error);
    }
  }

  async loadTags(): Promise<void> {
    try {
      const tags = await db.noteTags
        .where('isDeleted')
        .equals(false)
        .toArray();
      this.tags$.next(tags);
    } catch (error) {
      console.error('Error loading tags:', error);
    }
  }

  getNotes(): Observable<Note[]> {
    return this.notes$.asObservable();
  }

  getTags(): Observable<NoteTag[]> {
    return this.tags$.asObservable();
  }

  async addNote(note: Omit<Note, 'id' | 'createdAt' | 'updatedAt' | 'isDeleted'>): Promise<Note> {
    const now = new Date().toISOString();
    const newNote: Note = {
      id: this.generateId(),
      ...note,
      createdAt: now,
      updatedAt: now,
      isDeleted: false
    };
    await db.notes.add(newNote);

    // Add tag associations
    if (note.tags && note.tags.length > 0) {
      const junctions = note.tags.map(tag => ({
        noteId: newNote.id,
        tagId: tag.id
      }));
      await db.notesTagsJunction.bulkAdd(junctions);
    }

    await this.loadNotes();
    return newNote;
  }

  async updateNote(id: string, updates: Partial<Note>): Promise<Note> {
    const note = await db.notes.get(id);
    if (!note) {
      throw new Error(`Note with id ${id} not found`);
    }
    const updated: Note = {
      ...note,
      ...updates,
      updatedAt: new Date().toISOString()
    };
    await db.notes.update(id, updated);

    // Update tag associations if tags changed
    if (updates.tags) {
      await db.notesTagsJunction
        .where('noteId')
        .equals(id)
        .delete();
      const junctions = updates.tags.map(tag => ({
        noteId: id,
        tagId: tag.id
      }));
      if (junctions.length > 0) {
        await db.notesTagsJunction.bulkAdd(junctions);
      }
    }

    await this.loadNotes();
    return updated;
  }

  async deleteNote(id: string, soft: boolean = true): Promise<void> {
    if (soft) {
      const now = new Date().toISOString();
      await db.notes.update(id, {
        isDeleted: true,
        updatedAt: now
      });
    } else {
      await db.notes.delete(id);
      await db.notesTagsJunction.where('noteId').equals(id).delete();
    }
    await this.loadNotes();
  }

  async restoreNote(id: string): Promise<void> {
    await db.notes.update(id, {
      isDeleted: false,
      updatedAt: new Date().toISOString()
    });
    await this.loadNotes();
  }

  async archiveNote(id: string): Promise<void> {
    await db.notes.update(id, {
      isArchived: true,
      updatedAt: new Date().toISOString()
    });
    await this.loadNotes();
  }

  async unarchiveNote(id: string): Promise<void> {
    await db.notes.update(id, {
      isArchived: false,
      updatedAt: new Date().toISOString()
    });
    await this.loadNotes();
  }

  async addTag(tag: Omit<NoteTag, 'id' | 'createdAt' | 'isDeleted'>): Promise<NoteTag> {
    const newTag: NoteTag = {
      id: this.generateId(),
      ...tag,
      createdAt: new Date().toISOString(),
      isDeleted: false
    };
    await db.noteTags.add(newTag);
    await this.loadTags();
    return newTag;
  }

  async deleteTag(id: string): Promise<void> {
    await db.noteTags.delete(id);
    await db.notesTagsJunction.where('tagId').equals(id).delete();
    await this.loadTags();
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
