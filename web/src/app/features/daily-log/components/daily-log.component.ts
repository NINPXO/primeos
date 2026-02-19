import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { DailyLogService } from '../services/daily-log.service';
import {
  LogEntryWithCategory,
  LogCategory,
  DailyLogViewData,
} from '../../../shared/models';
import { LogEntryFormComponent } from './log-entry-form.component';

/**
 * Daily Log Component
 * Displays log entries for a selected date with date navigation
 */
@Component({
  selector: 'app-daily-log',
  standalone: true,
  imports: [
    CommonModule,
    MatButtonModule,
    MatCardModule,
    MatIconModule,
    MatDividerModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatInputModule,
    MatFormFieldModule,
    LogEntryFormComponent,
  ],
  templateUrl: './daily-log.component.html',
  styleUrl: './daily-log.component.scss',
})
export class DailyLogComponent implements OnInit {
  currentDate: string = '';
  entries: LogEntryWithCategory[] = [];
  categories: LogCategory[] = [];
  viewData: DailyLogViewData | null = null;
  isFormVisible = false;
  selectedEntry: LogEntryWithCategory | null = null;

  constructor(private dailyLogService: DailyLogService) {}

  ngOnInit(): void {
    this.currentDate = this.dailyLogService.getTodayDate();
    this.loadData();

    // Subscribe to changes
    this.dailyLogService.entries$.subscribe((entries) => {
      this.entries = entries;
      this.updateViewData();
    });

    this.dailyLogService.categories$.subscribe((categories) => {
      this.categories = categories;
    });
  }

  /**
   * Load data for current date
   */
  async loadData(): Promise<void> {
    this.viewData = await this.dailyLogService.getViewData(this.currentDate);
  }

  /**
   * Navigate to previous day
   */
  previousDay(): void {
    this.currentDate = this.dailyLogService.getPreviousDate(this.currentDate);
    this.loadData();
  }

  /**
   * Navigate to next day
   */
  nextDay(): void {
    this.currentDate = this.dailyLogService.getNextDate(this.currentDate);
    this.loadData();
  }

  /**
   * Navigate to today
   */
  goToday(): void {
    this.currentDate = this.dailyLogService.getTodayDate();
    this.loadData();
  }

  /**
   * Open add entry form
   */
  openAddForm(): void {
    this.selectedEntry = null;
    this.isFormVisible = true;
  }

  /**
   * Open edit form for entry
   */
  openEditForm(entry: LogEntryWithCategory): void {
    this.selectedEntry = entry;
    this.isFormVisible = true;
  }

  /**
   * Close form
   */
  closeForm(): void {
    this.isFormVisible = false;
    this.selectedEntry = null;
  }

  /**
   * Handle form save
   */
  async onFormSave(data: any): Promise<void> {
    try {
      if (this.selectedEntry) {
        // Update
        await this.dailyLogService.updateEntry(this.selectedEntry.id, {
          categoryId: data.categoryId,
          note: data.note,
        });
      } else {
        // Create
        await this.dailyLogService.addEntry({
          categoryId: data.categoryId,
          note: data.note,
          date: this.currentDate,
        });
      }
      this.closeForm();
    } catch (error) {
      console.error('Error saving entry:', error);
    }
  }

  /**
   * Delete entry
   */
  async deleteEntry(entry: LogEntryWithCategory): Promise<void> {
    if (confirm('Are you sure you want to delete this entry?')) {
      try {
        await this.dailyLogService.deleteEntry(entry.id);
      } catch (error) {
        console.error('Error deleting entry:', error);
      }
    }
  }

  /**
   * Format date for display
   */
  formatDate(date: string): string {
    const d = new Date(date + 'T00:00:00Z');
    return d.toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  }

  /**
   * Get category by id
   */
  getCategoryById(categoryId: string): LogCategory | undefined {
    return this.categories.find((c) => c.id === categoryId);
  }

  /**
   * Update view data from current entries
   */
  private updateViewData(): void {
    if (this.viewData) {
      this.viewData.entries = this.entries;
      this.viewData.groupedByCategory =
        this.dailyLogService.getGroupedEntries(this.entries);
    }
  }

  /**
   * Get grouped entries
   */
  getGroupedEntries(): Map<string, LogEntryWithCategory[]> {
    return this.viewData?.groupedByCategory || new Map();
  }

  /**
   * Get category ids in order
   */
  getCategoryIds(): string[] {
    return Array.from(this.getGroupedEntries().keys());
  }
}
