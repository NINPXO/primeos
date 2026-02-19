import { TestBed } from '@angular/core/testing';
import { GoalsService } from './goals.service';
import { db } from '../database/app-database';
import { Goal, GoalCategory } from '../models';

describe('GoalsService', () => {
  let service: GoalsService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      providers: [GoalsService]
    }).compileComponents();

    service = TestBed.inject(GoalsService);
    // Clear database before each test
    await db.goals.clear();
    await db.goalCategories.clear();
  });

  afterEach(async () => {
    await db.goals.clear();
    await db.goalCategories.clear();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  describe('loadGoals', () => {
    it('should load all non-deleted goals', async () => {
      const goal: Omit<Goal, 'id' | 'createdAt' | 'updatedAt' | 'isDeleted' | 'deletedAt'> = {
        title: 'Test Goal',
        description: 'A test goal',
        categoryId: 'cat-learning',
        targetDate: '2025-12-31',
        status: 'active'
      };

      const createdGoal = await service.addGoal(goal);
      expect(createdGoal).toBeTruthy();
      expect(createdGoal.id).toBeTruthy();
      expect(createdGoal.isDeleted).toBeFalse();
    });
  });

  describe('addGoal', () => {
    it('should add a new goal', async () => {
      const goal: Omit<Goal, 'id' | 'createdAt' | 'updatedAt' | 'isDeleted' | 'deletedAt'> = {
        title: 'Learn Angular',
        description: 'Master Angular framework',
        categoryId: 'cat-learning',
        targetDate: '2025-12-31',
        status: 'active'
      };

      const result = await service.addGoal(goal);
      expect(result.title).toBe('Learn Angular');
      expect(result.status).toBe('active');
      expect(result.createdAt).toBeTruthy();
    });

    it('should generate unique ids', async () => {
      const goal1 = await service.addGoal({
        title: 'Goal 1',
        description: '',
        categoryId: 'cat-learning',
        targetDate: '2025-12-31',
        status: 'active'
      });

      const goal2 = await service.addGoal({
        title: 'Goal 2',
        description: '',
        categoryId: 'cat-learning',
        targetDate: '2025-12-31',
        status: 'active'
      });

      expect(goal1.id).not.toBe(goal2.id);
    });
  });

  describe('updateGoal', () => {
    it('should update a goal', async () => {
      const goal = await service.addGoal({
        title: 'Original Title',
        description: 'Original description',
        categoryId: 'cat-learning',
        targetDate: '2025-12-31',
        status: 'active'
      });

      const updated = await service.updateGoal(goal.id, {
        title: 'Updated Title',
        status: 'completed'
      });

      expect(updated.title).toBe('Updated Title');
      expect(updated.status).toBe('completed');
      expect(updated.description).toBe('Original description');
    });

    it('should throw error for non-existent goal', async () => {
      try {
        await service.updateGoal('non-existent-id', { title: 'New Title' });
        fail('Should have thrown error');
      } catch (error: any) {
        expect(error.message).toContain('not found');
      }
    });
  });

  describe('deleteGoal', () => {
    it('should soft delete a goal', async () => {
      const goal = await service.addGoal({
        title: 'Goal to Delete',
        description: '',
        categoryId: 'cat-learning',
        targetDate: '2025-12-31',
        status: 'active'
      });

      await service.deleteGoal(goal.id);

      const goals = await db.goals.toArray();
      const deletedGoal = goals.find(g => g.id === goal.id);
      expect(deletedGoal?.isDeleted).toBeTrue();
      expect(deletedGoal?.deletedAt).toBeTruthy();
    });

    it('should hard delete a goal', async () => {
      const goal = await service.addGoal({
        title: 'Goal to Delete',
        description: '',
        categoryId: 'cat-learning',
        targetDate: '2025-12-31',
        status: 'active'
      });

      await service.deleteGoal(goal.id, false);

      const remaining = await db.goals.get(goal.id);
      expect(remaining).toBeUndefined();
    });
  });

  describe('restoreGoal', () => {
    it('should restore a soft-deleted goal', async () => {
      const goal = await service.addGoal({
        title: 'Goal to Restore',
        description: '',
        categoryId: 'cat-learning',
        targetDate: '2025-12-31',
        status: 'active'
      });

      await service.deleteGoal(goal.id);
      await service.restoreGoal(goal.id);

      const restored = await db.goals.get(goal.id);
      expect(restored?.isDeleted).toBeFalse();
      expect(restored?.deletedAt).toBeUndefined();
    });
  });

  describe('Categories', () => {
    it('should initialize default categories', async () => {
      const categories = await db.goalCategories.toArray();
      expect(categories.length).toBeGreaterThan(0);
      expect(categories.some(c => c.name === 'Learning')).toBeTrue();
    });

    it('should add a custom category', async () => {
      const newCategory = await service.addCategory({
        name: 'Custom Category',
        color: '#FF0000'
      });

      expect(newCategory.id).toBeTruthy();
      expect(newCategory.isSystem).toBeFalse();
    });

    it('should not allow deleting system categories', async () => {
      const categories = await db.goalCategories.toArray();
      const systemCategory = categories.find(c => c.isSystem);

      if (systemCategory) {
        try {
          await service.deleteCategory(systemCategory.id);
          fail('Should have thrown error');
        } catch (error: any) {
          expect(error.message).toContain('Cannot delete system categories');
        }
      }
    });

    it('should delete custom categories', async () => {
      const category = await service.addCategory({
        name: 'Temp Category',
        color: '#00FF00'
      });

      await service.deleteCategory(category.id);
      const deleted = await db.goalCategories.get(category.id);
      expect(deleted).toBeUndefined();
    });
  });
});
