<script lang="ts">
	import { page } from '$app/state';
	import { gql, GraphQLRequestError } from '#lib/api.ts';
	import { FIND_AUTHOR_WITH_BOOKS } from '#lib/queries.ts';
	import type { AuthorWithBooks } from '#lib/types.ts';

	let author = $state<AuthorWithBooks | null>(null);
	let loading = $state(true);
	let error = $state('');

	$effect(() => {
		const id = page.params.id;
		loading = true;
		error = '';
		gql<{ author: AuthorWithBooks | null }>(FIND_AUTHOR_WITH_BOOKS, { id })
			.then((data) => {
				author = data.author;
				if (!data.author) error = 'Autor não encontrado';
			})
			.catch((e) => {
				error = e instanceof GraphQLRequestError ? e.message : 'Falha ao carregar autor';
			})
			.finally(() => (loading = false));
	});
</script>

<main>
	<p class="muted"><a href="/authors">← Autores</a></p>

	{#if loading}
		<p class="muted">Carregando…</p>
	{:else if error}
		<p class="error" role="alert">{error}</p>
	{:else if author}
		<h1>{author.firstName} {author.lastName}</h1>

		<h2>Livros</h2>
		{#if author.books.length === 0}
			<p class="muted">Este autor ainda não tem livros.</p>
		{:else}
			<ul class="list">
				{#each author.books as b (b.id)}
					<li>
						<a href={`/books/${b.id}`}>{b.title}</a>
						<span class="muted">
							<span class="tag">{b.genre}</span>
							{b.publicationDate ?? ''}
						</span>
					</li>
				{/each}
			</ul>
		{/if}
	{/if}
</main>
