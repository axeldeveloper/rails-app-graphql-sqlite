<script lang="ts">
	import { onMount } from 'svelte';
	import { gql, GraphQLRequestError } from '#lib/api.ts';
	import { LIST_AUTHORS, createAuthorMutation } from '#lib/queries.ts';
	import type { Author } from '#lib/types.ts';

	let authors = $state<Author[]>([]);
	let loading = $state(true);
	let error = $state('');

	let firstName = $state('');
	let lastName = $state('');
	let dateOfBirth = $state('');
	let formErrors = $state<string[]>([]);
	let saving = $state(false);

	async function load() {
		try {
			const data = await gql<{ authors: Author[] }>(LIST_AUTHORS);
			authors = data.authors;
		} catch (e) {
			error = e instanceof GraphQLRequestError ? e.message : 'Falha ao carregar autores';
		} finally {
			loading = false;
		}
	}

	onMount(load);

	async function onCreate(e: SubmitEvent) {
		e.preventDefault();
		formErrors = [];
		saving = true;
		try {
			const data = await gql<{ createAuthor: { author: Author | null; errors: string[] | null } }>(
				createAuthorMutation({ firstName, lastName, dateOfBirth })
			);
			const { author, errors } = data.createAuthor;
			if (errors?.length || !author) {
				formErrors = errors?.length ? errors : ['Não foi possível criar o autor'];
				return;
			}
			authors = [...authors, author];
			firstName = lastName = dateOfBirth = '';
		} catch (err) {
			formErrors = [err instanceof Error ? err.message : 'Erro ao criar autor'];
		} finally {
			saving = false;
		}
	}

	const fmt = (iso: string | null) =>
		iso ? new Date(`${iso}T00:00:00`).toLocaleDateString('pt-BR') : '—';
</script>

<main>
	<h1>Autores</h1>

	{#if loading}
		<p class="muted">Carregando…</p>
	{:else if error}
		<p class="error" role="alert">{error}</p>
	{:else if authors.length === 0}
		<p class="muted">Nenhum autor cadastrado.</p>
	{:else}
		<ul class="list">
			{#each authors as a (a.id)}
				<li>
					<a href={`/authors/${a.id}`}>{a.firstName} {a.lastName}</a>
					<span class="muted">Nasc.: {fmt(a.dateOfBirth)}</span>
				</li>
			{/each}
		</ul>
	{/if}

	<h2>Novo autor</h2>
	<form class="card stack" onsubmit={onCreate}>
		<div class="grid-2">
			<label>Nome <input bind:value={firstName} required /></label>
			<label>Sobrenome <input bind:value={lastName} required /></label>
		</div>
		<label>Data de nascimento <input type="date" bind:value={dateOfBirth} required /></label>
		{#each formErrors as message}
			<p class="error" role="alert">{message}</p>
		{/each}
		<div class="row">
			<button type="submit" disabled={saving}>{saving ? 'Salvando…' : 'Criar autor'}</button>
		</div>
	</form>
</main>
