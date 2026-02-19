export interface NoteTag {
  id: string;
  name: string;
  isDeleted: boolean;
  createdAt: string;
  updatedAt?: string;
}

export interface Note {
  id: string;
  title: string;
  richContent: object; // Quill Delta JSON format
  tags: NoteTag[];
  isArchived: boolean;
  isDeleted: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface NoteTagJunction {
  noteId: string;
  tagId: string;
}
