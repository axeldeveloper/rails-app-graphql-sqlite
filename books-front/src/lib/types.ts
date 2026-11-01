export type User = { id: number | string; email: string };

export type AuthPayload = { user: User; access_token: string };

export type AuthorSummary = { id: string; firstName: string; lastName: string };

export type Author = AuthorSummary & { dateOfBirth: string | null };

export type Book = {
	id: string;
	title: string;
	genre: string;
	publicationDate: number | null;
	author?: AuthorSummary & { dateOfBirth?: string | null };
};

export type AuthorWithBooks = AuthorSummary & { books: Omit<Book, 'author'>[] };
