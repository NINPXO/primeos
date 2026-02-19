import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { DatabaseService } from '../../../core/services/database.service';
import {
  Note,
  NoteWithTags,
  Tag,
  NoteTag,
  CreateNoteRequest,
  UpdateNoteRequest,
  NoteFilterOptions,
} from '../../../shared/models';

/**
 * Notes Service
 * Manages notes and tags with Dexie persistence
 */
@Injectable({
  providedIn: 'root',
})
export class NotesService {
  private notesSubject = new BehaviorSubject<NoteWithTags[]>([]);
  public notes$ = this.notesSubject.asObservable();

  private tagsSubject = new BehaviorSubject<Tag[]>([]);
  public tags$ = this.tagsSubject.asObservable();

  constructor(private db: DatabaseService) {
    this.loadTags();
    this.loadNotes();
  }

  /**
   * Load all tags
   */
  async loadTags(): Promise<Tag[]> {
    try {
      const tags = await this.db.tags.toArray();
      this.tagsSubject.next(tags);
      return tags;
    } catch (error) {
      console.error('Error loading tags:', error);
      return [];
    }
  }

  /**
   * Get tags as observable
   */
  getTags$(): Observable<Tag[]> {
    return this.tags$;
  }

  /**
   * Get current tags (snapshot)
   */
  getTags(): Tag[] {
    return this.tagsSubject.value;
  }

  /**
   * Load all non-deleted, non-archived notes with tags
   */
  async loadNotes(options?: NoteFilterOptions): Promise<NoteWithTags[]> {
    try {
      let allNotes = await this.db.notes.toArray();
      let notes = allNotes.filter(n => !n.isDeleted);

      // Filter archived if requested
      if (options?.excludeArchived !== false) {
        notes = notes.filter((n) => !n.isArchived);
      }

      // Load tags for each note
      const notesWithTags = await Promise.all(
        notes.map(async (note) => {
          const tags = await this.getNoteTags(note.id);
          return { ...note, tags } as NoteWithTags;
        })
      );

      // Apply search filter
      let filtered = notesWithTags;
      if (options?.searchTerm) {
        const term = options.searchTerm.toLowerCase();
        filtered = notesWithTags.filter(
          (n) =>
            n.title.toLowerCase().includes(term) ||
            n.tags.some((t) => t.name.toLowerCase().includes(term))
        );
      }

      // Apply tag filter
      if (options?.tagIds && options.tagIds.length > 0) {
        filtered = filtered.filter((n) =>
          options.tagIds?.some((tagId) =>
            n.tags.some((t) => t.id === tagId)
          )
        );
      }

      this.notesSubject.next(filtered);
      return filtered;
    } catch (error) {
      console.error('Error loading notes:', error);
      return [];
    }
  }

  /**
   * Get notes as observable
   */
  getNotes$(): Observable<NoteWithTags[]> {
    return this.notes$;
  }

  /**
   * Get a single note by id with tags
   */
  async getNote(id: string): Promise<NoteWithTags | undefined> {
    try {
      const note = await this.db.notes.get(id);
      if (!note || note.isDeleted) {
        return undefined;
      }

      const tags = await this.getNoteTags(id);
      return { ...note, tags } as NoteWithTags;
    } catch (error) {
      console.error('Error getting note:', error);
      return undefined;
    }
  }

  /**
   * Get tags for a note
   */
  async getNoteTags(noteId: string): Promise<Tag[]> {
    try {
      const noteTags = await this.db.noteTags
        .where('noteId')
        .equals(noteId)
        .toArray();

      const tagIds = noteTags.map((nt) => nt.tagId);
      const tags = await this.db.tags
        .bulkGet(tagIds);

      return tags.filter((t) => t !== undefined) as Tag[];
    } catch (error) {
      console.error('Error getting note tags:', error);
      return [];
    }
  }

  /**
   * Add a new note
   */
  async addNote(request: CreateNoteRequest): Promise<NoteWithTags> {
    const now = new Date().toISOString();
    const id = this.generateId();

    const note: Note = {
      id,
      title: request.title,
      richContent: request.richContent,
      isArchived: false,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    };

    try {
      await this.db.notes.add(note);

      // Add tags
      let tags: Tag[] = [];
      if (request.tags && request.tags.length > 0) {
        tags = await this.addTagsToNote(id, request.tags);
      }

      const result = { ...note, tags } as NoteWithTags;
      await this.loadNotes();
      return result;
    } catch (error) {
      console.error('Error adding note:', error);
      throw error;
    }
  }

