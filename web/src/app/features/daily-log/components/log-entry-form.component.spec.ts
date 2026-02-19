import { ComponentFixture, TestBed } from '@angular/core/testing';
import { LogEntryFormComponent } from './log-entry-form.component';
import { LogCategory, LogEntryWithCategory } from '../../../shared/models';

describe('LogEntryFormComponent', () => {
  let component: LogEntryFormComponent;
  let fixture: ComponentFixture<LogEntryFormComponent>;

  const mockCategories: LogCategory[] = [
    {
      id: 'cat-1',
      name: 'Category 1',
      isDeleted: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'cat-2',
      name: 'Category 2',
      isDeleted: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
  ];

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LogEntryFormComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(LogEntryFormComponent);
    component = fixture.componentInstance;
    component.categories = mockCategories;
    component.currentDate = '2024-02-15';
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('initialization', () => {
    it('should initialize add mode when no entry provided', () => {
      component.entry = null;
      fixture.detectChanges();
      expect(component.isEdit).toBe(false);
      expect(component.form.categoryId).toBe(mockCategories[0].id);
      expect(component.form.note).toBe('');
    });

    it('should initialize edit mode when entry provided', () => {
      const mockEntry: LogEntryWithCategory = {
        id: 'entry-1',
        categoryId: 'cat-2',
        note: 'Test note',
        date: '2024-02-15',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        isDeleted: false,
        category: mockCategories[1],
      };

      component.entry = mockEntry;
      fixture.detectChanges();

      expect(component.isEdit).toBe(true);
      expect(component.form.categoryId).toBe('cat-2');
      expect(component.form.note).toBe('Test note');
    });

    it('should set first category as default when no categories', () => {
      component.categories = [];
      component.entry = null;
      fixture.detectChanges();
      expect(component.form.categoryId).toBe('');
    });
  });

  describe('validation', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should validate required category', () => {
      component.form.categoryId = '';
      component.form.note = 'Valid note';
      const valid = component.validate();
      expect(valid).toBe(false);
      expect(component.errors).toContain('Category is required');
    });

    it('should validate required note', () => {
      component.form.categoryId = 'cat-1';
      component.form.note = '';
      const valid = component.validate();
      expect(valid).toBe(false);
      expect(component.errors).toContain('Note is required');
    });

    it('should trim whitespace from note', () => {
      component.form.categoryId = 'cat-1';
      component.form.note = '   ';
      const valid = component.validate();
      expect(valid).toBe(false);
    });

    it('should pass validation with valid data', () => {
      component.form.categoryId = 'cat-1';
      component.form.note = 'Valid note';
      const valid = component.validate();
      expect(valid).toBe(true);
      expect(component.errors.length).toBe(0);
    });
  });

  describe('form events', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should emit save event with valid data', (done) => {
      component.form.categoryId = 'cat-1';
      component.form.note = 'Test note';

      component.save.subscribe((data) => {
        expect(data.categoryId).toBe('cat-1');
        expect(data.note).toBe('Test note');
        done();
      });

      component.onSave();
    });

    it('should not emit save event with invalid data', (done) => {
      component.form.categoryId = '';
      component.form.note = '';

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

  describe('utility methods', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should get category name by id', () => {
      const name = component.getCategoryName('cat-1');
      expect(name).toBe('Category 1');
    });

    it('should return Unknown for invalid category id', () => {
      const name = component.getCategoryName('invalid-id');
      expect(name).toBe('Unknown');
    });
  });
});
