export const LIST_AUTHORS = /* GraphQL */ `
	query ListAuthors {
		authors {
			id
			firstName
			lastName
			dateOfBirth
		}
	}
`;

export const FIND_AUTHOR_WITH_BOOKS = /* GraphQL */ `
	query FindAuthorWithBooks($id: ID!) {
		author(id: $id) {
			id
			firstName
			lastName
			books {
				id
				title
				genre
				publicationDate
			}
		}
	}
`;

export const LIST_BOOKS = /* GraphQL */ `
	query ListBooks {
		books {
			id
			title
			genre
			publicationDate
			author {
				id
				firstName
				lastName
			}
		}
	}
`;

export const FIND_BOOK = /* GraphQL */ `
	query FindBook($id: ID!) {
		book(id: $id) {
			id
			title
			genre
			publicationDate
			author {
				id
				firstName
				lastName
				dateOfBirth
			}
		}
	}
`;

export const UPDATE_BOOK = /* GraphQL */ `
	mutation UpdateBook($id: Int!, $title: String, $genre: Genre) {
		updateBook(id: $id, title: $title, genre: $genre) {
			id
			title
			genre
			publicationDate
		}
	}
`;

export const DELETE_BOOK = /* GraphQL */ `
	mutation DeleteBook($id: Int!) {
		destroyBook(id: $id) {
			id
			title
		}
	}
`;

export const GENRES_INTROSPECTION = /* GraphQL */ `
	query GenreValues {
		__type(name: "Genre") {
			enumValues {
				name
			}
		}
	}
`;

// Os exemplos de createAuthor/createBook usam literais inline e não informam os tipos
// dos argumentos (ex.: scalar da data). Para não adivinhar nomes de tipos, montamos o
// documento com literais escapados e validados, em vez de variáveis.

const ENUM_NAME = /^[A-Z][A-Za-z0-9_]*$/;
const ISO_DATE = /^\d{4}-\d{2}-\d{2}$/;

export function createAuthorMutation(input: {
	firstName: string;
	lastName: string;
	dateOfBirth: string;
}): string {
	if (!ISO_DATE.test(input.dateOfBirth)) throw new Error('Data de nascimento inválida');
	return `mutation CreateAuthor {
		createAuthor(
			firstName: ${JSON.stringify(input.firstName)}
			lastName: ${JSON.stringify(input.lastName)}
			dateOfBirth: ${JSON.stringify(input.dateOfBirth)}
		) {
			author { id firstName lastName dateOfBirth }
			errors
		}
	}`;
}

export function createBookMutation(input: {
	title: string;
	authorId: number;
	publicationDate: number;
	genre: string;
}): string {
	if (!Number.isInteger(input.authorId) || !Number.isInteger(input.publicationDate)) {
		throw new Error('Autor e ano devem ser números inteiros');
	}
	if (!ENUM_NAME.test(input.genre)) throw new Error('Gênero inválido');
	return `mutation CreateBook {
		createBook(
			title: ${JSON.stringify(input.title)}
			authorId: ${input.authorId}
			publicationDate: ${input.publicationDate}
			genre: ${input.genre}
		) {
			id title genre publicationDate
		}
	}`;
}
