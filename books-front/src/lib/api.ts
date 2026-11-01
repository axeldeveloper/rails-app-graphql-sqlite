import { getAccessToken, refresh } from './auth.svelte';
import { GENRES_INTROSPECTION } from './queries';

const GRAPHQL_URL = '/graphql';

export class GraphQLRequestError extends Error {
	messages: string[];
	constructor(messages: string[]) {
		super(messages.join('; '));
		this.messages = messages;
	}
}

function send(query: string, variables?: Record<string, unknown>) {
	const token = getAccessToken();
	return fetch(GRAPHQL_URL, {
		method: 'POST',
		credentials: 'same-origin',
		headers: {
			'Content-Type': 'application/json',
			Accept: 'application/json',
			...(token ? { Authorization: `Bearer ${token}` } : {})
		},
		body: JSON.stringify({ query, variables })
	});
}

/** Executa uma operação GraphQL. Em 401, tenta renovar o token uma vez e repete. */
export async function gql<T>(query: string, variables?: Record<string, unknown>): Promise<T> {
	let res = await send(query, variables);

	if (res.status === 401 && (await refresh())) {
		res = await send(query, variables);
	}
	if (res.status === 401) {
		// refresh() já limpou a sessão; o layout redireciona para /login.
		throw new GraphQLRequestError(['Sessão expirada. Faça login novamente.']);
	}

	const body = await res.json().catch(() => null);
	if (!res.ok && !body) throw new GraphQLRequestError([`Erro ${res.status} ao chamar a API`]);

	if (body?.errors?.length) {
		throw new GraphQLRequestError(body.errors.map((e: { message: string }) => e.message));
	}
	return body.data as T;
}

const FALLBACK_GENRES = ['Mystery'];
let genresCache: string[] | null = null;

/** Lê os valores do enum Genre por introspecção; se estiver desabilitada, usa o fallback. */
export async function loadGenres(): Promise<string[]> {
	if (genresCache) return genresCache;
	try {
		const data = await gql<{ __type: { enumValues: { name: string }[] } | null }>(
			GENRES_INTROSPECTION
		);
		const values = data.__type?.enumValues.map((v) => v.name) ?? [];
		genresCache = values.length ? values : FALLBACK_GENRES;
	} catch {
		genresCache = FALLBACK_GENRES;
	}
	return genresCache;
}
