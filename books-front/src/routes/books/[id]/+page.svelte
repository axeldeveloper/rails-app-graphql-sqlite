<script lang="ts">
	import { page } from '$app/state';
	import { goto } from '$app/navigation';
	import { gql, loadGenres, GraphQLRequestError } from '#lib/api.ts';
	import { FIND_BOOK, UPDATE_BOOK, DELETE_BOOK } from '#lib/queries.ts';
	import type { Book } from '#lib/types.ts';

	let book = $state<Book | null>(null);
	let genres = $state<string[]>([]);
	let loading = $state(true);
	let error = $state('');

	let editing = $state(false);
	let title = $state('');
	let genre = $state('');
	let saving = $state(false);
	let actionError = $state('');

	$effect(() => {
		const id = page.params.id;
		loading = true;
		error = '';
		Promise.all([gql<{ book: Book | null }>(FIND_BOOK, { id }), loadGenres()])
			.then(([data, g]) => {
				book = data.book;
				genres = g;
				if (!data.book) error = 'Livro não encontrado';
			})
			.catch((e) => {
				error = e instanceof GraphQLRequestError ? e.message : 'Falha ao carregar livro';
			})
			.finally(() => (loading = false));
	});

	function startEdit() {
		if (!book) return;
		title = book.title;
		genre = book.genre;
		actionError = '';
		editing = true;
	}

	async function onSave(e: SubmitEvent) {
		e.preventDefault();
		if (!book) return;
		saving = true;
		actionError = '';
		try {
			const data = await gql<{ updateBook: Pick<Book, 'id' | 'title' | 'genre' | 'publicationDate'> }>(
				UPDATE_BOOK,
				{ id: Number(book.id), title, genre }
			);
			book = { ...book, ...data.updateBook };
			editing = false;
		} catch (err) {
			actionError = err instanceof Error ? err.message : 'Erro ao salvar';
		} finally {
			saving = false;
		}
	}

	async function onDelete() {
		if (!book || !confirm(`Excluir "${book.title}"?`)) return;
		actionError = '';
		try {
			await gql(DELETE_BOOK, { id: Number(book.id) });
			await goto('/books');
		} catch (err) {
			actionError = err instanceof Error ? err.message : 'Erro ao excluir';
		}
	}
</script>

<main>
	<p class="muted"><a href="/books">← Livros</a></p>

	{#if loading}
		<p class="muted">Carregando…</p>
	{:else if error}
		<p class="error" role="alert">{error}</p>
	{:else if book}
		{#if editing}
			<h1>Editar livro</h1>
			<form class="card stack" onsubmit={onSave}>
				<label>Título <input bind:value={title} required /></label>
				<label>
					Gênero
					<select bind:value={genre}>
						{#each genres as g}
							<option value={g}>{g}</option>
						{/each}
					</select>
				</label>
				{#if actionError}<p class="error" role="alert">{actionError}</p>{/if}
				<div class="row">
					<button type="submit" disabled={saving}>{saving ? 'Salvando…' : 'Salvar'}</button>
					<button type="button" class="secondary" onclick={() => (editing = false)}>Cancelar</button>
				</div>
			</form>
		{:else}
			<h1>{book.title}</h1>
			<div class="card stack">
				<div><span class="muted">Gênero</span><br /><span class="tag">{book.genre}</span></div>
				<div><span class="muted">Ano de publicação</span><br />{book.publicationDate ?? '—'}</div>
				{#if book.author}
					<div>
						<span class="muted">Autor</span><br />
						<a href={`/authors/${book.author.id}`}>
							{book.author.firstName} {book.author.lastName}
						</a>
					</div>
				{/if}
				{#if actionError}<p class="error" role="alert">{actionError}</p>{/if}
				<div class="row">
					<button type="button" onclick={startEdit}>Editar</button>
					<button type="button" class="danger" onclick={onDelete}>Excluir</button>
				</div>
			</div>
		{/if}
	{/if}
</main>
