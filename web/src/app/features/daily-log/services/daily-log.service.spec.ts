import { TestBed } from '@angular/core/testing';
import { DailyLogService } from './daily-log.service';
import { DatabaseService } from '../../../core/services/database.service';

describe('DailyLogService', () => {
  let service: DailyLogService;
  let db: DatabaseService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      providers: [DailyLogService, DatabaseService],
    }).compileComponents();

    service = TestBed.inject(DailyLogService);
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

  describe('loadCategories', () => {
    it('should load all non-deleted categories', async () => {
      const categories = await service.loadCategories();
      expect(categories.length).toBeGreaterThan(0);
      expect(categories.some((c) => c.name === 'Location')).toBe(true);
    });

    it('should filter out deleted categories', async () => {
      const now = new Date().toISOString();
      await db.logCategories.add({
        id: 'deleted-cat',
        name: 'Deleted Category',
        isDeleted: true,
        createdAt: now,
        updatedAt: now,
      });

      const categories = await service.loadCategories();
      expect(categories.some((c) => c.id === 'deleted-cat')).toBe(false);
    });
  });

  describe('loadEntriesForDate', () => {
    it('should load entries for a specific date', async () => {
      const today = service.getTodayDate();
      const now = new Date().toISOString();

      await db.logEntries.add({
        id: 'entry-1',
        categoryId: 'cat-location',
        note: 'Test entry',
        date: today,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      });

      const entries = await service.loadEntriesForDate(today);
      expect(entries.length).toBe(1);
      expect(entries[0].note).toBe('Test entry');
    });

    it('should filter out deleted entries', async () => {
      const today = service.getTodayDate();
      const now = new Date().toISOString();

      await db.logEntries.add({
        id: 'entry-deleted',
        categoryId: 'cat-location',
        note: 'Deleted entry',
        date: today,
        createdAt: now,
        updatedAt: now,
        isDeleted: true,
      });

      const entries = await service.loadEntriesForDate(today);
      expect(entries.some((e) => e.id === 'entry-deleted')).toBe(false);
    });

    it('should not load entries from different dates', async () => {
      const today = service.getTodayDate();
      const yesterday = service.getPreviousDate(today);
      const now = new Date().toISOString();

      await db.logEntries.add({
        id: 'entry-yesterday',
        categoryId: 'cat-location',
        note: 'Yesterday entry',
        date: yesterday,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      });

      const entries = await service.loadEntriesForDate(today);
      expect(entries.length).toBe(0);
    });
  });

  describe('addEntry', () => {
    it('should create a new log entry', async () => {
      const today = service.getTodayDate();
      const entry = await service.addEntry({
        categoryId: 'cat-location',
        note: 'New entry',
        date: today,
      });

      expect(entry.id).toBeTruthy();
      expect(entry.note).toBe('New entry');
      expect(entry.isDeleted).toBe(false);

      // Verify it's in the database
      const loaded = await db.logEntries.get(entry.id);
      expect(loaded).toBeTruthy();
    });

    it('should reload entries after adding', async () => {
      const today = service.getTodayDate();
      await service.addEntry({
        categoryId: 'cat-location',
        note: 'Test entry',
        date: today,
      });

      service.entries$.subscribe((entries) => {
        expect(entries.length).toBe(1);
      });
    });
  });

  describe('updateEntry', () => {
    it('should update an existing entry', async () => {
      const today = service.getTodayDate();
      const entry = await service.addEntry({
        categoryId: 'cat-location',
        note: 'Original note',
        date: today,
      });

      await service.updateEntry(entry.id, {
        note: 'Updated note',
      });

      const updated = await db.logEntries.get(entry.id);
      expect(updated?.note).toBe('Updated note');
    });

    it('should throw error if entry not found', async () => {
      try {
        await service.updateEntry('nonexistent-id', { note: 'test' });
        fail('Should have thrown error');
      } catch (error: any) {
        expect(error.message).toContain('not found');
      }
    });
  });

  describe('deleteEntry', () => {
    it('should soft delete an entry', async () => {
      const today = service.getTodayDate();
      const entry = await service.addEntry({
        categoryId: 'cat-location',
        note: 'To delete',
        date: today,
      });

      await service.deleteEntry(entry.id);

      const deleted = await db.logEntries.get(entry.id);
      expect(deleted?.isDeleted).toBe(true);
    });

    it('should throw error if entry not found', async () => {
      try {
        await service.deleteEntry('nonexistent-id');
        fail('Should have thrown error');
      } catch (error: any) {
        expect(error.message).toContain('not found');
      }
    });
  });

  describe('date utilities', () => {
    it('should get today date in correct format', () => {
      const today = service.getTodayDate();
      expect(today).toMatch(/\d{4}-\d{2}-\d{2}/);
    });

    it('should get previous date', () => {
      const date = '2024-02-15';
      const prev = service.getPreviousDate(date);
      expect(prev).toBe('2024-02-14');
    });

    it('should get next date', () => {
      const date = '2024-02-15';
      const next = service.getNextDate(date);
      expect(next).toBe('2024-02-16');
    });
  });

  describe('getGroupedEntries', () => {
    it('should group entries by category', () => {
      const now = new Date().toISOString();
      const entries: any[] = [
        {
          id: '1',
          categoryId: 'cat-1',
          note: 'note1',
          category: { id: 'cat-1', name: 'Category 1' },
          createdAt: now,
        },
        {
          id: '2',
          categoryId: 'cat-1',
          note: 'note2',
          category: { id: 'cat-1', name: 'Category 1' },
          createdAt: now,
        },
        {
          id: '3',
          categoryId: 'cat-2',
          note: 'note3',
          category: { id: 'cat-2', name: 'Category 2' },
          createdAt: now,
        },
      ];

      const grouped = service.getGroupedEntries(entries);
      expect(grouped.size).toBe(2);
      expect(grouped.get('cat-1')?.length).toBe(2);
      expect(grouped.get('cat-2')?.length).toBe(1);
    });
  });
});
