import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatBottomNavigationModule } from '@angular/material/bottom-nav';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { SettingsService } from '../../../core/services/settings.service';

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    MatToolbarModule,
    MatBottomNavigationModule,
    MatIconModule,
    MatButtonModule,
    MatMenuModule
  ],
  templateUrl: './app-shell.component.html',
  styleUrls: ['./app-shell.component.scss']
})
export class AppShellComponent implements OnInit {
  currentTheme: 'light' | 'dark' | 'system' = 'system';

  constructor(
    private settingsService: SettingsService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadTheme();
  }

  private async loadTheme(): Promise<void> {
    this.currentTheme = (await this.settingsService.getThemeMode()) as any;
  }

  toggleTheme(): void {
    const themes: ('light' | 'dark' | 'system')[] = ['light', 'dark', 'system'];
    const currentIndex = themes.indexOf(this.currentTheme);
    const nextTheme = themes[(currentIndex + 1) % themes.length];
    this.currentTheme = nextTheme;
    this.settingsService.setThemeMode(nextTheme);
    this.applyTheme(nextTheme);
  }

  openSettings(): void {
    this.router.navigate(['/settings']);
  }

  openSearch(): void {
    this.router.navigate(['/search']);
  }

  private applyTheme(theme: 'light' | 'dark' | 'system'): void {
    const html = document.documentElement;
    if (theme === 'system') {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      html.setAttribute('data-theme', prefersDark ? 'dark' : 'light');
    } else {
      html.setAttribute('data-theme', theme);
    }
  }
}
