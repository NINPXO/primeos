import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { SettingsService } from '../../core/services/settings.service';
import { CsvExportService } from '../../core/services/csv-export.service';
import { CsvImportService } from '../../core/services/csv-import.service';
import { ZipExportService } from '../../core/services/zip-export.service';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatCardModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule
  ],
  template: `
    <div class="settings-container">
      <h1>Settings</h1>

      <mat-card class="settings-section">
        <mat-card-header>
          <mat-card-title>Theme</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <mat-form-field>
            <mat-label>Theme Mode</mat-label>
            <mat-select [(ngModel)]="themeMode" (selectionChange)="onThemeChange()">
              <mat-option value="light">Light</mat-option>
              <mat-option value="dark">Dark</mat-option>
              <mat-option value="system">System</mat-option>
            </mat-select>
          </mat-form-field>
        </mat-card-content>
      </mat-card>

      <mat-card class="settings-section">
        <mat-card-header>
          <mat-card-title>Data Export/Import</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <div class="button-group">
            <button mat-raised-button color="primary" (click)="exportAllData()">
              <mat-icon>download</mat-icon>
              Export All Data (ZIP)
            </button>
            <button mat-raised-button (click)="importData()">
              <mat-icon>upload</mat-icon>
              Import Data
            </button>
          </div>

          <div class="csv-buttons">
            <h3>CSV Export</h3>
            <button mat-stroked-button (click)="exportGoalsCSV()">
              Export Goals
            </button>
            <button mat-stroked-button (click)="exportProgressCSV()">
              Export Progress
            </button>
            <button mat-stroked-button (click)="exportNotesCSV()">
              Export Notes
            </button>
          </div>
        </mat-card-content>
      </mat-card>

      <mat-card class="settings-section">
        <mat-card-header>
          <mat-card-title>About</mat-card-title>
        </mat-card-header>
        <mat-card-content>
          <p>PrimeOS v1.0.0</p>
          <p>A personal operating system for goals, progress tracking, daily logs, and notes.</p>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .settings-container {
      padding: 20px;
      max-width: 600px;

      h1 {
        margin-bottom: 20px;
      }

      .settings-section {
        margin-bottom: 20px;
      }

      .button-group {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;

        button {
          flex: 1;
          min-width: 150px;
        }
      }

      .csv-buttons {
        margin-top: 20px;

        h3 {
          margin-bottom: 10px;
        }

        button {
          display: block;
          margin-bottom: 10px;
        }
      }
    }
  `]
})
export class SettingsComponent implements OnInit {
  themeMode: 'light' | 'dark' | 'system' = 'system';

  constructor(
    private settingsService: SettingsService,
    private csvExportService: CsvExportService,
    private csvImportService: CsvImportService,
    private zipExportService: ZipExportService
  ) {}

  ngOnInit(): void {
    this.loadThemeMode();
  }

  private async loadThemeMode(): Promise<void> {
    this.themeMode = (await this.settingsService.getThemeMode()) as any;
  }

  async onThemeChange(): Promise<void> {
    await this.settingsService.setThemeMode(this.themeMode);
  }

  async exportAllData(): Promise<void> {
    try {
      const blob = await this.zipExportService.exportAll();
      this.zipExportService.downloadExport(blob);
    } catch (error) {
      console.error('Export failed:', error);
      alert('Export failed. See console for details.');
    }
  }

  importData(): void {
    alert('Import functionality to be implemented');
  }

  async exportGoalsCSV(): Promise<void> {
    const csv = await this.csvExportService.exportGoals();
    this.downloadCSV(csv, 'goals.csv');
  }

  async exportProgressCSV(): Promise<void> {
    const csv = await this.csvExportService.exportProgress();
    this.downloadCSV(csv, 'progress.csv');
  }

  async exportNotesCSV(): Promise<void> {
    const csv = await this.csvExportService.exportNotes();
    this.downloadCSV(csv, 'notes.csv');
  }

  private downloadCSV(csv: string, filename: string): void {
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  }
}
