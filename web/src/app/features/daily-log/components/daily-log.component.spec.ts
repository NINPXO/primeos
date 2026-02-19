import { ComponentFixture, TestBed } from '@angular/core/testing';
import { DailyLogComponent } from './daily-log.component';
import { DailyLogService } from '../services/daily-log.service';
import { DatabaseService } from '../../../core/services/database.service';
import { BehaviorSubject } from 'rxjs';

describe('DailyLogComponent', () => {
  let component: DailyLogComponent;
  let fixture: ComponentFixture<DailyLogComponent>;
  let service: DailyLogService;
  let db: DatabaseService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DailyLogComponent],
      providers: [DailyLogService, DatabaseService],
    }).compileComponents();

    fixture = TestBed.createComponent(DailyLogComponent);
    component = fixture.componentInstance;
    service = TestBed.inject(DailyLogService);
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

  it('should initialize with today date on init', () => {
    const today = service.getTodayDate();
    fixture.detectChanges();
    expect(component.currentDate).toBe(today);
  });

  describe('date navigation', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should go to previous day', () => {
      const original = component.currentDate;
      component.previousDay();
      const expected = service.getPreviousDate(original);
      expect(component.currentDate).toBe(expected);
    });

    it('should go to next day', () => {
      const original = component.currentDate;
      component.nextDay();
      const expected = service.getNextDate(original);
      expect(component.currentDate).toBe(expected);
    });

    it('should go to today', () => {
      component.currentDate = '2024-01-01';
      component.goToday();
      expect(component.currentDate).toBe(service.getTodayDate());
    });
  });

  describe('form management', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should open add form', () => {
      expect(component.isFormVisible).toBe(false);
      component.openAddForm();
      expect(component.isFormVisible).toBe(true);
      expect(component.selectedEntry).toBeNull();
    });

    it('should open edit form with entry', async () => {
      const entry: any = {
        id: 'test-id',
        categoryId: 'cat-1',
        note: 'test note',
        date: component.currentDate,
        createdAt: new Date().toISOString(),
        category: { id: 'cat-1', name: 'Test' },
      };

      component.openEditForm(entry);
      expect(component.isFormVisible).toBe(true);
      expect(component.selectedEntry).toBe(entry);
    });

    it('should close form', () => {
      component.isFormVisible = true;
      component.selectedEntry = {} as any;
      component.closeForm();
      expect(component.isFormVisible).toBe(false);
      expect(component.selectedEntry).toBeNull();
    });
  });

  describe('entry operations', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should add new entry through form', async () => {
      const formData = {
        categoryId: 'cat-location',
        note: 'New test entry',
      };

      await component.onFormSave(formData);
      expect(component.isFormVisible).toBe(false);

      const entries = await service.loadEntriesForDate(component.currentDate);
      expect(entries.length).toBe(1);
      expect(entries[0].note).toBe('New test entry');
    });

    it('should update existing entry through form', async () => {
      // Add initial entry
      const entry = await service.addEntry({
        categoryId: 'cat-location',
        note: 'Original note',
        date: component.currentDate,
      });

      component.selectedEntry = entry;
      component.openEditForm(entry);

      const formData = {
        categoryId: 'cat-location',
        note: 'Updated note',
      };

      await component.onFormSave(formData);

      const updated = await db.logEntries.get(entry.id);
      expect(updated?.note).toBe('Updated note');
    });

    it('should delete entry with confirmation', async () => {
      const entry = await service.addEntry({
        categoryId: 'cat-location',
        note: 'To delete',
        date: component.currentDate,
      });

      spyOn(window, 'confirm').and.returnValue(true);
      await component.deleteEntry(entry);

      const deleted = await db.logEntries.get(entry.id);
      expect(deleted?.isDeleted).toBe(true);
    });

    it('should not delete entry if confirmation cancelled', async () => {
      const entry = await service.addEntry({
        categoryId: 'cat-location',
        note: 'To delete',
        date: component.currentDate,
      });

      spyOn(window, 'confirm').and.returnValue(false);
      await component.deleteEntry(entry);

      const notDeleted = await db.logEntries.get(entry.id);
      expect(notDeleted?.isDeleted).toBe(false);
    });
  });

  describe('utility methods', () => {
    it('should format date correctly', () => {
      const formatted = component.formatDate('2024-02-15');
      expect(formatted).toContain('February');
      expect(formatted).toContain('15');
      expect(formatted).toContain('2024');
    });

    it('should get category by id', async () => {
      await component.loadData();
      const category = component.getCategoryById('cat-location');
      expect(category?.name).toBe('Location');
    });

    it('should get grouped entries', () => {
      const now = new Date().toISOString();
      const entries: any[] = [
        {
          id: '1',
          categoryId: 'cat-1',
          note: 'note1',
          category: { id: 'cat-1' },
          createdAt: now,
        },
        {
          id: '2',
          categoryId: 'cat-1',
          note: 'note2',
          category: { id: 'cat-1' },
          createdAt: now,
        },
        {
          id: '3',
          categoryId: 'cat-2',
          note: 'note3',
          category: { id: 'cat-2' },
          createdAt: now,
        },
      ];

      component.entries = entries;
      const grouped = component.getGroupedEntries();
      expect(grouped.size).toBe(2);
      expect(grouped.get('cat-1')?.length).toBe(2);
      expect(grouped.get('cat-2')?.length).toBe(1);
    });
  });
});
