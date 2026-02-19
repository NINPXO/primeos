/**
 * Notes Domain Models
 * Represents notes with rich-text content and tags
 */

export interface Note {
  id: string;
  title: string;
  richContent: any; // Quill Delta JSON
  isArchived: boolean;
  isDeleted: boolean;
  createdAt: string;
  updatedAt: string;
  tags?: Tag[];
}

export interface Tag {
  id: string;
  name: string;
  color?: string;
  createdAt: string;
  updatedAt: string;
}

export interface NoteTag {
  noteId: string;
  tagId: string;
}

export interface NoteWithTags extends Note {
  tags: Tag[];
}

export interface CreateNoteRequest {
  title: string;
  richContent: any; // Quill Delta JSON
  tags?: string[]; // tag IDs or names
}

export interface UpdateNoteRequest {
  title?: string;
  richContent?: any;
  tags?: string[];
}

export interface NoteFilterOptions {
  searchTerm?: string;
  tagIds?: string[];
  excludeArchived?: boolean;
  excludeDeleted?: boolean;
}

export interface QuillDelta {
  ops: DeltaOp[];
}

export interface DeltaOp {
  insert?: string;
  retain?: number;
  delete?: number;
  attributes?: Record<string, any>;
}
