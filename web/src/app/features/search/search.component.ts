import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { MatInputModule } from '@angular/material/input';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { SearchService } from '../../core/services/search.service';
import { SearchResult } from '../../core/models';

@Component({
  selector: 'app-search',
  standalone: true,
  imports: [CommonModule, FormsModule, MatInputModule, MatListModule, MatIconModule],
  template: `
    <div class="search-container">
      <h1>Search</h1>
      <mat-form-field class="search-input">
        <input
          matInput
          placeholder="Search goals, progress, logs, and notes..."
          [(ngModel)]="searchQuery"
          (input)="onSearch()"
        />
      </mat-form-field>

      <div class="results">
        <mat-list *ngIf="results.length > 0">
          <mat-list-item *ngFor="let result of results" (click)="navigateToResult(result)">
            <mat-icon matListItemIcon>
              {{ getIcon(result.type) }}
            </mat-icon>
            <div matListItemTitle>{{ result.title }}</div>
            <div matListItemLine>{{ result.snippet | slice : 0 : 100 }}</div>
          </mat-list-item>
        </mat-list>
        <p *ngIf="searchQuery && results.length === 0" class="no-results">
          No results found
        </p>
      </div>
    </div>
  `,
  styles: [`
    .search-container {
      padding: 20px;

      .search-input {
        width: 100%;
        margin: 20px 0;
      }

      .results {
        margin-top: 20px;
      }

      .no-results {
        text-align: center;
        color: #999;
      }
    }
  `]
})
export class SearchComponent implements OnInit {
  searchQuery: string = '';
  results: SearchResult[] = [];

  constructor(private searchService: SearchService, private router: Router) {}

  ngOnInit(): void {}

  async onSearch(): Promise<void> {
    if (this.searchQuery.length < 2) {
      this.results = [];
      return;
    }
    this.results = await this.searchService.search(this.searchQuery);
  }

  getIcon(type: string): string {
    switch (type) {
      case 'goal':
        return 'target';
      case 'progress':
        return 'trending_up';
      case 'log':
        return 'today';
      case 'note':
        return 'note';
      default:
        return 'help';
    }
  }

  navigateToResult(result: SearchResult): void {
    this.router.navigate([result.path]);
  }
}
