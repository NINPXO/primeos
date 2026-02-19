export interface ProgressEntry {
  id: string;
  goalId: string;
  value: number;
  date: string; // ISO date string
  note?: string;
  createdAt: string;
  updatedAt: string;
  isDeleted: boolean;
  deletedAt?: string;
}
