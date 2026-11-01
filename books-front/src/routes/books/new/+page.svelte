<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { gql, loadGenres } from '#lib/api.ts';
	import { LIST_AUTHORS, createBookMutation } from '#lib/queries.ts';
	import type { Author } from '#lib/types.ts';

	let authors = $state<Author[]>([]);
	let genres = $state<string[]>([]);

	let title = $state('');
	let authorId = $state('');
	let publicationDate = $state(new Date().getFullYear());
	let genre = $state('');
	let error = $state('');
	let saving = $state(false);

	onMount(async () => {
		try {
			const [a, g] = await Promise.all([gql<{ authors: Author[] }>(LIST_AUTHORS), loadGenres()]);
			authors = a.authors;
			genres = g;
			genre = g[0] ?? '';
		} catch (e) {
			error = e instanceof Error ? e.message : 'Falha ao carregar dados do formulário';
		}
	});

	async function onSubmit(e: SubmitEvent) {
		e.preventDefault();
		error = '';
		saving = true;
		try {
			const data = await gql<{ createBook: { id: string } }>(
				createBookMutation({
					title,
					authorId: Number(authorId),
					publicationDate: Number(publicationDate),
					genre
				})
			);
			await goto(`/books/${data.createBook.id}`);
		} catch (err) {
			error = err instanceof Error ? err.message : 'Erro ao criar livro';
		} finally {
			saving = false;
		}
	}
</script>

<main>
	<p class="muted"><a href="/books">← Livros</a></p>
	<h1>Novo livro</h1>

	{#if authors.length === 0 && !error}
		<p class="muted">Cadastre um <a href="/authors">autor</a> antes de criar livros.</p>
	{/if}

	<form class="card stack" onsubmit={onSubmit}>
		<label>Título <input bind:value={title} required /></label>
		<label>
			Autor
			<select bind:value={authorId} required>
				<option value="" disabled>Selecione…</option>
				{#each authors as a (a.id)}
					<option value={a.id}>{a.firstName} {a.lastName}</option>
				{/each}
			</select>
		</label>
		<div class="grid-2">
			<label>
				Ano de publicação
				<input type="number" bind:value={publicationDate} min="0" max="9999" required />
			</label>
			<label>
				Gênero
				<select bind:value={genre} required>
					{#each genres as g}
						<option value={g}>{g}</option>
					{/each}
				</select>
			</label>
		</div>
		{#if error}<p class="error" role="alert">{error}</p>{/if}
		<div class="row">
			<button type="submit" disabled={saving}>{saving ? 'Salvando…' : 'Criar livro'}</button>
			<a href="/books"><button type="button" class="secondary">Cancelar</button></a>
		</div>
	</form>
</main>
