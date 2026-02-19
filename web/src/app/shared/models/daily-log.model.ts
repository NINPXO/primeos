/**
 * Daily Log Domain Models
 * Represents log entries and their categories
 */

export interface LogCategory {
  id: string;
  name: string;
  description?: string;
  color?: string;
  isDeleted: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface LogEntry {
  id: string;
  categoryId: string;
  note: string;
  date: string; // ISO-8601 format (YYYY-MM-DD)
  createdAt: string;
  updatedAt: string;
  isDeleted: boolean;
}

export interface LogEntryWithCategory extends LogEntry {
  category: LogCategory;
}

export interface DailyLogViewData {
  date: string;
  entries: LogEntryWithCategory[];
  groupedByCategory: Map<string, LogEntryWithCategory[]>;
}

export interface CreateLogEntryRequest {
  categoryId: string;
  note: string;
  date: string;
}

export interface UpdateLogEntryRequest {
  categoryId?: string;
  note?: string;
}
