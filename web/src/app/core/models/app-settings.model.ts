export interface AppSettings {
  key: string;
  value: string;
  createdAt?: string;
  updatedAt?: string;
}

export const DEFAULT_SETTINGS: AppSettings[] = [
  {
    key: 'theme_mode',
    value: 'system',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];
