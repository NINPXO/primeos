import { Injectable } from '@angular/core';
import { db } from '../database/app-database';
import { AppSettings, DEFAULT_SETTINGS } from '../models';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SettingsService {
  private settings$ = new BehaviorSubject<AppSettings[]>([]);

  constructor() {
    this.loadSettings();
  }

  async loadSettings(): Promise<void> {
    try {
      const settings = await db.appSettings.toArray();
      if (settings.length === 0) {
        await db.appSettings.bulkAdd(DEFAULT_SETTINGS);
        const loaded = await db.appSettings.toArray();
        this.settings$.next(loaded);
      } else {
        this.settings$.next(settings);
      }
    } catch (error) {
      console.error('Error loading settings:', error);
    }
  }

  getSettings(): Observable<AppSettings[]> {
    return this.settings$.asObservable();
  }

  async getSetting(key: string): Promise<AppSettings | undefined> {
    try {
      return await db.appSettings.get(key);
    } catch (error) {
      console.error('Error getting setting:', error);
      return undefined;
    }
  }

  async updateSetting(key: string, value: string): Promise<AppSettings> {
    const now = new Date().toISOString();
    const setting: AppSettings = {
      key,
      value,
      updatedAt: now
    };

    const existing = await db.appSettings.get(key);
    if (existing) {
      await db.appSettings.update(key, setting);
    } else {
      setting.createdAt = now;
      await db.appSettings.add(setting);
    }

    await this.loadSettings();
    return setting;
  }

  async getThemeMode(): Promise<string> {
    const setting = await this.getSetting('theme_mode');
    return setting?.value || 'system';
  }

  async setThemeMode(mode: 'light' | 'dark' | 'system'): Promise<void> {
    await this.updateSetting('theme_mode', mode);
  }
}
