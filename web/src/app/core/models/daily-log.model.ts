export interface DailyLogCategory {
  id: string;
  name: string;
  isFixed: boolean;
  isDeleted: boolean;
  createdAt: string;
  updatedAt?: string;
}

export interface DailyLogEntry {
  id: string;
  logDate: string; // ISO date string
  categoryId: string;
  note?: string;
  isDeleted: boolean;
  createdAt: string;
  updatedAt?: string;
}

export const DEFAULT_LOG_CATEGORIES: DailyLogCategory[] = [
  {
    id: 'cat-location',
    name: 'Location',
    isFixed: true,
    isDeleted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: 'cat-mobile-usage',
    name: 'Mobile Usage',
    isFixed: true,
    isDeleted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: 'cat-app-usage',
    name: 'App Usage',
    isFixed: true,
    isDeleted: false,
    createdAt: new Date().toISOString()
  }
];
