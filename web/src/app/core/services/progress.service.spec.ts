import { TestBed } from '@angular/core/testing';
import { ProgressService } from './progress.service';
import { db } from '../database/app-database';
import { ProgressEntry } from '../models';

describe('ProgressService', () => {
  let service: ProgressService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      providers: [ProgressService]
    }).compileComponents();

    service = TestBed.inject(ProgressService);
    await db.progressEntries.clear();
  });

  afterEach(async () => {
    await db.progressEntries.clear();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  describe('addEntry', () => {
    it('should add a new progress entry', async () => {
      const entry: Omit<ProgressEntry, 'id' | 'createdAt' | 'updatedAt' | 'isDeleted' | 'deletedAt'> = {
        goalId: 'goal-1',
        value: 10,
        date: new Date().toISOString(),
        note: 'Great progress!'
      };

      const result = await service.addEntry(entry);
      expect(result.id).toBeTruthy();
      expect(result.value).toBe(10);
      expect(result.goalId).toBe('goal-1');
    });

    it('should set isDeleted to false', async () => {
      const entry = await service.addEntry({
        goalId: 'goal-1',
        value: 5,
        date: new Date().toISOString()
      });

      expect(entry.isDeleted).toBeFalse();
    });
  });

  describe('getProgressByGoal', () => {
    it('should return progress entries for a specific goal', async () => {
      await service.addEntry({
        goalId: 'goal-1',
        value: 10,
        date: new Date().toISOString()
      });

      await service.addEntry({
        goalId: 'goal-1',
        value: 15,
        date: new Date().toISOString()
      });

      await service.addEntry({
        goalId: 'goal-2',
        value: 20,
        date: new Date().toISOString()
      });

      const entries = await service.getProgressByGoal('goal-1');
      expect(entries.length).toBe(2);
      expect(entries.every(e => e.goalId === 'goal-1')).toBeTrue();
    });

    it('should return entries sorted by date descending', async () => {
      const now = new Date();
      const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);

      await service.addEntry({
        goalId: 'goal-1',
        value: 10,
        date: yesterday.toISOString()
      });

      await service.addEntry({
        goalId: 'goal-1',
        value: 20,
        date: now.toISOString()
      });

      const entries = await service.getProgressByGoal('goal-1');
      expect(entries[0].value).toBe(20);
      expect(entries[1].value).toBe(10);
    });
  });

  describe('updateEntry', () => {
    it('should update a progress entry', async () => {
      const entry = await service.addEntry({
        goalId: 'goal-1',
        value: 10,
        date: new Date().toISOString()
      });

      const updated = await service.updateEntry(entry.id, {
        value: 20,
        note: 'Updated note'
      });

      expect(updated.value).toBe(20);
      expect(updated.note).toBe('Updated note');
      expect(updated.goalId).toBe('goal-1');
    });

    it('should throw error for non-existent entry', async () => {
      try {
        await service.updateEntry('non-existent-id', { value: 100 });
        fail('Should have thrown error');
      } catch (error: any) {
        expect(error.message).toContain('not found');
      }
    });
  });

  describe('deleteEntry', () => {
    it('should soft delete an entry', async () => {
      const entry = await service.addEntry({
        goalId: 'goal-1',
        value: 10,
        date: new Date().toISOString()
      });

      await service.deleteEntry(entry.id);

      const deleted = await db.progressEntries.get(entry.id);
      expect(deleted?.isDeleted).toBeTrue();
      expect(deleted?.deletedAt).toBeTruthy();
    });

    it('should hard delete an entry', async () => {
      const entry = await service.addEntry({
        goalId: 'goal-1',
        value: 10,
        date: new Date().toISOString()
      });

      await service.deleteEntry(entry.id, false);

      const remaining = await db.progressEntries.get(entry.id);
      expect(remaining).toBeUndefined();
    });
  });

  describe('restoreEntry', () => {
    it('should restore a soft-deleted entry', async () => {
      const entry = await service.addEntry({
        goalId: 'goal-1',
        value: 10,
        date: new Date().toISOString()
      });

      await service.deleteEntry(entry.id);
      await service.restoreEntry(entry.id);

      const restored = await db.progressEntries.get(entry.id);
      expect(restored?.isDeleted).toBeFalse();
      expect(restored?.deletedAt).toBeUndefined();
    });
  });
});