  /**
   * Update an existing note
   */
  async updateNote(id: string, request: UpdateNoteRequest): Promise<void> {
    try {
      const now = new Date().toISOString();
      const updates: any = { updatedAt: now };

      if (request.title !== undefined) {
        updates.title = request.title;
      }
      if (request.richContent !== undefined) {
        updates.richContent = request.richContent;
      }

      await this.db.notes.update(id, updates);

      // Update tags if provided
      if (request.tags !== undefined) {
        // Remove old tags
        await this.db.noteTags
          .where('noteId')
          .equals(id)
          .delete();

        // Add new tags
        if (request.tags.length > 0) {
          await this.addTagsToNote(id, request.tags);
        }
      }

      await this.loadNotes();
    } catch (error) {
      console.error('Error updating note:', error);
      throw error;
    }
  }

  /**
   * Archive a note
   */
  async archiveNote(id: string): Promise<void> {
    try {
      const now = new Date().toISOString();
      await this.db.notes.update(id, {
        isArchived: true,
        updatedAt: now,
      });

      await this.loadNotes();
    } catch (error) {
      console.error('Error archiving note:', error);
      throw error;
    }
  }

  /**
   * Delete a note (soft delete)
   */
  async deleteNote(id: string): Promise<void> {
    try {
      const now = new Date().toISOString();
      await this.db.notes.update(id, {
        isDeleted: true,
        updatedAt: now,
      });

      await this.loadNotes();
    } catch (error) {
      console.error('Error deleting note:', error);
      throw error;
    }
  }

  /**
   * Restore a deleted note
   */
  async restoreNote(id: string): Promise<void> {
    try {
      const now = new Date().toISOString();
      await this.db.notes.update(id, {
        isDeleted: false,
        updatedAt: now,
      });

      await this.loadNotes();
    } catch (error) {
      console.error('Error restoring note:', error);
      throw error;
    }
  }

  /**
   * Add or create tags for a note
   */
  private async addTagsToNote(
    noteId: string,
    tagIdentifiers: string[]
  ): Promise<Tag[]> {
    const tags: Tag[] = [];

    for (const identifier of tagIdentifiers) {
      let tag = await this.db.tags
        .where('name')
        .equals(identifier)
        .first();

      if (!tag) {
        // Create new tag
        const tagId = this.generateId();
        const now = new Date().toISOString();
        tag = {
          id: tagId,
          name: identifier,
          createdAt: now,
          updatedAt: now,
        };
        await this.db.tags.add(tag);
      }

      // Add junction record
      await this.db.noteTags.add({
        noteId,
        tagId: tag.id,
      });

      tags.push(tag);
    }

    // Reload tags
    await this.loadTags();
    return tags;
  }

  /**
   * Add a new tag
   */
  async addTag(name: string): Promise<Tag> {
    // Check if tag already exists
    const existing = await this.db.tags
      .where('name')
      .equals(name)
      .first();

    if (existing) {
      return existing;
    }

    const now = new Date().toISOString();
    const tag: Tag = {
      id: this.generateId(),
      name,
      createdAt: now,
      updatedAt: now,
    };

    try {
      await this.db.tags.add(tag);
      await this.loadTags();
      return tag;
    } catch (error) {
      console.error('Error adding tag:', error);
      throw error;
    }
  }

  /**
   * Remove a tag from a note
   */
  async removeTagFromNote(noteId: string, tagId: string): Promise<void> {
    try {
      await this.db.noteTags
        .where('[noteId+tagId]')
        .equals([noteId, tagId])
        .delete();

      await this.loadNotes();
    } catch (error) {
      console.error('Error removing tag from note:', error);
      throw error;
    }
  }

  /**
   * Get note preview (first 100 characters of rich content)
   */
  getPreview(note: NoteWithTags): string {
    if (!note.richContent || !note.richContent.ops) {
      return '';
    }

    const text = note.richContent.ops
      .filter((op: any) => typeof op.insert === 'string')
      .map((op: any) => op.insert)
      .join('')
      .substring(0, 100);

    return text;
  }

  /**
   * Generate a unique ID
   */
  private generateId(): string {
    return `note-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
