import type { AuthPayload, User } from './types';

const AUTH_BASE = '/api/v1/auth';
// Ajuste se as rotas do Rails usarem outro verbo (ex.: 'DELETE' no logout).
const LOGOUT_METHOD = 'POST';

// O access token vive só em memória (nunca localStorage/sessionStorage).
// O refresh token é cookie HttpOnly gerenciado pelo Rails; o JS não o enxerga.
let accessToken: string | null = null;

export const session = $state<{ user: User | null; ready: boolean }>({
	user: null,
	ready: false
});

export class AuthError extends Error {
	messages: string[];
	constructor(messages: string[]) {
		super(messages.join('; '));
		this.messages = messages;
	}
}

export function getAccessToken(): string | null {
	return accessToken;
}

function apply(data: AuthPayload) {
	accessToken = data.access_token;
	session.user = data.user;
}

function clear() {
	accessToken = null;
	session.user = null;
}

function call(path: string, method: string, body?: unknown) {
	return fetch(`${AUTH_BASE}/${path}`, {
		method,
		credentials: 'same-origin',
		headers: body ? { 'Content-Type': 'application/json', Accept: 'application/json' } : { Accept: 'application/json' },
		body: body ? JSON.stringify(body) : undefined
	});
}

async function submit(path: 'login' | 'register', email: string, password: string) {
	const res = await call(path, 'POST', { email, password });
	const data = await res.json().catch(() => ({}));
	if (!res.ok) {
		throw new AuthError(data.errors ?? [data.error ?? 'Não foi possível concluir a operação']);
	}
	apply(data as AuthPayload);
}

export const login = (email: string, password: string) => submit('login', email, password);
export const register = (email: string, password: string) => submit('register', email, password);

let refreshing: Promise<boolean> | null = null;

/** Renova o access token usando o cookie de refresh. Chamadas simultâneas compartilham a mesma requisição
 *  (o refresh token é rotativo: dois refreshes em paralelo invalidariam a sessão). */
export function refresh(): Promise<boolean> {
	refreshing ??= (async () => {
		try {
			const res = await call('refresh', 'POST');
			if (!res.ok) {
				clear();
				return false;
			}
			apply((await res.json()) as AuthPayload);
			return true;
		} catch {
			return false;
		} finally {
			refreshing = null;
		}
	})();
	return refreshing;
}

/** Chamado uma vez ao abrir o app: tenta restaurar a sessão pelo cookie. */
export async function restore() {
	await refresh();
	session.ready = true;
}

export async function logout() {
	try {
		await call('logout', LOGOUT_METHOD);
	} finally {
		clear();
	}
}
