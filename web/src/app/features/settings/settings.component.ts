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
    MatSnackBarModule,
    MatProgressSpinnerModule
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
            <button mat-raised-button color="primary" (click)="exportAllData()" [disabled]="isImporting">
              <mat-icon>download</mat-icon>
              Export All Data (ZIP)
            </button>
            <button mat-raised-button (click)="fileInput.click()" [disabled]="isImporting">
              <mat-icon *ngIf="!isImporting">upload</mat-icon>
              <mat-spinner *ngIf="isImporting" diameter="20" class="import-spinner"></mat-spinner>
              {{ isImporting ? 'Importing...' : 'Import Data' }}
            </button>
            <input #fileInput type="file" hidden accept=".zip,.json" (change)="onFileSelected($event)">
          </div>

          <div *ngIf="importError" class="import-error">
            {{ importError }}
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
          position: relative;
        }

        button[disabled] {
          opacity: 0.6;
          cursor: not-allowed;
        }
      }

      .import-error {
        color: #d32f2f;
        background-color: #ffebee;
        padding: 12px;
        border-radius: 4px;
        margin-top: 12px;
        font-size: 14px;
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

      .import-spinner {
        display: inline-block;
        margin-right: 8px;
      }
    }
  `]
})
export class SettingsComponent implements OnInit {
  themeMode: 'light' | 'dark' | 'system' = 'system';
  isImporting = false;
  importError: string | null = null;

  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  constructor(
    private settingsService: SettingsService,
    private csvExportService: CsvExportService,
    private csvImportService: CsvImportService,
    private zipExportService: ZipExportService,
    private zipImportService: ZipImportService,
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

  onFileSelected(event: Event): void {
    const file = (event.target as HTMLInputElement).files?.[0];
    if (file) {
      this.importFile(file);
    }
    // Reset the input so the same file can be selected again
    (event.target as HTMLInputElement).value = '';
  }

  private async importFile(file: File): Promise<void> {
    try {
      this.isImporting = true;
      this.importError = null;

      const result = await this.zipImportService.importFromFile(file);

      if (!result.ok) {
        this.importError = result.error || 'Import failed';
        this.snackBar.open('✗ ' + (result.error || 'Import failed'), 'Close', {
          duration: 5000,
          horizontalPosition: 'end',
          verticalPosition: 'bottom',
          panelClass: ['error-snackbar']
        });
        return;
      }

      const data = result.data;
      const totalCount = (data?.goalsCount || 0) +
        (data?.progressEntriesCount || 0) +
        (data?.goalCategoriesCount || 0) +
        (data?.dailyLogCategoriesCount || 0) +
        (data?.dailyLogEntriesCount || 0) +
        (data?.noteTagsCount || 0) +
        (data?.notesCount || 0) +
        (data?.appSettingsCount || 0);

      const summary = [
        data?.goalsCount && `${data.goalsCount} goal(s)`,
        data?.progressEntriesCount && `${data.progressEntriesCount} progress entry(ies)`,
        data?.goalCategoriesCount && `${data.goalCategoriesCount} category(ies)`,
        data?.dailyLogEntriesCount && `${data.dailyLogEntriesCount} log entry(ies)`,
        data?.notesCount && `${data.notesCount} note(s)`
      ].filter(Boolean).join(', ');

      this.snackBar.open(`✓ Data imported successfully (${totalCount} records: ${summary})`, 'Close', {
        duration: 5000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['success-snackbar']
      });
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      this.importError = errorMsg;
      this.snackBar.open('✗ Import failed: ' + errorMsg, 'Close', {
        duration: 5000,
        horizontalPosition: 'end',
        verticalPosition: 'bottom',
        panelClass: ['error-snackbar']
      });
      console.error('Import error:', error);
    } finally {
      this.isImporting = false;
    }
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
