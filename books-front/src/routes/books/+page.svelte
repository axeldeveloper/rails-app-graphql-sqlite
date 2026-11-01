<script lang="ts">
	import { onMount } from 'svelte';
	import { gql, GraphQLRequestError } from '#lib/api.ts';
	import { LIST_BOOKS } from '#lib/queries.ts';
	import type { Book } from '#lib/types.ts';

	let books = $state<Book[]>([]);
	let loading = $state(true);
	let error = $state('');

	onMount(async () => {
		try {
			const data = await gql<{ books: Book[] }>(LIST_BOOKS);
			books = data.books;
		} catch (e) {
			error = e instanceof GraphQLRequestError ? e.message : 'Falha ao carregar livros';
		} finally {
			loading = false;
		}
	});
</script>

<main>
	<div class="row" style="justify-content: space-between">
		<h1>Livros</h1>
		<a href="/books/new"><button type="button">Novo livro</button></a>
	</div>

	{#if loading}
		<p class="muted">Carregando…</p>
	{:else if error}
		<p class="error" role="alert">{error}</p>
	{:else if books.length === 0}
		<p class="muted">Nenhum livro cadastrado.</p>
	{:else}
		<ul class="list">
			{#each books as b (b.id)}
				<li>
					<span>
						<a href={`/books/${b.id}`}>{b.title}</a>
						{#if b.author}
							<span class="muted"> — {b.author.firstName} {b.author.lastName}</span>
						{/if}
					</span>
					<span class="muted">
						<span class="tag">{b.genre}</span>
						{b.publicationDate ?? ''}
					</span>
				</li>
			{/each}
		</ul>
	{/if}
</main>
