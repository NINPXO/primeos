export type SearchResultType = 'goal' | 'progress' | 'log' | 'note';

export interface SearchResult {
  type: SearchResultType;
  id: string;
  title: string;
  snippet: string;
  path: string;
  createdAt?: string;
}
