import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoteEditorComponent } from './note-editor.component';
import { NoteWithTags, Tag } from '../../../shared/models';

describe('NoteEditorComponent', () => {
  let component: NoteEditorComponent;
  let fixture: ComponentFixture<NoteEditorComponent>;

  const mockTags: Tag[] = [
    {
      id: 'tag-1',
      name: 'Angular',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'tag-2',
      name: 'TypeScript',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
  ];

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NoteEditorComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(NoteEditorComponent);
    component = fixture.componentInstance;
    component.allTags = mockTags;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('initialization', () => {
    it('should initialize add mode when no note provided', () => {
      component.note = null;
      fixture.detectChanges();

      expect(component.isEdit).toBe(false);
      expect(component.form.title).toBe('');
      expect(component.selectedTags).toEqual([]);
    });

    it('should initialize edit mode when note provided', () => {
      const mockNote: NoteWithTags = {
        id: 'note-1',
        title: 'Test Note',
        richContent: { ops: [{ insert: 'Test Content' }] },
        isArchived: false,
        isDeleted: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        tags: mockTags,
      };

      component.note = mockNote;
      fixture.detectChanges();

      expect(component.isEdit).toBe(true);
      expect(component.form.title).toBe('Test Note');
      expect(component.selectedTags).toEqual(mockTags);
    });
  });

  describe('validation', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should validate required title', () => {
      component.form.title = '';
      component.form.richContent = { ops: [{ insert: 'Content' }] };

      const valid = component.validate();

      expect(valid).toBe(false);
      expect(component.errors).toContain('Title is required');
    });

    it('should validate required content', () => {
      component.form.title = 'Test Title';
      component.form.richContent = { ops: [] };

      const valid = component.validate();

      expect(valid).toBe(false);
      expect(component.errors).toContain('Content is required');
    });

    it('should pass validation with valid data', () => {
      component.form.title = 'Test Title';
      component.form.richContent = { ops: [{ insert: 'Test Content' }] };

      const valid = component.validate();

      expect(valid).toBe(true);
      expect(component.errors.length).toBe(0);
    });

    it('should reject whitespace-only title', () => {
      component.form.title = '   ';
      component.form.richContent = { ops: [{ insert: 'Content' }] };

      const valid = component.validate();

      expect(valid).toBe(false);
    });

    it('should reject whitespace-only content', () => {
      component.form.title = 'Test Title';
      component.form.richContent = { ops: [{ insert: '   ' }] };

      const valid = component.validate();

      expect(valid).toBe(false);
    });
  });

  describe('form events', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should emit save event with valid data', (done) => {
      component.form.title = 'Test Title';
      component.form.richContent = { ops: [{ insert: 'Content' }] };

      component.save.subscribe((data) => {
        expect(data.title).toBe('Test Title');
        expect(data.richContent.ops).toBeTruthy();
        done();
      });

      component.onSave();
    });

    it('should not emit save event with invalid data', (done) => {
      component.form.title = '';
      component.form.richContent = { ops: [] };

      let emitted = false;
      component.save.subscribe(() => {
        emitted = true;
      });

      component.onSave();
      setTimeout(() => {
        expect(emitted).toBe(false);
        done();
      }, 100);
    });

    it('should emit cancel event', (done) => {
      component.cancel.subscribe(() => {
        done();
      });

      component.onCancel();
    });
  });

  describe('tag management', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should get available tags', () => {
      component.tagInput = '';
      const available = component.getAvailableTags();

      expect(available.length).toBe(mockTags.length);
    });

    it('should filter available tags by input', () => {
      component.tagInput = 'angular';
      const available = component.getAvailableTags();

      expect(available.length).toBe(1);
      expect(available[0].name).toBe('Angular');
    });

    it('should not show selected tags in available', () => {
      component.selectedTags = [mockTags[0]];
      component.tagInput = '';
      const available = component.getAvailableTags();

      expect(available).not.toContain(mockTags[0]);
      expect(available).toContain(mockTags[1]);
    });

    it('should select tag from autocomplete', () => {
      component.selectTag(mockTags[0]);

      expect(component.selectedTags).toContain(mockTags[0]);
      expect(component.form.tags).toContain(mockTags[0].id);
      expect(component.tagInput).toBe('');
    });

    it('should not select duplicate tags', () => {
      component.selectTag(mockTags[0]);
      component.selectTag(mockTags[0]);

      expect(component.selectedTags.filter((t) => t.id === mockTags[0].id).length).toBe(1);
    });

    it('should remove tag from note', () => {
      component.selectedTags = [mockTags[0], mockTags[1]];
      component.form.tags = [mockTags[0].id, mockTags[1].id];

      component.removeTag(mockTags[0]);

      expect(component.selectedTags).not.toContain(mockTags[0]);
      expect(component.form.tags).not.toContain(mockTags[0].id);
    });

    it('should add new tag by name', () => {
      const event = { target: { value: 'NewTag' } };
      component.addTag(event);

      expect(component.selectedTags.length).toBe(1);
      expect(component.selectedTags[0].name).toBe('NewTag');
      expect(component.form.tags).toContain('NewTag');
    });

    it('should select existing tag when adding', () => {
      const event = { target: { value: 'Angular' } };
      component.addTag(event);

      expect(component.selectedTags).toContain(mockTags[0]);
    });

    it('should clear tag input after adding', () => {
      component.tagInput = 'NewTag';
      const event = { target: { value: 'NewTag' } };

      component.addTag(event);

      expect(component.tagInput).toBe('');
      expect(event.target.value).toBe('');
    });
  });

  describe('editor changes', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should update rich content on editor change', () => {
      const newDelta = { ops: [{ insert: 'Updated' }] };
      component.onEditorChange(newDelta);

      expect(component.form.richContent).toEqual(newDelta);
    });
  });

  describe('display methods', () => {
    it('should get tag display name', () => {
      const name = component.getTagDisplayName(mockTags[0]);
      expect(name).toBe('Angular');
    });
  });
});
