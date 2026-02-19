export interface Goal {
  id: string;
  title: string;
  description: string;
  categoryId: string;
  targetDate: string; // ISO date string
  status: 'active' | 'completed' | 'on-hold';
  createdAt: string;
  updatedAt: string;
  isDeleted: boolean;
  deletedAt?: string;
}

export interface GoalCategory {
  id: string;
  name: string;
  color: string; // hex color
  createdAt: string;
  isSystem: boolean;
}

export const DEFAULT_GOAL_CATEGORIES: GoalCategory[] = [
  {
    id: 'cat-learning',
    name: 'Learning',
    color: '#2196F3',
    createdAt: new Date().toISOString(),
    isSystem: true
  },
  {
    id: 'cat-fitness',
    name: 'Fitness',
    color: '#FF9800',
    createdAt: new Date().toISOString(),
    isSystem: true
  },
  {
    id: 'cat-nutrition',
    name: 'Nutrition',
    color: '#4CAF50',
    createdAt: new Date().toISOString(),
    isSystem: true
  },
  {
    id: 'cat-general',
    name: 'General',
    color: '#9C27B0',
    createdAt: new Date().toISOString(),
    isSystem: true
  }
];
