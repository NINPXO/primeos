import Dexie, { type Table } from 'dexie';
import {
  Goal,
  ProgressEntry,
  GoalCategory,
  AppSettings,
  DailyLogCategory,
  DailyLogEntry,
  NoteTag,
  Note,
  NoteTagJunction,
  DEFAULT_GOAL_CATEGORIES,
  DEFAULT_LOG_CATEGORIES,
  DEFAULT_SETTINGS
} from '../models';

export interface GoalRecord extends Goal {
  id: string;
  createdAt: string;
  updatedAt: string;
  isDeleted: boolean;
  deletedAt?: string;
}

export interface ProgressRecord extends ProgressEntry {
  id: string;
  createdAt: string;
  updatedAt: string;
  isDeleted: boolean;
  deletedAt?: string;
}

export interface GoalCategoryRecord extends GoalCategory {
  id: string;
  createdAt: string;
  isSystem: boolean;
}

export interface AppSettingsRecord extends AppSettings {
  key: string;
  value: string;
}

export interface DailyLogCategoryRecord extends DailyLogCategory {
  id: string;
}

export interface DailyLogEntryRecord extends DailyLogEntry {
  id: string;
}

export interface NoteTagRecord extends NoteTag {
  id: string;
}

export interface NoteRecord extends Note {
  id: string;
}

export interface NoteTagJunctionRecord extends NoteTagJunction {
  noteId: string;
  tagId: string;
}

export class AppDatabase extends Dexie {
  appSettings!: Table<AppSettingsRecord>;
  goalCategories!: Table<GoalCategoryRecord>;
  goals!: Table<GoalRecord>;
  progressEntries!: Table<ProgressRecord>;
  dailyLogCategories!: Table<DailyLogCategoryRecord>;
  dailyLogEntries!: Table<DailyLogEntryRecord>;
  noteTags!: Table<NoteTagRecord>;
  notes!: Table<NoteRecord>;
  notesTagsJunction!: Table<NoteTagJunctionRecord>;

  constructor() {
    super('PrimeOS');
    this.version(1).stores({
      appSettings: 'key',
      goalCategories: 'id, name, isSystem, isDeleted',
      goals: 'id, categoryId, status, isDeleted, targetDate',
      progressEntries: 'id, goalId, categoryId, loggedDate, trackingPeriod, isDeleted',
      dailyLogCategories: 'id, name, isFixed, isDeleted',
      dailyLogEntries: 'id, logDate, categoryId, isDeleted',
      noteTags: 'id, name, isDeleted',
      notes: 'id, isArchived, isDeleted',
      notesTagsJunction: '[noteId+tagId], noteId, tagId'
    });

    // Seed default data
    this.on('ready', () => this.seedData());
  }

  private async seedData() {
    const settingsCount = await this.appSettings.count();
    if (settingsCount === 0) {
      await this.appSettings.bulkAdd(DEFAULT_SETTINGS);
    }

    const categoriesCount = await this.goalCategories.count();
    if (categoriesCount === 0) {
      await this.goalCategories.bulkAdd(DEFAULT_GOAL_CATEGORIES);
    }

    const logCategoriesCount = await this.dailyLogCategories.count();
    if (logCategoriesCount === 0) {
      await this.dailyLogCategories.bulkAdd(DEFAULT_LOG_CATEGORIES);
    }
  }
}

export const db = new AppDatabase();
