import { TestBed } from '@angular/core/testing';
import { NotesService } from './notes.service';
import { DatabaseService } from '../../../core/services/database.service';

describe('NotesService', () => {
  let service: NotesService;
  let db: DatabaseService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      providers: [NotesService, DatabaseService],
    }).compileComponents();

    service = TestBed.inject(NotesService);
    db = TestBed.inject(DatabaseService);

    // Clear and initialize database
    await db.clearAll();
    await db.initializeWithSeed();
  });

  afterEach(async () => {
    await db.clearAll();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  describe('tag management', () => {
    it('should load tags', async () => {
      const tag = await service.addTag('Test Tag');
      const tags = await service.loadTags();

      expect(tags.length).toBeGreaterThan(0);
      expect(tags.some((t) => t.id === tag.id)).toBe(true);
    });

    it('should add new tag', async () => {
      const tag = await service.addTag('New Tag');

      expect(tag.id).toBeTruthy();
      expect(tag.name).toBe('New Tag');

      const loaded = await db.tags.get(tag.id);
      expect(loaded).toBeTruthy();
    });

    it('should not create duplicate tags', async () => {
      await service.addTag('Duplicate');
      const tag2 = await service.addTag('Duplicate');

      const allTags = await db.tags.where('name').equals('Duplicate').toArray();
      expect(allTags.length).toBe(1);
      expect(tag2.name).toBe('Duplicate');
    });
  });

  describe('note management', () => {
    it('should add a new note', async () => {
      const note = await service.addNote({
        title: 'Test Note',
        richContent: { ops: [{ insert: 'Hello World' }] },
      });

      expect(note.id).toBeTruthy();
      expect(note.title).toBe('Test Note');
      expect(note.isDeleted).toBe(false);
      expect(note.isArchived).toBe(false);
    });

    it('should add note with tags', async () => {
      const note = await service.addNote({
        title: 'Tagged Note',
        richContent: { ops: [{ insert: 'Content' }] },
        tags: ['Tag1', 'Tag2'],
      });

      expect(note.tags.length).toBe(2);
      expect(note.tags.map((t) => t.name)).toContain('Tag1');
      expect(note.tags.map((t) => t.name)).toContain('Tag2');
    });

    it('should load notes', async () => {
      await service.addNote({
        title: 'Note 1',
        richContent: { ops: [{ insert: 'Content 1' }] },
      });
      await service.addNote({
        title: 'Note 2',
        richContent: { ops: [{ insert: 'Content 2' }] },
      });

      const notes = await service.loadNotes();
      expect(notes.length).toBe(2);
    });

    it('should filter out deleted notes', async () => {
      const note = await service.addNote({
        title: 'To Delete',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      await service.deleteNote(note.id);
      const notes = await service.loadNotes();

      expect(notes.some((n) => n.id === note.id)).toBe(false);
    });

    it('should filter out archived notes by default', async () => {
      const note = await service.addNote({
        title: 'To Archive',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      await service.archiveNote(note.id);
      const notes = await service.loadNotes();

      expect(notes.some((n) => n.id === note.id)).toBe(false);
    });

    it('should include archived notes when excludeArchived is false', async () => {
      const note = await service.addNote({
        title: 'Archived Note',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      await service.archiveNote(note.id);
      const notes = await service.loadNotes({ excludeArchived: false });

      expect(notes.some((n) => n.id === note.id)).toBe(true);
    });
  });

  describe('note operations', () => {
    it('should get a single note', async () => {
      const created = await service.addNote({
        title: 'Single Note',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      const retrieved = await service.getNote(created.id);

      expect(retrieved).toBeTruthy();
      expect(retrieved?.title).toBe('Single Note');
    });

    it('should not get deleted note', async () => {
      const note = await service.addNote({
        title: 'To Delete',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      await service.deleteNote(note.id);
      const retrieved = await service.getNote(note.id);

      expect(retrieved).toBeUndefined();
    });

    it('should update note', async () => {
      const note = await service.addNote({
        title: 'Original Title',
        richContent: { ops: [{ insert: 'Original Content' }] },
      });

      await service.updateNote(note.id, {
        title: 'Updated Title',
        richContent: { ops: [{ insert: 'Updated Content' }] },
      });

      const updated = await db.notes.get(note.id);
      expect(updated?.title).toBe('Updated Title');
    });

    it('should update note tags', async () => {
      const note = await service.addNote({
        title: 'Note with Tags',
        richContent: { ops: [{ insert: 'Content' }] },
        tags: ['OldTag'],
      });

      await service.updateNote(note.id, {
        tags: ['NewTag1', 'NewTag2'],
      });

      const tags = await service.getNoteTags(note.id);
      expect(tags.map((t) => t.name)).toEqual(['NewTag1', 'NewTag2']);
    });

    it('should archive note', async () => {
      const note = await service.addNote({
        title: 'To Archive',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      await service.archiveNote(note.id);

      const archived = await db.notes.get(note.id);
      expect(archived?.isArchived).toBe(true);
    });

    it('should soft delete note', async () => {
      const note = await service.addNote({
        title: 'To Delete',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      await service.deleteNote(note.id);

      const deleted = await db.notes.get(note.id);
      expect(deleted?.isDeleted).toBe(true);
    });

    it('should restore deleted note', async () => {
      const note = await service.addNote({
        title: 'To Restore',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      await service.deleteNote(note.id);
      await service.restoreNote(note.id);

      const restored = await db.notes.get(note.id);
      expect(restored?.isDeleted).toBe(false);
    });
  });

  describe('filtering', () => {
    beforeEach(async () => {
      await service.addNote({
        title: 'Angular Guide',
        richContent: { ops: [{ insert: 'Angular content' }] },
        tags: ['Angular'],
      });
      await service.addNote({
        title: 'React Tutorial',
        richContent: { ops: [{ insert: 'React content' }] },
        tags: ['React'],
      });
      await service.addNote({
        title: 'Vue Tips',
        richContent: { ops: [{ insert: 'Vue content' }] },
        tags: ['Vue'],
      });
    });

    it('should search notes by title', async () => {
      const notes = await service.loadNotes({ searchTerm: 'Angular' });
      expect(notes.length).toBe(1);
      expect(notes[0].title).toBe('Angular Guide');
    });

    it('should search notes by tag', async () => {
      const notes = await service.loadNotes({ searchTerm: 'React' });
      expect(notes.length).toBe(1);
      expect(notes[0].title).toBe('React Tutorial');
    });

    it('should filter notes by tag ids', async () => {
      const allTags = await service.loadTags();
      const angularTag = allTags.find((t) => t.name === 'Angular');

      const notes = await service.loadNotes({ tagIds: [angularTag!.id] });
      expect(notes.length).toBe(1);
      expect(notes[0].title).toBe('Angular Guide');
    });

    it('should filter notes by multiple tags', async () => {
      const allTags = await service.loadTags();
      const angularTag = allTags.find((t) => t.name === 'Angular');
      const reactTag = allTags.find((t) => t.name === 'React');

      const notes = await service.loadNotes({
        tagIds: [angularTag!.id, reactTag!.id],
      });
      expect(notes.length).toBe(2);
    });
  });

  describe('preview generation', () => {
    it('should generate preview from rich content', async () => {
      const note = await service.addNote({
        title: 'Test',
        richContent: {
          ops: [
            { insert: 'This is a long note with more than 100 characters' },
            { insert: ' to test the preview generation' },
          ],
        },
      });

      const preview = service.getPreview(note);
      expect(preview.length).toBeLessThanOrEqual(100);
      expect(preview).toContain('This is a long note');
    });

    it('should handle empty rich content', async () => {
      const note = await service.addNote({
        title: 'Empty Note',
        richContent: { ops: [] },
      });

      const preview = service.getPreview(note);
      expect(preview).toBe('');
    });
  });
});
