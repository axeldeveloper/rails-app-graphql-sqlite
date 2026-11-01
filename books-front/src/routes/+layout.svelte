<script lang="ts">
	import '../app.css';
	import favicon from '#lib/assets/favicon.svg';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { session, restore, logout } from '#lib/auth.svelte.ts';
	import type { LayoutProps } from './$types';

	let { children }: LayoutProps = $props();

	const PUBLIC_ROUTES = ['/login', '/register'];
	const isPublic = $derived(PUBLIC_ROUTES.includes(page.url.pathname));

	onMount(restore);

	// Guarda de rota: sem sessão vai para /login; com sessão sai das telas públicas.
	$effect(() => {
		if (!session.ready) return;
		if (!session.user && !isPublic) goto('/login', { replaceState: true });
		else if (session.user && isPublic) goto('/books', { replaceState: true });
	});

	async function onLogout() {
		await logout();
		goto('/login');
	}
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>Biblioteca</title>
</svelte:head>

{#if session.user}
	<header class="top">
		<a class="brand" href="/books">Biblioteca</a>
		<nav>
			<a href="/books">Livros</a>
			<a href="/authors">Autores</a>
		</nav>
		<span class="who">{session.user.email}</span>
		<button class="secondary" onclick={onLogout}>Sair</button>
	</header>
{/if}

{#if !session.ready}
	<main><p class="muted">Carregando…</p></main>
{:else if session.user || isPublic}
	{@render children()}
{/if}
