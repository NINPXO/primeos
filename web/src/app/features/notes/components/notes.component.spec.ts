import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NotesComponent } from './notes.component';
import { NotesService } from '../services/notes.service';
import { DatabaseService } from '../../../core/services/database.service';

describe('NotesComponent', () => {
  let component: NotesComponent;
  let fixture: ComponentFixture<NotesComponent>;
  let service: NotesService;
  let db: DatabaseService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NotesComponent],
      providers: [NotesService, DatabaseService],
    }).compileComponents();

    fixture = TestBed.createComponent(NotesComponent);
    component = fixture.componentInstance;
    service = TestBed.inject(NotesService);
    db = TestBed.inject(DatabaseService);

    // Initialize database
    await db.clearAll();
    await db.initializeWithSeed();
  });

  afterEach(async () => {
    await db.clearAll();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('view management', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should initialize with grid view', () => {
      expect(component.viewMode).toBe('grid');
    });

    it('should toggle to list view', () => {
      component.toggleView('list');
      expect(component.viewMode).toBe('list');
    });

    it('should toggle back to grid view', () => {
      component.viewMode = 'list';
      component.toggleView('grid');
      expect(component.viewMode).toBe('grid');
    });
  });

  describe('tag filtering', () => {
    beforeEach(async () => {
      fixture.detectChanges();
      await service.addNote({
        title: 'Tagged Note',
        richContent: { ops: [{ insert: 'Content' }] },
        tags: ['Angular', 'Web'],
      });
    });

    it('should toggle tag selection', async () => {
      const tags = await service.loadTags();
      const tag = tags.find((t) => t.name === 'Angular');

      component.toggleTag(tag!.id);
      expect(component.selectedTags).toContain(tag!.id);

      component.toggleTag(tag!.id);
      expect(component.selectedTags).not.toContain(tag!.id);
    });

    it('should filter notes by selected tag', async () => {
      const tags = await service.loadTags();
      const angularTag = tags.find((t) => t.name === 'Angular');

      component.selectedTags = [angularTag!.id];
      await component.applyFilters();

      expect(component.filteredNotes.length).toBeGreaterThan(0);
      expect(
        component.filteredNotes.every((n) =>
          n.tags.some((t) => t.id === angularTag!.id)
        )
      ).toBe(true);
    });

    it('should clear filters', async () => {
      component.searchTerm = 'test';
      component.selectedTags = ['tag-1'];

      component.clearFilters();

      expect(component.searchTerm).toBe('');
      expect(component.selectedTags).toEqual([]);
    });
  });

  describe('search functionality', () => {
    beforeEach(async () => {
      fixture.detectChanges();
      await service.addNote({
        title: 'Angular Guide',
        richContent: { ops: [{ insert: 'Angular content' }] },
      });
      await service.addNote({
        title: 'React Tutorial',
        richContent: { ops: [{ insert: 'React content' }] },
      });
    });

    it('should search notes by title', async () => {
      component.searchTerm = 'Angular';
      await component.applyFilters();

      expect(component.filteredNotes.length).toBe(1);
      expect(component.filteredNotes[0].title).toBe('Angular Guide');
    });

    it('should update search on input change', async () => {
      spyOn(component, 'applyFilters');

      component.searchTerm = 'React';
      component.onSearchChange();

      expect(component.applyFilters).toHaveBeenCalled();
    });
  });

  describe('editor management', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should open editor for new note', () => {
      expect(component.isEditorVisible).toBe(false);
      component.newNote();
      expect(component.isEditorVisible).toBe(true);
      expect(component.selectedNote).toBeNull();
    });

    it('should open editor to edit note', async () => {
      const note = await service.addNote({
        title: 'Test Note',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      component.editNote(note);

      expect(component.isEditorVisible).toBe(true);
      expect(component.selectedNote).toBe(note);
    });

    it('should close editor', () => {
      component.isEditorVisible = true;
      component.selectedNote = {} as any;

      component.closeEditor();

      expect(component.isEditorVisible).toBe(false);
      expect(component.selectedNote).toBeNull();
    });
  });

  describe('note operations', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should save new note through editor', async () => {
      const editorData = {
        title: 'New Note',
        richContent: { ops: [{ insert: 'Content' }] },
        tags: [],
      };

      await component.onEditorSave(editorData);

      expect(component.isEditorVisible).toBe(false);
      const notes = await service.loadNotes();
      expect(notes.some((n) => n.title === 'New Note')).toBe(true);
    });

    it('should update existing note through editor', async () => {
      const note = await service.addNote({
        title: 'Original Title',
        richContent: { ops: [{ insert: 'Original Content' }] },
      });

      component.selectedNote = note;
      const editorData = {
        title: 'Updated Title',
        richContent: { ops: [{ insert: 'Updated Content' }] },
        tags: [],
      };

      await component.onEditorSave(editorData);

      const updated = await db.notes.get(note.id);
      expect(updated?.title).toBe('Updated Title');
    });

    it('should archive note', async () => {
      const note = await service.addNote({
        title: 'To Archive',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      await component.archiveNote(note);

      const archived = await db.notes.get(note.id);
      expect(archived?.isArchived).toBe(true);
    });

    it('should delete note with confirmation', async () => {
      const note = await service.addNote({
        title: 'To Delete',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      spyOn(window, 'confirm').and.returnValue(true);
      await component.deleteNote(note);

      const deleted = await db.notes.get(note.id);
      expect(deleted?.isDeleted).toBe(true);
    });

    it('should not delete note if confirmation cancelled', async () => {
      const note = await service.addNote({
        title: 'To Delete',
        richContent: { ops: [{ insert: 'Content' }] },
      });

      spyOn(window, 'confirm').and.returnValue(false);
      await component.deleteNote(note);

      const notDeleted = await db.notes.get(note.id);
      expect(notDeleted?.isDeleted).toBe(false);
    });
  });

  describe('utility methods', () => {
    it('should get note preview', async () => {
      const note = await service.addNote({
        title: 'Test',
        richContent: {
          ops: [{ insert: 'This is a test note with content' }],
        },
      });

      const preview = component.getPreview(note);
      expect(preview).toBeTruthy();
      expect(preview.length).toBeGreaterThan(0);
    });

    it('should check if tag is selected', () => {
      component.selectedTags = ['tag-1', 'tag-2'];

      expect(component.isTagSelected('tag-1')).toBe(true);
      expect(component.isTagSelected('tag-3')).toBe(false);
    });

    it('should get note tags', async () => {
      const note = await service.addNote({
        title: 'Tagged Note',
        richContent: { ops: [{ insert: 'Content' }] },
        tags: ['Tag1', 'Tag2'],
      });

      const tags = component.getNoteTags(note);
      expect(tags.length).toBe(2);
    });
  });
});
