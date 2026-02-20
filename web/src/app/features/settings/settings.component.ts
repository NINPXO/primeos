import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { SettingsService } from '../../core/services/settings.service';
import { CsvExportService } from '../../core/services/csv-export.service';
import { CsvImportService } from '../../core/services/csv-import.service';
import { ZipExportService } from '../../core/services/zip-export.service';
import { ZipImportService } from '../../core/services/zip-import.service';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatCardModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatSnackBarModule
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
    private zipExportService: ZipExportService,
    private snackBar: MatSnackBar
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
      const fileSizeKB = (blob.size / 1024).toFixed(2);
      this.zipExportService.downloadExport(blob);
      this.snackBar.open(`✓ All data exported successfully (${fileSizeKB}KB)`, 'Close', {
        duration: 3000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['success-snackbar']
      });
    } catch (error) {
      console.error('Export failed:', error);
      this.snackBar.open('✗ Export failed. See console for details.', 'Close', {
        duration: 3000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['error-snackbar']
      });
    }
  }

  importData(): void {
    alert('Import functionality to be implemented');
  }

  async exportGoalsCSV(): Promise<void> {
    try {
      const csv = await this.csvExportService.exportGoals();
      const lines = csv.split('\n').filter(line => line.trim().length > 0).length;
      this.downloadCSV(csv, 'goals.csv');
      const fileSizeKB = (new Blob([csv]).size / 1024).toFixed(2);
      this.snackBar.open(`✓ Goals exported (${lines} rows, ${fileSizeKB}KB)`, 'Close', {
        duration: 3000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['success-snackbar']
      });
    } catch (error) {
      console.error('Export failed:', error);
      this.snackBar.open('✗ Goals export failed', 'Close', {
        duration: 3000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['error-snackbar']
      });
    }
  }

  async exportProgressCSV(): Promise<void> {
    try {
      const csv = await this.csvExportService.exportProgress();
      const lines = csv.split('\n').filter(line => line.trim().length > 0).length;
      this.downloadCSV(csv, 'progress.csv');
      const fileSizeKB = (new Blob([csv]).size / 1024).toFixed(2);
      this.snackBar.open(`✓ Progress exported (${lines} rows, ${fileSizeKB}KB)`, 'Close', {
        duration: 3000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['success-snackbar']
      });
    } catch (error) {
      console.error('Export failed:', error);
      this.snackBar.open('✗ Progress export failed', 'Close', {
        duration: 3000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['error-snackbar']
      });
    }
  }

  async exportNotesCSV(): Promise<void> {
    try {
      const csv = await this.csvExportService.exportNotes();
      const lines = csv.split('\n').filter(line => line.trim().length > 0).length;
      this.downloadCSV(csv, 'notes.csv');
      const fileSizeKB = (new Blob([csv]).size / 1024).toFixed(2);
      this.snackBar.open(`✓ Notes exported (${lines} rows, ${fileSizeKB}KB)`, 'Close', {
        duration: 3000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['success-snackbar']
      });
    } catch (error) {
      console.error('Export failed:', error);
      this.snackBar.open('✗ Notes export failed', 'Close', {
        duration: 3000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['error-snackbar']
      });
    }
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
